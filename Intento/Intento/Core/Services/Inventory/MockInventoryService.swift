import Foundation

actor MockInventoryService: InventoryServicing {
    private let inventory: [String: InventoryStatus]
    private let catalog: ProductCatalogServicing

    init(inventory: [String: InventoryStatus], catalog: ProductCatalogServicing) {
        self.inventory = inventory
        self.catalog = catalog
    }

    func status(forSKU sku: String) async throws -> InventoryStatus {
        inventory[sku] ?? InventoryStatus(sku: sku, quantityAvailable: 0)
    }

    func statuses(forSKUs skus: [String]) async throws -> [String: InventoryStatus] {
        var result: [String: InventoryStatus] = [:]
        for sku in skus {
            result[sku] = inventory[sku] ?? InventoryStatus(sku: sku, quantityAvailable: 0)
        }
        return result
    }

    func substitutes(forSKU sku: String, limit: Int) async throws -> [Product] {
        guard let original = try await catalog.product(forSKU: sku) else { return [] }
        let sameCategory = try await catalog.products(in: original.category)

        let available = sameCategory.filter { candidate in
            candidate.sku != sku && (inventory[candidate.sku]?.isAvailable ?? false)
        }

        let ranked = available.sorted { lhs, rhs in
            let lhsGap = abs(lhs.price.paise - original.price.paise)
            let rhsGap = abs(rhs.price.paise - original.price.paise)
            if lhsGap != rhsGap { return lhsGap < rhsGap }
            return (rhs.nutritionScore ?? 0) < (lhs.nutritionScore ?? 0)
        }

        return Array(ranked.prefix(max(0, limit)))
    }
}
