import SwiftUI

enum Theme {
    nonisolated static let useCustomFonts = false

    typealias Color = AppColor
    typealias Spacing = AppSpacing
    typealias Radius = AppRadius
    typealias Shadow = AppShadow
    typealias Text = AppTextStyle

    nonisolated static let screenPadding: CGFloat = AppSpacing.lg
    nonisolated static let cardRadius: CGFloat = AppRadius.lg
    nonisolated static let controlRadius: CGFloat = AppRadius.md
}
