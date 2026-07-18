import Foundation
import Observation

@MainActor
@Observable
final class CartViewModel {
    enum Phase: Equatable {
        case idle
        case generating
        case ready
        case failed
    }

    private let assembler: CartAssembling
    private let budgetOptimizer: BudgetOptimizing
    private let catalog: ProductCatalogServicing
    private let inventory: InventoryServicing
    private let nutrition: NutritionAdvising
    private let sustainability: SustainabilityAdvising
    private let personalization: PersonalizationStoring
    let haptics: HapticsServicing
    let currencyCode: String
    let localeIdentifier: String

    private(set) var intent: ShoppingIntent
    private var baseCart = Cart()

    var phase: Phase = .idle
    var cart = Cart()
    var fitToBudget = false
    var nutritionAware = false
    var sustainabilitySuggestions: [SustainabilitySuggestion] = []
    var dismissedSuggestionIDs: Set<UUID> = []
    var errorMessage: String?
    var orderConfirmation: OrderConfirmation?
    var isCheckingOut = false

    private var generationTask: Task<Void, Never>?

    var visibleSustainabilitySuggestions: [SustainabilitySuggestion] {
        sustainabilitySuggestions.filter { !dismissedSuggestionIDs.contains($0.id) }
    }

    var budgetStatus: BudgetStatus { cart.budgetStatus }

    init(
        intent: ShoppingIntent,
        assembler: CartAssembling,
        budgetOptimizer: BudgetOptimizing,
        catalog: ProductCatalogServicing,
        inventory: InventoryServicing,
        nutrition: NutritionAdvising,
        sustainability: SustainabilityAdvising,
        personalization: PersonalizationStoring,
        haptics: HapticsServicing,
        currencyCode: String,
        localeIdentifier: String
    ) {
        self.intent = intent
        self.assembler = assembler
        self.budgetOptimizer = budgetOptimizer
        self.catalog = catalog
        self.inventory = inventory
        self.nutrition = nutrition
        self.sustainability = sustainability
        self.personalization = personalization
        self.haptics = haptics
        self.currencyCode = currencyCode
        self.localeIdentifier = localeIdentifier
        self.fitToBudget = intent.budget != nil
    }

    func start() {
        generationTask?.cancel()
        generationTask = Task { await generate() }
    }

    func regenerate(with intent: ShoppingIntent) {
        self.intent = intent
        self.fitToBudget = intent.budget != nil
        orderConfirmation = nil
        start()
    }

    func format(_ money: Money) -> String {
        money.formatted(currencyCode: currencyCode, localeIdentifier: localeIdentifier)
    }

    private func generate() async {
        phase = .generating
        cart = Cart(budget: intent.budget)
        sustainabilitySuggestions = []
        dismissedSuggestionIDs = []
        errorMessage = nil

        do {
            for try await update in assembler.generateCartStream(for: intent) {
                cart = update.partialCart
                if update.isComplete {
                    baseCart = update.partialCart
                    rebuild()
                    await refreshSustainability()
                    phase = .ready
                    haptics.play(.cartGenerated)
                    await persistMission()
                }
            }
        } catch {
            errorMessage = "Could not build your cart. Please try again."
            phase = .failed
            haptics.play(.error)
        }
    }

    func setQuantity(for item: CartItem, to quantity: Int) {
        guard let index = baseCart.items.firstIndex(where: { $0.id == item.id }) else { return }
        if quantity <= 0 {
            baseCart.items.remove(at: index)
        } else {
            baseCart.items[index].quantity = quantity
        }
        rebuild()
        haptics.play(.selection)
    }

    func increment(_ item: CartItem) {
        setQuantity(for: item, to: item.quantity + 1)
    }

    func decrement(_ item: CartItem) {
        setQuantity(for: item, to: item.quantity - 1)
    }

    func remove(_ item: CartItem) {
        baseCart.items.removeAll { $0.id == item.id }
        rebuild()
        haptics.play(.warning)
    }

    func toggleFitToBudget() {
        fitToBudget.toggle()
        rebuild()
        haptics.play(.selection)
    }

