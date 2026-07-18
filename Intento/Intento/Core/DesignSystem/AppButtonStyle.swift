//
//  AppButtonStyle.swift
//  Intento (Ask Blinkit)
//
//  Reusable button styles mirroring the CSS `.btn` variants (primary, secondary,
//  ghost, danger) and sizes. Press state maps to the CSS `:active` state;
//  disabled maps to the `:disabled` state.
//
//  Usage:  Button("Checkout") { }.buttonStyle(.appPrimary)
//          Button("Cancel") { }.buttonStyle(.appGhost(size: .small))
//

import SwiftUI

enum AppButtonVariant: Sendable {
    case primary
    case secondary
    case ghost
    case danger
}

enum AppButtonSize: Sendable {
    case regular
    case small

    var textStyle: AppTextStyle {
        switch self {
        case .regular: .buttonL
        case .small: .buttonS
        }
    }
    var horizontalPadding: CGFloat {
        switch self {
        case .regular: AppSpacing.xxl   // 24
        case .small: 14
        }
    }
    var verticalPadding: CGFloat {
        switch self {
        case .regular: AppSpacing.md    // 12
        case .small: AppSpacing.sm      // 8
        }
    }
    var cornerRadius: CGFloat {
        switch self {
        case .regular: AppRadius.md     // 8
        case .small: 6
        }
    }
}

struct AppButtonStyle: ButtonStyle {
    let variant: AppButtonVariant
    var size: AppButtonSize = .regular
    /// Expands the button to the full available width.
    var fullWidth: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        StyledLabel(
            configuration: configuration,
            variant: variant,
            size: size,
            fullWidth: fullWidth
        )
    }

    private struct StyledLabel: View {
        let configuration: Configuration
        let variant: AppButtonVariant
        let size: AppButtonSize
        let fullWidth: Bool

        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            configuration.label
                .textStyle(size.textStyle)
                .lineLimit(1)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .padding(.horizontal, size.horizontalPadding)
                .padding(.vertical, size.verticalPadding)
                .foregroundStyle(foreground)
                .background(
                    RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                        .fill(background)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                        .strokeBorder(border, lineWidth: hasBorder ? 1.5 : 0)
                )
                .opacity(isEnabled ? 1 : 0.9)
                .contentShape(Rectangle())
                .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
        }

        private var isPressed: Bool { configuration.isPressed }

        private var hasBorder: Bool {
            variant == .secondary || variant == .ghost
        }

        private var background: Color {
            switch variant {
            case .primary:
                if !isEnabled { return AppColor.Primary.s200 }
                return isPressed ? AppColor.Primary.s700 : AppColor.Primary.s500
            case .secondary:
                return isPressed ? AppColor.Primary.s100 : AppColor.Primary.s50
            case .ghost:
                if isPressed { return AppColor.Primary.s100 }
                return .clear
            case .danger:
                if !isEnabled { return AppColor.Error.s200 }
                return isPressed ? AppColor.Error.s700 : AppColor.Error.s500
            }
        }

        private var foreground: Color {
            switch variant {
            case .primary:
                isEnabled ? AppColor.Semantic.onBrand : AppColor.Primary.s500
            case .secondary, .ghost:
                AppColor.Primary.s700
            case .danger:
                isEnabled ? AppColor.Semantic.textOnColor : AppColor.Error.s500
            }
        }

        private var border: Color {
            guard hasBorder else { return .clear }
            return isPressed ? AppColor.Primary.s600 : AppColor.Primary.s200
        }
    }
}

// MARK: - Convenience accessors

extension ButtonStyle where Self == AppButtonStyle {
    nonisolated static var appPrimary: AppButtonStyle { AppButtonStyle(variant: .primary) }
    nonisolated static var appSecondary: AppButtonStyle { AppButtonStyle(variant: .secondary) }
    nonisolated static var appGhost: AppButtonStyle { AppButtonStyle(variant: .ghost) }
    nonisolated static var appDanger: AppButtonStyle { AppButtonStyle(variant: .danger) }

    nonisolated static func app(
        _ variant: AppButtonVariant,
        size: AppButtonSize = .regular,
        fullWidth: Bool = false
    ) -> AppButtonStyle {
        AppButtonStyle(variant: variant, size: size, fullWidth: fullWidth)
    }
}
