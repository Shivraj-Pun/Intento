import Foundation

enum MeasurementUnit: String, Codable, CaseIterable, Hashable, Sendable {
    case gram = "g"
    case kilogram = "kg"
    case milliliter = "ml"
    case liter = "l"
    case piece = "pc"
    case pack = "pack"
    case dozen = "dozen"
    case bunch = "bunch"

    nonisolated var shortLabel: String { rawValue }

    nonisolated var isCountable: Bool {
        switch self {
        case .piece, .pack, .dozen, .bunch: true
        case .gram, .kilogram, .milliliter, .liter: false
        }
    }
}
