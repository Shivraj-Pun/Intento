import Foundation
import Observation

@MainActor
@Observable
final class PendingMissionCenter {
    static let shared = PendingMissionCenter()
    var pendingPrompt: String?

    private init() {}

    func submit(_ prompt: String) {
        pendingPrompt = prompt
    }

    func consume() -> String? {
        defer { pendingPrompt = nil }
        return pendingPrompt
    }
}
