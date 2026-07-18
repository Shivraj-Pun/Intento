import Foundation

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

    nonisolated var semanticColorName: String {
        switch self {
        case .noBudget: "neutral"
        case .under: "green"
        case .near: "amber"
        case .over: "red"
        }
    }
}
