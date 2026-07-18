import Foundation

// MARK: - Cart Row DTO

struct SupabaseCartRow: Codable, Sendable {
    let id: UUID
    let user_id: UUID
    let budget_paise: Int?
    let estimated_eta_minutes: Int?
    let near_budget_threshold: Double
    let status: String
    let mission_id: UUID?
    let created_at: String
    let updated_at: String
}

struct SupabaseCartInsert: Encodable, Sendable {
    let id: UUID
    let user_id: UUID
    let budget_paise: Int?
    let estimated_eta_minutes: Int?
    let near_budget_threshold: Double
    let status: String
    let mission_id: UUID?
}

// MARK: - Cart Item Row DTO

struct SupabaseCartItemRow: Codable, Sendable {
    let id: UUID
    let cart_id: UUID
    let product_sku: String
    let quantity: Int
    let source: String
    let substitution: String? // JSON string of SubstitutionRecord
    let added_at: String
}

struct SupabaseCartItemInsert: Encodable, Sendable {
    let id: UUID
    let cart_id: UUID
    let product_sku: String
    let quantity: Int
    let source: String
    let substitution: String? // JSON-encoded SubstitutionRecord
}

struct SupabaseCartItemQuantityUpdate: Encodable, Sendable {
    let quantity: Int
}
