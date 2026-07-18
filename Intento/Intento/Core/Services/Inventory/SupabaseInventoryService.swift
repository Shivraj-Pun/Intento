import Foundation
import Supabase

actor SupabaseInventoryService: InventoryServicing {
    private let client: SupabaseClient
    private let catalog: ProductCatalogServicing

    init(client: SupabaseClient, catalog: ProductCatalogServicing) {
        self.client = client
        self.catalog = catalog
    }

    func status(forSKU sku: String) async throws -> InventoryStatus {
        let response: SupabaseProductDTO = try await client.database
            .from("products")
            .select()
            .eq("sku", value: sku)
            .single()
            .execute()
            .value
            
        return InventoryStatus(
            sku: sku,
            quantityAvailable: response.quantity_available,
            etaMinutes: 12 // Using a constant default for now
        )
    }

    func statuses(forSKUs skus: [String]) async throws -> [String: InventoryStatus] {
        guard !skus.isEmpty else { return [:] }
        
        let response: [SupabaseProductDTO] = try await client.database
            .from("products")
            .select()
            .in("sku", values: skus)
            .execute()
            .value
            
        var statuses: [String: InventoryStatus] = [:]
        for dto in response {
            statuses[dto.sku] = InventoryStatus(
                sku: dto.sku,
                quantityAvailable: dto.quantity_available,
                etaMinutes: 12
            )
        }
        
        return statuses
    }

    func substitutes(forSKU sku: String, limit: Int) async throws -> [Product] {
        guard let product = try await catalog.product(forSKU: sku) else { return [] }
        
        let response: [SupabaseProductDTO] = try await client.database
            .from("products")
            .select()
            .eq("category", value: product.category.rawValue)
            .neq("sku", value: sku)
            .eq("is_active", value: true)
            .execute()
            .value
            
        let products = response.compactMap { $0.toProduct() }
        
        // Return up to `limit` available substitutes
        return Array(products.prefix(limit))
    }
}
