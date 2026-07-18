//
//  AppRadius.swift
//  Intento (Ask Blinkit)
//
//  Corner-radius scale mirroring the CSS `--radius-*` tokens.
//

import CoreGraphics

enum AppRadius {
    nonisolated static let none: CGFloat = 0
    nonisolated static let xs: CGFloat = 2
    nonisolated static let sm: CGFloat = 4
    nonisolated static let md: CGFloat = 8
    nonisolated static let lg: CGFloat = 12
    nonisolated static let xl: CGFloat = 16
    nonisolated static let xxl: CGFloat = 24
    /// Fully rounded (pills, chips, avatars).
    nonisolated static let pill: CGFloat = 9999
}
