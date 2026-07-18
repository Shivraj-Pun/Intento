import Foundation
import Combine
import Supabase

enum PersonalizationStoreError: Error {
    case notAuthenticated
}

/// Personalization store that persists missions to the Supabase `saved_missions`
/// table. Preferences are delegated to a wrapped local store (unchanged behavior).
@MainActor
final class SupabasePersonalizationStore: PersonalizationStoring {
    private let client: SupabaseClient
    private let local: PersonalizationStoring
    private var userID: UUID?
    private var authCancellable: AnyCancellable?

    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    init(client: SupabaseClient, auth: AuthServicing, local: PersonalizationStoring) {
        self.client = client
        self.local = local

        authCancellable = auth.authStatePublisher.sink { [weak self] state in
            Task { @MainActor in
                guard let self else { return }
                if case .loggedIn(let user) = state {
                    self.userID = user.id
                } else {
                    self.userID = nil
                }
            }
        }
    }

    // MARK: - Missions (Supabase)

    func saveMission(_ mission: SavedMission) async throws {
        guard let userID else { throw PersonalizationStoreError.notAuthenticated }

        let insert = SupabaseSavedMissionInsert(
            id: mission.id,
            user_id: userID,
            title: mission.title,
            raw_intent_text: mission.rawIntentText,
            intent: mission.intent,
            cart_snapshot: mission.cartSnapshot,
            occasion: mission.occasion,
            created_at: Self.isoFormatter.string(from: mission.createdAt),
            last_used_at: mission.lastUsedAt.map { Self.isoFormatter.string(from: $0) },
            times_used: mission.timesUsed,
            is_pinned: mission.isPinned
        )

        try await client.database
            .from("saved_missions")
            .upsert(insert, onConflict: "id")
            .execute()
    }

    func recentMissions(limit: Int) async throws -> [SavedMission] {
        guard let userID else { return [] }

        let rows: [SupabaseSavedMissionRow] = try await client.database
            .from("saved_missions")
            .select()
            .eq("user_id", value: userID.uuidString)
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
            .value

        return rows.map { $0.toDomain() }
    }

    func mission(withID id: UUID) async throws -> SavedMission? {
        let rows: [SupabaseSavedMissionRow] = try await client.database
            .from("saved_missions")
            .select()
            .eq("id", value: id.uuidString)
            .limit(1)
            .execute()
            .value

        return rows.first?.toDomain()
    }

    func deleteMission(withID id: UUID) async throws {
        // Detach any carts that reference this mission so the FK constraint
        // (carts.mission_id -> saved_missions.id) doesn't block the delete.
        try await client.database
            .from("carts")
            .update(NullMissionID())
            .eq("mission_id", value: id.uuidString)
            .execute()

        try await client.database
            .from("saved_missions")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }

    func recordUsage(ofMissionID id: UUID) async throws {
        guard let existing = try await mission(withID: id) else { return }

        struct UsageUpdate: Encodable {
            let times_used: Int
            let last_used_at: String
        }

        try await client.database
            .from("saved_missions")
            .update(UsageUpdate(
                times_used: existing.timesUsed + 1,
                last_used_at: Self.isoFormatter.string(from: Date())
            ))
            .eq("id", value: id.uuidString)
            .execute()
    }

    // MARK: - Preferences (delegated to local store)

    func loadPreferences() async throws -> UserPreference {
        try await local.loadPreferences()
    }

    func savePreferences(_ preferences: UserPreference) async throws {
        try await local.savePreferences(preferences)
    }
}

/// Encodes `{"mission_id": null}` explicitly (the synthesized encoder would omit a
/// nil optional, which would leave the column unchanged).
private struct NullMissionID: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeNil(forKey: .mission_id)
    }
    private enum CodingKeys: String, CodingKey {
        case mission_id
    }
}
