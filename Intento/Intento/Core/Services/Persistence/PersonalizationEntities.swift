import Foundation
import SwiftData

@Model
final class SavedMissionEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var createdAt: Date
    var lastUsedAt: Date?
    var timesUsed: Int
    var isPinned: Bool
    var payload: Data

    init(id: UUID, title: String, createdAt: Date, lastUsedAt: Date?, timesUsed: Int, isPinned: Bool, payload: Data) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.lastUsedAt = lastUsedAt
        self.timesUsed = timesUsed
        self.isPinned = isPinned
        self.payload = payload
    }
}

@Model
final class UserPreferenceEntity {
    @Attribute(.unique) var id: UUID
    var updatedAt: Date
    var payload: Data

    init(id: UUID, updatedAt: Date, payload: Data) {
        self.id = id
        self.updatedAt = updatedAt
        self.payload = payload
    }
}

@MainActor
extension SavedMissionEntity {
    static func make(from mission: SavedMission, encoder: JSONEncoder) throws -> SavedMissionEntity {
        SavedMissionEntity(
            id: mission.id,
            title: mission.title,
            createdAt: mission.createdAt,
            lastUsedAt: mission.lastUsedAt,
            timesUsed: mission.timesUsed,
            isPinned: mission.isPinned,
            payload: try encoder.encode(mission)
        )
    }

    func toDomain(decoder: JSONDecoder) -> SavedMission? {
        try? decoder.decode(SavedMission.self, from: payload)
    }

    func update(from mission: SavedMission, encoder: JSONEncoder) throws {
        title = mission.title
        createdAt = mission.createdAt
        lastUsedAt = mission.lastUsedAt
        timesUsed = mission.timesUsed
        isPinned = mission.isPinned
        payload = try encoder.encode(mission)
    }
}
