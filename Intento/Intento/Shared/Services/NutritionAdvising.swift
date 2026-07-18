//
//  NutritionAdvising.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Suggests healthier product swaps within a comparable budget. Only consulted
/// when the user's nutrition-aware toggle is on (off by default).
protocol NutritionAdvising: Sendable {
    /// A healthier alternative to `product` costing no more than `budget`
    /// (when provided), or `nil` if none qualifies.
    func healthierAlternative(for product: Product, within budget: Money?) async throws -> Product?
}
