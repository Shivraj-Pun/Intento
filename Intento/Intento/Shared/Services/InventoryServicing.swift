import Foundation

protocol InventoryServicing: Sendable {
    func status(forSKU sku: String) async throws -> InventoryStatus

    func statuses(forSKUs skus: [String]) async throws -> [String: InventoryStatus]

    func substitutes(forSKU sku: String, limit: Int) async throws -> [Product]
}
