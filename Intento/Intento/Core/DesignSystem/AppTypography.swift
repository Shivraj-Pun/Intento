//
//  AppTypography.swift
//  Intento (Ask Blinkit)
//
//  Type scale mirroring the CSS `--text-*` tokens. `rem` values are converted
//  to points at 16pt/rem. Each style carries family, size (phone + regular),
//  weight, line-height multiplier, letter tracking (em), and case.
//
//  Usage:  Text("Butter chicken for 4").textStyle(.headingS)
//

import SwiftUI

/// Text casing option (own type so `AppTextStyle` stays `Sendable`).
enum AppTextCase: Sendable {
    case none
    case uppercase
    case lowercase

    nonisolated var swiftUICase: Text.Case? {
        switch self {
        case .none: nil
        case .uppercase: .uppercase
        case .lowercase: .lowercase
        }
    }
}

/// A fully specified text style token.
struct AppTextStyle: Sendable {
    let family: AppFontFamily
    /// Point size used on phones (from the CSS `-mobile` value).
    let pointSize: CGFloat
    /// Point size used on regular-width layouts (iPad); reference value.
    let regularPointSize: CGFloat
    let weight: Font.Weight
    /// Line-height as a multiple of the font size (CSS `leading`).
    let lineHeight: CGFloat
    /// Letter spacing in em (CSS `tracking`).
    let tracking: CGFloat
    let textCase: AppTextCase

    nonisolated init(
        family: AppFontFamily,
        pointSize: CGFloat,
        regularPointSize: CGFloat? = nil,
        weight: Font.Weight,
        lineHeight: CGFloat,
        tracking: CGFloat = 0,
        textCase: AppTextCase = .none
    ) {
        self.family = family
        self.pointSize = pointSize
        self.regularPointSize = regularPointSize ?? pointSize
        self.weight = weight
        self.lineHeight = lineHeight
        self.tracking = tracking
        self.textCase = textCase
    }

    /// The resolved SwiftUI font (phone size).
    nonisolated var font: Font {
        AppFont.font(family, size: pointSize, weight: weight)
    }

    /// Letter spacing converted from em to points.
    nonisolated var trackingPoints: CGFloat {
        tracking * pointSize
    }

    /// Extra line spacing (SwiftUI adds spacing on top of the font's own line
    /// height, so subtract 1 from the multiplier).
    nonisolated var lineSpacing: CGFloat {
        max(0, pointSize * (lineHeight - 1))
    }
}

// MARK: - Token catalog

extension AppTextStyle {
    // Headings (Inter)
    nonisolated static let headingXXL = AppTextStyle(family: .primary, pointSize: 52, regularPointSize: 72, weight: .heavy, lineHeight: 1.0, tracking: -0.03)
    nonisolated static let headingXL = AppTextStyle(family: .primary, pointSize: 44, regularPointSize: 56, weight: .heavy, lineHeight: 1.05, tracking: -0.02)
    nonisolated static let headingL = AppTextStyle(family: .primary, pointSize: 36, regularPointSize: 44, weight: .bold, lineHeight: 1.1, tracking: -0.02)
    nonisolated static let headingM = AppTextStyle(family: .primary, pointSize: 30, regularPointSize: 36, weight: .bold, lineHeight: 1.15, tracking: -0.01)
    nonisolated static let headingS = AppTextStyle(family: .primary, pointSize: 24, regularPointSize: 28, weight: .bold, lineHeight: 1.2, tracking: -0.01)
    nonisolated static let headingXS = AppTextStyle(family: .primary, pointSize: 20, regularPointSize: 22, weight: .semibold, lineHeight: 1.3)
    nonisolated static let headingXXS = AppTextStyle(family: .primary, pointSize: 17, regularPointSize: 18, weight: .semibold, lineHeight: 1.35)

    // Body (Roboto)
    nonisolated static let bodyLRegular = AppTextStyle(family: .secondary, pointSize: 18, weight: .regular, lineHeight: 1.6)
    nonisolated static let bodyLMedium = AppTextStyle(family: .secondary, pointSize: 18, weight: .medium, lineHeight: 1.6)
    nonisolated static let bodyLBold = AppTextStyle(family: .secondary, pointSize: 18, weight: .bold, lineHeight: 1.6)
    nonisolated static let bodyMRegular = AppTextStyle(family: .secondary, pointSize: 16, weight: .regular, lineHeight: 1.65)
    nonisolated static let bodyMMedium = AppTextStyle(family: .secondary, pointSize: 16, weight: .medium, lineHeight: 1.65)
    nonisolated static let bodyMBold = AppTextStyle(family: .secondary, pointSize: 16, weight: .bold, lineHeight: 1.65)
    nonisolated static let bodySRegular = AppTextStyle(family: .secondary, pointSize: 14, weight: .regular, lineHeight: 1.55)
    nonisolated static let bodySMedium = AppTextStyle(family: .secondary, pointSize: 14, weight: .medium, lineHeight: 1.55)
    nonisolated static let bodySBold = AppTextStyle(family: .secondary, pointSize: 14, weight: .bold, lineHeight: 1.55)

    // Buttons (Roboto)
    nonisolated static let buttonL = AppTextStyle(family: .secondary, pointSize: 16, weight: .semibold, lineHeight: 1.2, tracking: 0.01)
    nonisolated static let buttonM = AppTextStyle(family: .secondary, pointSize: 14, weight: .semibold, lineHeight: 1.2, tracking: 0.01)
    nonisolated static let buttonS = AppTextStyle(family: .secondary, pointSize: 12, weight: .semibold, lineHeight: 1.2, tracking: 0.02)

    // Utility
    nonisolated static let caption = AppTextStyle(family: .secondary, pointSize: 12, weight: .regular, lineHeight: 1.45, tracking: 0.01)
    nonisolated static let label = AppTextStyle(family: .mono, pointSize: 12, weight: .semibold, lineHeight: 1.2, tracking: 0.08, textCase: .uppercase)
    nonisolated static let code = AppTextStyle(family: .mono, pointSize: 14, weight: .regular, lineHeight: 1.6)
}

// MARK: - View modifier

private struct AppTextStyleModifier: ViewModifier {
    let style: AppTextStyle

    func body(content: Content) -> some View {
        content
            .font(style.font)
            .tracking(style.trackingPoints)
            .lineSpacing(style.lineSpacing)
            .textCase(style.textCase.swiftUICase)
    }
}

extension View {
    /// Applies a design-system text style (font, tracking, line-height, case).
    nonisolated func textStyle(_ style: AppTextStyle) -> some View {
        modifier(AppTextStyleModifier(style: style))
    }
}
