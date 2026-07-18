//
//  AppColor+Status.swift
//  Intento (Ask Blinkit)
//
//  Bridges domain status enums to design-system colours so status colouring is
//  consistent everywhere it appears (budget bar, stock labels, confidence).
//

import SwiftUI

extension AppColor {

    /// Resolves the semantic colour name declared on `BudgetStatus`
    /// (green / amber / red / neutral) to a palette colour.
    nonisolated static func color(for status: BudgetStatus) -> Color {
        switch status {
        case .under: Semantic.success
        case .near: Semantic.warning
        case .over: Semantic.error
        case .noBudget: Semantic.textTertiary
        }
    }

    /// Colour for a stock/availability state.
    nonisolated static func color(for status: StockStatus) -> Color {
        switch status {
        case .inStock: Semantic.success
        case .lowStock: Semantic.warning
        case .outOfStock: Semantic.error
        }
    }

    /// Colour for an intent confidence level.
    nonisolated static func color(for level: ConfidenceLevel) -> Color {
        switch level {
        case .high: Semantic.success
        case .medium: Semantic.warning
        case .low: Semantic.error
        }
    }
}
