import Foundation

struct InventoryStatus: Codable, Hashable, Sendable {
    let sku: String
    let quantityAvailable: Int

    let etaMinutes: Int?

    let lowStockThreshold: Int

    nonisolated init(sku: String, quantityAvailable: Int, etaMinutes: Int? = nil, lowStockThreshold: Int = 3) {
        self.sku = sku
        self.quantityAvailable = quantityAvailable
        self.etaMinutes = etaMinutes
        self.lowStockThreshold = lowStockThreshold
    }

    nonisolated var status: StockStatus {
        StockStatus.from(quantity: quantityAvailable, lowStockThreshold: lowStockThreshold)
    }

    nonisolated var isAvailable: Bool {
        status.isAvailable
    }
}
