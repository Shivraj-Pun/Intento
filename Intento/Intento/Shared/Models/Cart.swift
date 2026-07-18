//
//  Cart.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// The generated shopping cart. Pure data model; all derived values are
/// computed and unit-testable with no UI dependency.
struct Cart: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var items: [CartItem]

    /// Target budget, when the user stated or the engine inferred one.
    var budget: Money?

    /// Aggregate estimated delivery time for the whole cart, in minutes.
    var estimatedETAMinutes: Int?
    var createdAt: Date

    /// Percentage thresholds controlling when the budget status flips to
    /// "near" (amber). Above 100% is always "over".
    let nearBudgetThreshold: Double

    init(
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

    // MARK: - Derived values

    nonisolated var subtotal: Money {
        items.reduce(Money.zero) { $0 + $1.lineTotal }
    }

    /// Total number of individual packs across all lines.
    nonisolated var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    nonisolated var isEmpty: Bool {
        items.isEmpty
    }

    nonisolated var substitutionCount: Int {
        items.filter(\.isSubstitution).count
    }

    /// Distinct categories present, ordered by their canonical sort order.
    nonisolated var categories: [ProductCategory] {
        let unique = Set(items.map { $0.product.category })
        return unique.sorted { $0.sortOrder < $1.sortOrder }
    }

    /// Items belonging to a category, preserving insertion order.
    nonisolated func items(in category: ProductCategory) -> [CartItem] {
        items.filter { $0.product.category == category }
    }

    /// Amount remaining before hitting the budget (negative if over).
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
