import Foundation

enum DietaryConstraint: String, Codable, CaseIterable, Hashable, Sendable, Identifiable {
    case vegetarian
    case nonVegetarian = "non_vegetarian"
    case vegan
    case eggetarian

    nonisolated var id: String { rawValue }

    nonisolated var displayName: String {
        switch self {
        case .vegetarian: "Vegetarian"
        case .nonVegetarian: "Non-Vegetarian"
        case .vegan: "Vegan"
        case .eggetarian: "Eggetarian"
        }
    }
}
