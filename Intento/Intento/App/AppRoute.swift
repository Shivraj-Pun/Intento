import Foundation

struct MissionSeed: Hashable, Identifiable {
    let id: UUID
    let prompt: String

    nonisolated init(id: UUID = UUID(), prompt: String) {
        self.id = id
        self.prompt = prompt
    }
}

enum AppRoute: Hashable {
    case mission(MissionSeed)
    case order(OrderConfirmation)
    case settings
}
