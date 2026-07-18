//
//  CatalogDecoder.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// The decoded result of the bundled catalog: domain products plus their
/// inventory records. A single JSON file feeds both the catalog and inventory
/// mock services (Phase 2).
struct CatalogSnapshot: Sendable {
    let products: [Product]
    let inventory: [String: InventoryStatus]

    static let empty = CatalogSnapshot(products: [], inventory: [:])
}

/// Errors thrown while loading or decoding the catalog.
enum CatalogDecoderError: Error, Sendable {
    case resourceNotFound(name: String)
    case decodingFailed(underlying: Error)
}

/// A basic `Codable` decoder for the mock catalog JSON. This is intentionally
/// *not* the full `ProductCatalogServicing` implementation (that arrives in
/// Phase 2); it only turns bundled JSON into domain models.
struct CatalogDecoder: Sendable {

    private let decoder: JSONDecoder

    init() {
        self.decoder = JSONDecoder()
    }

    /// Decode a catalog snapshot from raw JSON data.
    nonisolated func decode(_ data: Data) throws -> CatalogSnapshot {
        do {
            let file = try decoder.decode(CatalogFileDTO.self, from: data)
            return makeSnapshot(from: file.products)
        } catch {
            throw CatalogDecoderError.decodingFailed(underlying: error)
        }
    }

    /// Load and decode the bundled catalog resource (default `catalog.json`).
    nonisolated func loadBundledCatalog(
        named resource: String = "catalog",
        withExtension ext: String = "json",
        in bundle: Bundle = .main
    ) throws -> CatalogSnapshot {
        guard let url = bundle.url(forResource: resource, withExtension: ext) else {
            throw CatalogDecoderError.resourceNotFound(name: "\(resource).\(ext)")
        }
        let data = try Data(contentsOf: url)
        return try decode(data)
    }

    private nonisolated func makeSnapshot(from dtos: [ProductDTO]) -> CatalogSnapshot {
        var products: [Product] = []
        var inventory: [String: InventoryStatus] = [:]
        products.reserveCapacity(dtos.count)

        for dto in dtos {
            guard let product = dto.toProduct() else { continue }
            products.append(product)
            inventory[dto.sku] = dto.toInventoryStatus()
        }

        return CatalogSnapshot(products: products, inventory: inventory)
    }
}
