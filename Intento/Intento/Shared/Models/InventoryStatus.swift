//
//  InventoryStatus.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Live (mock) availability information for a single SKU. Kept separate from
/// `Product` so the catalog and inventory services can evolve independently.
struct InventoryStatus: Codable, Hashable, Sendable {
    let sku: String
    let quantityAvailable: Int

    /// Estimated delivery time in minutes for this SKU, when known.
    let etaMinutes: Int?

    /// Threshold at or below which the item is considered low stock.
    let lowStockThreshold: Int

    init(sku: String, quantityAvailable: Int, etaMinutes: Int? = nil, lowStockThreshold: Int = 3) {
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
