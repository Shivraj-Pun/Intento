//
//  ScalingRule.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// How to round a fractional pack count up to a purchasable integer quantity.
enum RoundingStrategy: String, Codable, Hashable, Sendable {
    case up
    case nearest
    case down

    /// Applies the strategy to a raw pack count, never returning less than 1.
    nonisolated func apply(to rawQuantity: Double) -> Int {
        let rounded: Double
        switch self {
        case .up: rounded = rawQuantity.rounded(.up)
        case .nearest: rounded = rawQuantity.rounded()
        case .down: rounded = rawQuantity.rounded(.down)
        }
        return max(1, Int(rounded))
    }
}

/// Category-specific parameters consumed by the quantity-scaling engine
/// (Phase 2). Pure configuration data so the scaling logic itself stays
/// testable and free of hard-coded constants.
struct ScalingRule: Codable, Hashable, Sendable {
    let category: ProductCategory

    /// Base number of servings needed per person for one sitting/day.
    let servingsPerPerson: Double

    /// Multiplier applied per additional day of duration (1.0 = linear).
    let perDayMultiplier: Double

    /// How to round the resulting fractional pack count.
    let rounding: RoundingStrategy

    init(
        category: ProductCategory,
        servingsPerPerson: Double,
        perDayMultiplier: Double = 1.0,
        rounding: RoundingStrategy = .up
    ) {
        self.category = category
        self.servingsPerPerson = servingsPerPerson
        self.perDayMultiplier = perDayMultiplier
        self.rounding = rounding
    }
}
