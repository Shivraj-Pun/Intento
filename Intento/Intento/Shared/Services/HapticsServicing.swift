import Foundation

enum HapticEvent: String, Sendable {
    case chipEdit
    case cartGenerated
    case checkout
    case selection
    case success
    case warning
    case error
}

protocol HapticsServicing: Sendable {
    func play(_ event: HapticEvent)
}
