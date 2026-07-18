import SwiftUI

extension AppColor {

    nonisolated static func color(for status: BudgetStatus) -> Color {
        switch status {
        case .under: Semantic.success
        case .near: Semantic.warning
        case .over: Semantic.error
        case .noBudget: Semantic.textTertiary
        }
    }

    nonisolated static func color(for status: StockStatus) -> Color {
        switch status {
        case .inStock: Semantic.success
        case .lowStock: Semantic.warning
        case .outOfStock: Semantic.error
        }
    }

    nonisolated static func color(for level: ConfidenceLevel) -> Color {
        switch level {
        case .high: Semantic.success
        case .medium: Semantic.warning
        case .low: Semantic.error
        }
    }
}
