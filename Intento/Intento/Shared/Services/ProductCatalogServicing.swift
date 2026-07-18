import Foundation

protocol ProductCatalogServicing: Sendable {
    func allProducts() async throws -> [Product]
    func products(in category: ProductCategory) async throws -> [Product]
    func product(forSKU sku: String) async throws -> Product?
    func products(forSKUs skus: [String]) async throws -> [Product]

    func search(_ query: String) async throws -> [Product]
}
