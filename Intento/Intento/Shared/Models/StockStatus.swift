import Foundation

enum StockStatus: String, Codable, Hashable, Sendable {
    case inStock = "in_stock"
    case lowStock = "low_stock"
    case outOfStock = "out_of_stock"

    nonisolated var displayName: String {
        switch self {
        case .inStock: "In Stock"
        case .lowStock: "Low Stock"
        case .outOfStock: "Out of Stock"
        }
    }

    nonisolated var isAvailable: Bool {
        self != .outOfStock
    }

    nonisolated static func from(quantity: Int, lowStockThreshold: Int = 3) -> StockStatus {
        if quantity <= 0 { return .outOfStock }
        if quantity <= lowStockThreshold { return .lowStock }
        return .inStock
    }
}
