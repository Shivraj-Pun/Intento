import Foundation

struct Cart: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var items: [CartItem]

    var budget: Money?

    var estimatedETAMinutes: Int?
    var createdAt: Date

    let nearBudgetThreshold: Double

    nonisolated init(
        id: UUID = UUID(),
        items: [CartItem] = [],
        budget: Money? = nil,
        estimatedETAMinutes: Int? = nil,
        createdAt: Date = Date(),
        nearBudgetThreshold: Double = 0.9
    ) {
        self.id = id
        self.items = items
        self.budget = budget
        self.estimatedETAMinutes = estimatedETAMinutes
        self.createdAt = createdAt
        self.nearBudgetThreshold = nearBudgetThreshold
    }

    nonisolated var subtotal: Money {
        items.reduce(Money.zero) { $0 + $1.lineTotal }
    }

    nonisolated var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    nonisolated var isEmpty: Bool {
        items.isEmpty
    }

    nonisolated var substitutionCount: Int {
        items.filter(\.isSubstitution).count
    }

    nonisolated var categories: [ProductCategory] {
        let unique = Set(items.map { $0.product.category })
        return unique.sorted { $0.sortOrder < $1.sortOrder }
    }

    nonisolated func items(in category: ProductCategory) -> [CartItem] {
        items.filter { $0.product.category == category }
    }

    nonisolated var budgetRemaining: Money? {
        guard let budget else { return nil }
        return budget - subtotal
    }

    nonisolated var budgetStatus: BudgetStatus {
        guard let budget, budget.paise > 0 else { return .noBudget }
        let ratio = Double(subtotal.paise) / Double(budget.paise)
        if ratio > 1.0 { return .over }
        if ratio >= nearBudgetThreshold { return .near }
        return .under
    }
}