    func setNutritionAware(_ enabled: Bool) {
        nutritionAware = enabled
        haptics.play(.selection)
    }

    func alternatives(for item: CartItem) async -> [Product] {
        let inStock = (try? await inventory.substitutes(forSKU: item.product.sku, limit: 6)) ?? []
        if !inStock.isEmpty { return inStock }
        let sameCategory = (try? await catalog.products(in: item.product.category)) ?? []
        return sameCategory.filter { $0.sku != item.product.sku }
    }

    func replace(_ item: CartItem, with product: Product) {
        guard let index = baseCart.items.firstIndex(where: { $0.id == item.id }) else { return }
        baseCart.items[index] = CartItem(
            id: item.id,
            product: product,
            quantity: item.quantity,
            source: .userAdded
        )
        rebuild()
        haptics.play(.selection)
    }

    func healthierAlternative(for item: CartItem) async -> Product? {
        try? await nutrition.healthierAlternative(for: item.product, within: intent.budget)
    }

    func applySuggestion(_ suggestion: SustainabilitySuggestion) async {
        guard let replacement = try? await catalog.product(forSKU: suggestion.suggestedSKU),
              let index = baseCart.items.firstIndex(where: { $0.product.sku == suggestion.originalSKU }) else { return }
        let existing = baseCart.items[index]
        baseCart.items[index] = CartItem(
            id: existing.id,
            product: replacement,
            quantity: existing.quantity,
            source: .suggestion
        )
        dismissedSuggestionIDs.insert(suggestion.id)
        rebuild()
        haptics.play(.success)
    }

    func dismissSuggestion(_ suggestion: SustainabilitySuggestion) {
        dismissedSuggestionIDs.insert(suggestion.id)
    }

    func checkout() async {
        guard !cart.isEmpty else { return }
        isCheckingOut = true
        defer { isCheckingOut = false }

        try? await Task.sleep(nanoseconds: 400_000_000)

        let confirmation = OrderConfirmation(
            orderNumber: Self.makeOrderNumber(),
            itemCount: cart.itemCount,
            total: cart.subtotal,
            etaMinutes: cart.estimatedETAMinutes
        )
        orderConfirmation = confirmation
        haptics.play(.checkout)
        await persistMission(checkedOut: true)
        await learnPreferences()
    }

    private func rebuild() {
        if fitToBudget, let budget = intent.budget {
            cart = budgetOptimizer.fitToBudget(baseCart, budget: budget)
        } else {
            var updated = baseCart
            updated.budget = intent.budget
            cart = updated
        }
    }

    private func refreshSustainability() async {
        sustainabilitySuggestions = (try? await sustainability.sustainableAlternatives(for: cart)) ?? []
    }

    private func persistMission(checkedOut: Bool = false) async {
        let mission = SavedMission(
            title: intent.goal,
            rawIntentText: intent.rawText,
            intent: intent,
            cartSnapshot: cart,
            occasion: intent.occasion,
            lastUsedAt: checkedOut ? Date() : nil,
            timesUsed: checkedOut ? 1 : 0
        )
        try? await personalization.saveMission(mission)
    }

    private func learnPreferences() async {
        guard var preference = try? await personalization.loadPreferences() else { return }
        for item in cart.items {
            if let index = preference.preferredProducts.firstIndex(where: { $0.sku == item.product.sku }) {
                preference.preferredProducts[index].frequency += 1
            } else {
                preference.preferredProducts.append(
                    PreferredProduct(category: item.product.category, sku: item.product.sku, name: item.product.displayTitle)
                )
            }
        }
        if intent.occasion == .weeklyRestock {
            preference.lastRestockAt = Date()
            if preference.restockCadenceDays == nil { preference.restockCadenceDays = 7 }
        }
        try? await personalization.savePreferences(preference)
    }

    private static func makeOrderNumber() -> String {
        let digits = (0..<6).map { _ in String(Int.random(in: 0...9)) }.joined()
        return "INT-\(digits)"
    }
}
