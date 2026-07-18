import Foundation

struct CatalogSnapshot: Sendable {
    let products: [Product]
    let inventory: [String: InventoryStatus]

    nonisolated static let empty = CatalogSnapshot(products: [], inventory: [:])

    nonisolated init(products: [Product], inventory: [String: InventoryStatus]) {
        self.products = products
        self.inventory = inventory
    }
}

enum CatalogDecoderError: Error, Sendable {
    case resourceNotFound(name: String)
    case decodingFailed(underlying: Error)
}

struct CatalogDecoder: Sendable {

    private let decoder: JSONDecoder

    init() {
        self.decoder = JSONDecoder()
    }

    func decode(_ data: Data) throws -> CatalogSnapshot {
        do {
            let file = try decoder.decode(CatalogFileDTO.self, from: data)
            return makeSnapshot(from: file.products)
        } catch {
            throw CatalogDecoderError.decodingFailed(underlying: error)
        }
    }

    func loadBundledCatalog(
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

    private func makeSnapshot(from dtos: [ProductDTO]) -> CatalogSnapshot {
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
