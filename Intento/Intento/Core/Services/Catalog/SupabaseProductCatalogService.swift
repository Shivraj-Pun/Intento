import Foundation
import Supabase

actor SupabaseProductCatalogService: ProductCatalogServicing {
    private let client: SupabaseClient
    
    init(client: SupabaseClient) {
        self.client = client
    }
    
    func allProducts() async throws -> [Product] {
        let response: [SupabaseProductDTO] = try await client.database
            .from("products")
            .select()
            .eq("is_active", value: true)
            .execute()
            .value
            
        return response.compactMap { $0.toProduct() }
    }
    
    func products(in category: ProductCategory) async throws -> [Product] {
        let response: [SupabaseProductDTO] = try await client.database
            .from("products")
            .select()
            .eq("category", value: category.rawValue)
            .eq("is_active", value: true)
            .execute()
            .value
            
        return response.compactMap { $0.toProduct() }
    }
    
    func product(forSKU sku: String) async throws -> Product? {
        let response: SupabaseProductDTO = try await client.database
            .from("products")
            .select()
            .eq("sku", value: sku)
            .single()
            .execute()
            .value
            
        return response.toProduct()
    }
    
    func products(forSKUs skus: [String]) async throws -> [Product] {
        guard !skus.isEmpty else { return [] }
        
        // Supabase `in` filter takes an array of strings
        let response: [SupabaseProductDTO] = try await client.database
            .from("products")
            .select()
            .in("sku", values: skus)
            .execute()
            .value
            
        return response.compactMap { $0.toProduct() }
    }
    
    func search(_ query: String) async throws -> [Product] {
        guard !query.isEmpty else { return [] }
        
        // Searches name and tags ignoring case
        let response: [SupabaseProductDTO] = try await client.database
            .from("products")
            .select()
            .or("name.ilike.%\\(query)%,tags.cs.{\\(query)}")
            .eq("is_active", value: true)
            .execute()
            .value
            
        return response.compactMap { $0.toProduct() }
    }
}
