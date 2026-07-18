import Foundation
import SwiftData

@MainActor
final class SwiftDataPersonalizationStore: PersonalizationStoring {
    private let context: ModelContext
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(context: ModelContext) {
        self.context = context
    }

    func saveMission(_ mission: SavedMission) async throws {
        let id = mission.id
        let descriptor = FetchDescriptor<SavedMissionEntity>(predicate: #Predicate { $0.id == id })
        if let existing = try context.fetch(descriptor).first {
            try existing.update(from: mission, encoder: encoder)
        } else {
            context.insert(try SavedMissionEntity.make(from: mission, encoder: encoder))
        }
        try context.save()
    }

    func recentMissions(limit: Int) async throws -> [SavedMission] {
        var descriptor = FetchDescriptor<SavedMissionEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try context.fetch(descriptor).compactMap { $0.toDomain(decoder: decoder) }
    }

    func mission(withID id: UUID) async throws -> SavedMission? {
        let descriptor = FetchDescriptor<SavedMissionEntity>(predicate: #Predicate { $0.id == id })
        return try context.fetch(descriptor).first?.toDomain(decoder: decoder)
    }

    func deleteMission(withID id: UUID) async throws {
        let descriptor = FetchDescriptor<SavedMissionEntity>(predicate: #Predicate { $0.id == id })
        for entity in try context.fetch(descriptor) {
            context.delete(entity)
        }
        try context.save()
    }

    func recordUsage(ofMissionID id: UUID) async throws {
        let descriptor = FetchDescriptor<SavedMissionEntity>(predicate: #Predicate { $0.id == id })
        guard let entity = try context.fetch(descriptor).first,
              var mission = entity.toDomain(decoder: decoder) else { return }
        mission.timesUsed += 1
        mission.lastUsedAt = Date()
        try entity.update(from: mission, encoder: encoder)
        try context.save()
    }

    func loadPreferences() async throws -> UserPreference {
        let descriptor = FetchDescriptor<UserPreferenceEntity>()
        if let entity = try context.fetch(descriptor).first,
           let preference = try? decoder.decode(UserPreference.self, from: entity.payload) {
            return preference
        }
        return .empty
    }

    func savePreferences(_ preferences: UserPreference) async throws {
        var toSave = preferences
        toSave.updatedAt = Date()
        let data = try encoder.encode(toSave)

        let descriptor = FetchDescriptor<UserPreferenceEntity>()
        if let entity = try context.fetch(descriptor).first {
            entity.payload = data
            entity.updatedAt = toSave.updatedAt
        } else {
            context.insert(UserPreferenceEntity(id: toSave.id, updatedAt: toSave.updatedAt, payload: data))
        }
        try context.save()
    }
}
