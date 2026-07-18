import SwiftUI

extension Color {
    nonisolated init(hex: UInt32, opacity: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

    nonisolated init(hexString: String, opacity: Double = 1.0) {
        var string = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if string.hasPrefix("#") { string.removeFirst() }
        guard let value = UInt32(string, radix: 16), string.count == 6 else {
            self = .clear
            return
        }
        self.init(hex: value, opacity: opacity)
    }
}
