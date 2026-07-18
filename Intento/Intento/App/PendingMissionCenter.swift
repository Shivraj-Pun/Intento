import Foundation
import Observation

/// Structured payload from Siri / App Intents that preserves parameters beyond a raw text prompt.
struct PendingMission: Equatable {
    let prompt: String
    var peopleCount: Int?
    var budget: Int? // rupees
    var dietaryConstraints: [String]
    var occasion: String?

    init(
        prompt: String,
        peopleCount: Int? = nil,
        budget: Int? = nil,
        dietaryConstraints: [String] = [],
        occasion: String? = nil
    ) {
        self.prompt = prompt
        self.peopleCount = peopleCount
        self.budget = budget
        self.dietaryConstraints = dietaryConstraints
        self.occasion = occasion
    }
}

@MainActor
@Observable
final class PendingMissionCenter {
    static let shared = PendingMissionCenter()

    /// Legacy string-only access (still drives onChange in RootView).
    var pendingPrompt: String?

    /// Rich structured mission from Siri intents.
    var pendingMission: PendingMission?

    private init() {}

    /// Simple text-only submission (backwards-compatible).
    func submit(_ prompt: String) {
        pendingPrompt = prompt
        pendingMission = PendingMission(prompt: prompt)
    }

    /// Rich submission with all Siri parameters preserved.
    func submit(mission: PendingMission) {
        pendingPrompt = mission.prompt
        pendingMission = mission
    }

    func consume() -> PendingMission? {
        defer {
            pendingPrompt = nil
            pendingMission = nil
        }
        return pendingMission
    }
}
