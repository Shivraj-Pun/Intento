//
//  Theme.swift
//  Intento (Ask Blinkit)
//
//  Umbrella entry point for the design system. Groups the token namespaces and
//  holds global theme switches. Pure design tokens — no business logic.
//

import SwiftUI

/// Central design-system namespace.
///
/// Prefer the specific token types directly in feature code (`AppColor`,
/// `AppSpacing`, `AppTextStyle`, `AppRadius`, `AppShadow`); `Theme` exists to
/// document the system and hold global switches.
enum Theme {
    /// Set to `true` once Inter / Roboto / JetBrains Mono are bundled into the
    /// target and declared under `UIAppFonts` in Info.plist. Until then the
    /// system font (San Francisco) is used at the correct sizes and weights.
    nonisolated static let useCustomFonts = false

    typealias Color = AppColor
    typealias Spacing = AppSpacing
    typealias Radius = AppRadius
    typealias Shadow = AppShadow
    typealias Text = AppTextStyle

    /// Standard screen edge padding.
    nonisolated static let screenPadding: CGFloat = AppSpacing.lg
    /// Default card corner radius.
    nonisolated static let cardRadius: CGFloat = AppRadius.lg
    /// Default control (button/field) corner radius.
    nonisolated static let controlRadius: CGFloat = AppRadius.md
}
