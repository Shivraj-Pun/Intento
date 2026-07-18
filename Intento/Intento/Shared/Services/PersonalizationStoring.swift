//
//  PersonalizationStoring.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Local persistence of missions and learned preferences. The Phase 2 concrete
/// implementation is backed by SwiftData; this protocol keeps the storage
/// framework out of the domain and ViewModels.
protocol PersonalizationStoring: Sendable {

    // MARK: Missions
    func saveMission(_ mission: SavedMission) async throws
    func recentMissions(limit: Int) async throws -> [SavedMission]
    func mission(withID id: UUID) async throws -> SavedMission?
    func deleteMission(withID id: UUID) async throws

    /// Bumps usage count and `lastUsedAt` for a reused mission.
    func recordUsage(ofMissionID id: UUID) async throws

    // MARK: Preferences
    func loadPreferences() async throws -> UserPreference
    func savePreferences(_ preferences: UserPreference) async throws
}
