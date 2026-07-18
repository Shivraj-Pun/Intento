//
//  BudgetStatus.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Traffic-light budget state for a cart. Colour mapping is done in the view
/// layer (Phase 2) so this stays free of any UI dependency.
enum BudgetStatus: String, Codable, Hashable, Sendable {
    case noBudget = "no_budget"
    case under
    case near
    case over

    nonisolated var displayName: String {
        switch self {
        case .noBudget: "No budget set"
        case .under: "Within budget"
        case .near: "Close to budget"
        case .over: "Over budget"
        }
    }

    /// Semantic colour name (green / amber / red) resolved to an actual colour
    /// in the UI layer.
    nonisolated var semanticColorName: String {
        switch self {
        case .noBudget: "neutral"
        case .under: "green"
        case .near: "amber"
        case .over: "red"
        }
    }
}
