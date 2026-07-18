//
//  ProductCategory.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Top-level product categories used to group the catalog, drive scaling rules,
/// and organise the cart screen.
enum ProductCategory: String, Codable, CaseIterable, Hashable, Sendable, Identifiable {
    case produce
    case dairy
    case meat
    case bakery
    case pantry
    case snacks
    case beverages
    case cleaning
    case partySupplies = "party_supplies"
    case baby
    case firstAid = "first_aid"
    case personalCare = "personal_care"
    case frozen
    case household

    nonisolated var id: String { rawValue }

    nonisolated var displayName: String {
        switch self {
        case .produce: "Fruits & Vegetables"
        case .dairy: "Dairy & Eggs"
        case .meat: "Meat & Seafood"
        case .bakery: "Bakery"
        case .pantry: "Pantry & Staples"
        case .snacks: "Snacks"
        case .beverages: "Beverages"
        case .cleaning: "Cleaning"
        case .partySupplies: "Party Supplies"
        case .baby: "Baby Care"
        case .firstAid: "First Aid"
        case .personalCare: "Personal Care"
        case .frozen: "Frozen"
        case .household: "Household"
        }
    }

    /// SF Symbol name used across the UI (Phase 2).
    nonisolated var iconName: String {
        switch self {
        case .produce: "carrot.fill"
        case .dairy: "carton.fill"
        case .meat: "fish.fill"
        case .bakery: "birthday.cake.fill"
        case .pantry: "bag.fill"
        case .snacks: "popcorn.fill"
        case .beverages: "cup.and.saucer.fill"
        case .cleaning: "bubbles.and.sparkles.fill"
        case .partySupplies: "party.popper.fill"
        case .baby: "figure.and.child.holdinghands"
        case .firstAid: "cross.case.fill"
        case .personalCare: "comb.fill"
        case .frozen: "snowflake"
        case .household: "house.fill"
        }
    }

    /// Display order used when grouping the cart by category.
    nonisolated var sortOrder: Int {
        ProductCategory.allCases.firstIndex(of: self) ?? 0
    }
}
