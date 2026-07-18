import Foundation

/// Insert/upsert payload for the `saved_missions` table.
///
/// `intent`, `cart_snapshot` and `occasion` are nested `Codable` values that the
/// Supabase client serializes into the corresponding `jsonb` columns. The date
/// columns are sent as ISO8601 strings for predictable `timestamptz` mapping.
struct SupabaseSavedMissionInsert: Encodable, Sendable {
    let id: UUID
    let user_id: UUID
    let title: String
    let raw_intent_text: String
    let intent: ShoppingIntent?
    let cart_snapshot: Cart?
    let occasion: Occasion?
    let created_at: String
    let last_used_at: String?
    let times_used: Int
    let is_pinned: Bool
}

/// Row shape returned when selecting from `saved_missions`.
struct SupabaseSavedMissionRow: Decodable, Sendable {
    let id: UUID
    let user_id: UUID
    let title: String
    let raw_intent_text: String
    let intent: ShoppingIntent?
    let cart_snapshot: Cart?
    let occasion: Occasion?
    let created_at: Date
    let last_used_at: Date?
    let times_used: Int
    let is_pinned: Bool

    func toDomain() -> SavedMission {
        SavedMission(
            id: id,
            title: title,
            rawIntentText: raw_intent_text,
            intent: intent,
            cartSnapshot: cart_snapshot,
            occasion: occasion,
            createdAt: created_at,
            lastUsedAt: last_used_at,
            timesUsed: times_used,
            isPinned: is_pinned
        )
    }
}
