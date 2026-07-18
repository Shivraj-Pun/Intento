import Foundation

actor MockProductCatalogService: ProductCatalogServicing {
    private let orderedProducts: [Product]
    private let productsBySKU: [String: Product]

    init(snapshot: CatalogSnapshot) {
        self.orderedProducts = snapshot.products
        self.productsBySKU = Dictionary(
            snapshot.products.map { ($0.sku, $0) },
            uniquingKeysWith: { first, _ in first }
        )
    }

    func allProducts() async throws -> [Product] {
        orderedProducts
    }

    func products(in category: ProductCategory) async throws -> [Product] {
        orderedProducts.filter { $0.category == category }
    }

    func product(forSKU sku: String) async throws -> Product? {
        productsBySKU[sku]
    }

    func products(forSKUs skus: [String]) async throws -> [Product] {
        skus.compactMap { productsBySKU[$0] }
    }

    func search(_ query: String) async throws -> [Product] {
        let normalized = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return [] }
        let tokens = normalized.split(separator: " ").map(String.init)

        return orderedProducts.filter { product in
            let haystack = ([product.name, product.brand ?? "", product.category.displayName]
                + product.tags)
                .joined(separator: " ")
                .lowercased()
            return tokens.allSatisfy { haystack.contains($0) }
        }
    }
}
