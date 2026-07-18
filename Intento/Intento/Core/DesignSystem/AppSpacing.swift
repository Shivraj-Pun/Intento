//
//  AppSpacing.swift
//  Intento (Ask Blinkit)
//
//  Spacing scale mirroring the CSS `--space-*` tokens (1rem = 16pt).
//

import CoreGraphics

/// Consistent spacing/padding scale. Use these instead of magic numbers so
/// layout rhythm stays uniform across screens.
enum AppSpacing {
    /// 2pt — hairline gaps.
    nonisolated static let xxs: CGFloat = 2      // --space-0-5
    /// 4pt.
    nonisolated static let xs: CGFloat = 4       // --space-1
    /// 8pt.
    nonisolated static let sm: CGFloat = 8       // --space-2
    /// 12pt.
    nonisolated static let md: CGFloat = 12      // --space-3
    /// 16pt — default content padding.
    nonisolated static let lg: CGFloat = 16      // --space-4
    /// 20pt.
    nonisolated static let xl: CGFloat = 20      // --space-5
    /// 24pt.
    nonisolated static let xxl: CGFloat = 24     // --space-6
    /// 32pt.
    nonisolated static let xxxl: CGFloat = 32    // --space-8

    // Larger rhythm steps (section spacing, hero areas).
    nonisolated static let s10: CGFloat = 40     // --space-10
    nonisolated static let s12: CGFloat = 48     // --space-12
    nonisolated static let s16: CGFloat = 64     // --space-16
    nonisolated static let s20: CGFloat = 80     // --space-20
    nonisolated static let s24: CGFloat = 96     // --space-24
    nonisolated static let s32: CGFloat = 128    // --space-32
}
