//
//  SeasonalIntelligenceProviding.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Provides local season/festival context and biases suggestions accordingly.
/// Backed by a simple local rules engine in Phase 2 (a live weather source can
/// be added later behind this same protocol).
protocol SeasonalIntelligenceProviding: Sendable {
    /// The seasonal context for a given date (defaults to now at call site).
    func currentContext(for date: Date) -> SeasonalContext

    /// Categories to boost given the current context (e.g. beverages in summer,
    /// party supplies near a festival).
    func boostedCategories(for context: SeasonalContext) -> [ProductCategory]
}
