//
//  QuantityScaling.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Portion-aware quantity scaling. Pure, synchronous, and unit-testable
/// (shipped with XCTest coverage in Phase 2). No SwiftUI or service dependency.
protocol QuantityScaling: Sendable {
    /// Recommended number of packs of `product` for the given intent,
    /// accounting for headcount, duration, category multipliers, and
    /// sensible pack-size rounding.
    func recommendedQuantity(for product: Product, intent: ShoppingIntent) -> Int
}
