//
//  HapticsServicing.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Semantic haptic events used across the app so callers stay decoupled from
/// Core Haptics specifics. Injected into ViewModels/Views rather than reached
/// into as a singleton.
enum HapticEvent: String, Sendable {
    case chipEdit
    case cartGenerated
    case checkout
    case selection
    case success
    case warning
    case error
}

/// Plays semantic haptic feedback. The Phase 2 concrete implementation wraps
/// Core Haptics; a no-op implementation is used in previews and tests.
protocol HapticsServicing: Sendable {
    func play(_ event: HapticEvent)
}
