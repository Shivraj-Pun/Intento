import Foundation

struct Cart: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var items: [CartItem]

    var budget: Money?

    var estimatedETAMinutes: Int?
    var createdAt: Date

    /// Items requested by the LLM that couldn't be matched to any product in the catalog.
    var unmatchedItems: [String]

    let nearBudgetThreshold: Double

    nonisolated init(
        id: UUID = UUID(),
        items: [CartItem] = [],
        budget: Money? = nil,
        estimatedETAMinutes: Int? = nil,
        createdAt: Date = Date(),
        unmatchedItems: [String] = [],
        nearBudgetThreshold: Double = 0.9
    ) {
        self.id = id
        self.items = items
        self.budget = budget
        self.estimatedETAMinutes = estimatedETAMinutes
        self.createdAt = createdAt
        self.unmatchedItems = unmatchedItems
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

    nonisolated var hasUnmatchedItems: Bool {
        !unmatchedItems.isEmpty
    }

    nonisolated var budgetStatus: BudgetStatus {
        guard let budget, budget.paise > 0 else { return .noBudget }
        let ratio = Double(subtotal.paise) / Double(budget.paise)
        if ratio > 1.0 { return .over }
        if ratio >= nearBudgetThreshold { return .near }
        return .under
    }

    // MARK: - Codable (gracefully handles missing unmatchedItems in legacy data)

    private enum CodingKeys: String, CodingKey {
        case id, items, budget, estimatedETAMinutes, createdAt, unmatchedItems, nearBudgetThreshold
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        items = try container.decode([CartItem].self, forKey: .items)
        budget = try container.decodeIfPresent(Money.self, forKey: .budget)
        estimatedETAMinutes = try container.decodeIfPresent(Int.self, forKey: .estimatedETAMinutes)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        unmatchedItems = try container.decodeIfPresent([String].self, forKey: .unmatchedItems) ?? []
        nearBudgetThreshold = try container.decodeIfPresent(Double.self, forKey: .nearBudgetThreshold) ?? 0.9
    }
}
