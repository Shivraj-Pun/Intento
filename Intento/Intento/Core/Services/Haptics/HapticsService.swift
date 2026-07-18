import Foundation
#if canImport(UIKit)
import UIKit
#endif

struct NoopHapticsService: HapticsServicing {
    func play(_ event: HapticEvent) {}
}

struct SystemHapticsService: HapticsServicing {
    nonisolated func play(_ event: HapticEvent) {
        #if canImport(UIKit)
        Task { @MainActor in
            switch event {
            case .success, .cartGenerated:
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            case .warning:
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            case .error:
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            case .selection:
                UISelectionFeedbackGenerator().selectionChanged()
            case .chipEdit:
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case .checkout:
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
        #endif
    }
}
