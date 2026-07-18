import Foundation

protocol PersonalizationStoring: Sendable {

    func saveMission(_ mission: SavedMission) async throws
    func recentMissions(limit: Int) async throws -> [SavedMission]
    func mission(withID id: UUID) async throws -> SavedMission?
    func deleteMission(withID id: UUID) async throws

    func recordUsage(ofMissionID id: UUID) async throws

    func loadPreferences() async throws -> UserPreference
    func savePreferences(_ preferences: UserPreference) async throws
}
