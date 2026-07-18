import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    private let personalization: PersonalizationStoring
    private let seasonal: SeasonalIntelligenceProviding
    let haptics: HapticsServicing

    var recentMissions: [SavedMission] = []
    var preference: UserPreference = .empty
    var restockNudge: String?
    var seasonalHint: String?
    var preferenceHints: [String] = []

    var quickMissions: [String] = []

    private static let defaultQuickMissions: [String] = [
        "Butter chicken for 4 under ₹900",
        "Movie night for 6",
        "Weekly grocery restock",
        "Healthy breakfast for 2",
        "Dinner party for 8",
        "Baby care essentials"
    ]

    init(personalization: PersonalizationStoring, seasonal: SeasonalIntelligenceProviding, haptics: HapticsServicing) {
        self.personalization = personalization
        self.seasonal = seasonal
        self.haptics = haptics
    }

    func load() async {
        preference = (try? await personalization.loadPreferences()) ?? .empty
        recentMissions = (try? await personalization.recentMissions(limit: 10)) ?? []
        computeQuickMissions()
        computeNudges()
    }

    func deleteMission(_ mission: SavedMission) async {
        try? await personalization.deleteMission(withID: mission.id)
        recentMissions.removeAll { $0.id == mission.id }
    }

    private func computeQuickMissions() {
        // Show user's most frequently used missions first
        let frequentMissions = recentMissions
            .filter { $0.timesUsed >= 2 }
            .sorted { $0.timesUsed > $1.timesUsed }
            .prefix(6)
            .map { $0.rawIntentText.isEmpty ? $0.title : $0.rawIntentText }

        if frequentMissions.isEmpty {
            quickMissions = Self.defaultQuickMissions
        } else {
            quickMissions = Array(frequentMissions)
        }
    }

    private func computeNudges() {
        let context = seasonal.currentContext(for: Date())

        if context.festival != .none {
            seasonalHint = "\(context.festival.displayName) is around the corner. Stock up on party supplies and treats."
        } else {
            switch context.season {
            case .summer: seasonalHint = "Summer is here. Cold drinks and juices are in season."
            case .winter: seasonalHint = "Winter picks: fresh greens, carrots and warming staples."
            case .monsoon: seasonalHint = "Monsoon cravings: snacks and hot beverages."
            default: seasonalHint = nil
            }
        }

        if let cadence = preference.restockCadenceDays, let last = preference.lastRestockAt {
            let due = Date().timeIntervalSince(last) >= Double(cadence) * 86_400
            restockNudge = due ? "Time for your restock?" : nil
        } else if recentMissions.contains(where: { $0.occasion == .weeklyRestock }) {
            restockNudge = "Time for your weekly restock?"
        } else {
            restockNudge = nil
        }

        preferenceHints = preference.preferredProducts
            .sorted { $0.frequency > $1.frequency }
            .prefix(2)
            .map { "You usually buy \($0.name)" }
    }
}
