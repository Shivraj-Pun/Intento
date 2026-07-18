//
//  AppFont.swift
//  Intento (Ask Blinkit)
//
//  Font-family resolution. Maps the design system's three families to fonts,
//  falling back to the system font (San Francisco) until the custom fonts are
//  bundled. Flip `Theme.useCustomFonts` once the .ttf/.otf files are added to
//  the target and registered in Info.plist.
//

import SwiftUI

/// The three type families used by the design system.
enum AppFontFamily: Sendable {
    case primary     // Inter — headings / UI
    case secondary   // Roboto — body
    case mono        // JetBrains Mono — labels / code

    /// System design used when falling back to the system font.
    nonisolated var systemDesign: Font.Design {
        switch self {
        case .primary, .secondary: .default
        case .mono: .monospaced
        }
    }

    /// Best-effort PostScript name for a given weight, used only when custom
    /// fonts are enabled and bundled.
    nonisolated func postScriptName(for weight: Font.Weight) -> String? {
        switch self {
        case .primary:
            switch weight {
            case .heavy, .black: "Inter-ExtraBold"
            case .bold: "Inter-Bold"
            case .semibold: "Inter-SemiBold"
            case .medium: "Inter-Medium"
            default: "Inter-Regular"
            }
        case .secondary:
            switch weight {
            case .bold, .heavy, .black: "Roboto-Bold"
            case .semibold, .medium: "Roboto-Medium"
            default: "Roboto-Regular"
            }
        case .mono:
            switch weight {
            case .semibold, .bold, .heavy, .black: "JetBrainsMono-SemiBold"
            default: "JetBrainsMono-Regular"
            }
        }
    }
}

enum AppFont {
    /// Resolves a `Font` for a family/size/weight, honouring the custom-font
    /// toggle. Uses `.custom` (with automatic system fallback) when enabled,
    /// otherwise the system font at the requested design + weight.
    nonisolated static func font(_ family: AppFontFamily, size: CGFloat, weight: Font.Weight) -> Font {
        if Theme.useCustomFonts, let name = family.postScriptName(for: weight) {
            return .custom(name, fixedSize: size).weight(weight)
        }
        return .system(size: size, weight: weight, design: family.systemDesign)
    }
}
