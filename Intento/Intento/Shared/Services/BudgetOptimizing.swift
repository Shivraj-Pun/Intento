//
//  BudgetOptimizing.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Adjusts a cart to fit within a target budget (the "fit to budget" toggle).
/// Pure, synchronous, unit-testable logic. No SwiftUI or service dependency.
protocol BudgetOptimizing: Sendable {
    /// Returns a cart adjusted to fall within `budget` where possible, e.g. by
    /// swapping to cheaper alternatives or trimming optional/suggested items.
    func fitToBudget(_ cart: Cart, budget: Money) -> Cart
}
