//
//  ProductCatalogServicing.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Read access to the product catalog. Modelled as if backed by a real-time
/// backend; the Phase 2 concrete implementation reads the bundled mock catalog
/// and can be swapped for a network client without touching consumers.
protocol ProductCatalogServicing: Sendable {
    func allProducts() async throws -> [Product]
    func products(in category: ProductCategory) async throws -> [Product]
    func product(forSKU sku: String) async throws -> Product?
    func products(forSKUs skus: [String]) async throws -> [Product]

    /// Free-text search across name, brand, and tags.
    func search(_ query: String) async throws -> [Product]
}
