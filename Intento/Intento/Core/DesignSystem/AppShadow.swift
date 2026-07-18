import SwiftUI

struct AppShadowStyle: Sendable {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    nonisolated init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

enum AppShadow {
    nonisolated static let xs = AppShadowStyle(color: .black.opacity(0.08), radius: 4, y: 2)
    nonisolated static let sm = AppShadowStyle(color: .black.opacity(0.12), radius: 6, y: 3)
    nonisolated static let md = AppShadowStyle(color: .black.opacity(0.10), radius: 3, y: 4)
    nonisolated static let lg = AppShadowStyle(color: .black.opacity(0.10), radius: 7.5, y: 10)
    nonisolated static let xl = AppShadowStyle(color: .black.opacity(0.10), radius: 12.5, y: 20)
    nonisolated static let xxl = AppShadowStyle(color: .black.opacity(0.25), radius: 25, y: 25)
}

extension View {
    nonisolated func appShadow(_ style: AppShadowStyle) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}
