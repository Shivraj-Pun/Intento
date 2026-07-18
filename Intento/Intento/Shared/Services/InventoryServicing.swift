//
//  InventoryServicing.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Real-time (mock) availability and substitution lookups.
protocol InventoryServicing: Sendable {
    /// Current availability for a single SKU.
    func status(forSKU sku: String) async throws -> InventoryStatus

    /// Batched availability lookup, keyed by SKU.
    func statuses(forSKUs skus: [String]) async throws -> [String: InventoryStatus]

    /// Candidate in-stock replacements for an unavailable SKU, best first.
    func substitutes(forSKU sku: String, limit: Int) async throws -> [Product]
}
