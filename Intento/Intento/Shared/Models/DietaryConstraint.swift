//
//  DietaryConstraint.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Dietary constraints that can be extracted from an intent and used to filter
/// or bias product selection.
enum DietaryConstraint: String, Codable, CaseIterable, Hashable, Sendable, Identifiable {
    case vegetarian
    case vegan
    case eggetarian
    case jain
    case glutenFree = "gluten_free"
    case dairyFree = "dairy_free"
    case nutFree = "nut_free"
    case halal
    case lowSugar = "low_sugar"

    nonisolated var id: String { rawValue }

    nonisolated var displayName: String {
        switch self {
        case .vegetarian: "Vegetarian"
        case .vegan: "Vegan"
        case .eggetarian: "Eggetarian"
        case .jain: "Jain"
        case .glutenFree: "Gluten-Free"
        case .dairyFree: "Dairy-Free"
        case .nutFree: "Nut-Free"
        case .halal: "Halal"
        case .lowSugar: "Low Sugar"
        }
    }
}
