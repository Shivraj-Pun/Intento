import SwiftUI

enum AppFontFamily: Sendable {
    case primary
    case secondary
    case mono

    nonisolated var systemDesign: Font.Design {
        switch self {
        case .primary, .secondary: .default
        case .mono: .monospaced
        }
    }

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
    nonisolated static func font(_ family: AppFontFamily, size: CGFloat, weight: Font.Weight) -> Font {
        if Theme.useCustomFonts, let name = family.postScriptName(for: weight) {
            return .custom(name, fixedSize: size).weight(weight)
        }
        return .system(size: size, weight: weight, design: family.systemDesign)
    }
}
