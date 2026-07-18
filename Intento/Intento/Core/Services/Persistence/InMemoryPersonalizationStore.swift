import Foundation

@MainActor
final class InMemoryPersonalizationStore: PersonalizationStoring {
    private var missions: [UUID: SavedMission] = [:]
    private var preferences: UserPreference = .empty

    init(missions: [SavedMission] = [], preferences: UserPreference = .empty) {
        for mission in missions { self.missions[mission.id] = mission }
        self.preferences = preferences
    }

    func saveMission(_ mission: SavedMission) async throws {
        missions[mission.id] = mission
    }

    func recentMissions(limit: Int) async throws -> [SavedMission] {
        Array(missions.values.sorted { $0.createdAt > $1.createdAt }.prefix(limit))
    }

    func mission(withID id: UUID) async throws -> SavedMission? {
        missions[id]
    }

    func deleteMission(withID id: UUID) async throws {
        missions[id] = nil
    }

    func recordUsage(ofMissionID id: UUID) async throws {
        guard var mission = missions[id] else { return }
        mission.timesUsed += 1
        mission.lastUsedAt = Date()
        missions[id] = mission
    }

    func loadPreferences() async throws -> UserPreference {
        preferences
    }

    func savePreferences(_ preferences: UserPreference) async throws {
        var updated = preferences
        updated.updatedAt = Date()
        self.preferences = updated
    }
}
