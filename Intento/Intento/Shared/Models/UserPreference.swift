//
//  UserPreference.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// A product the user habitually buys within a category, powering suggestions
/// like "You usually buy the 2 L milk pack".
struct PreferredProduct: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var category: ProductCategory
    var sku: String
    var name: String

    /// How many past missions included this product (used for ranking).
    var frequency: Int

    init(
        id: UUID = UUID(),
        category: ProductCategory,
        sku: String,
        name: String,
        frequency: Int = 1
    ) {
        self.id = id
        self.category = category
        self.sku = sku
        self.name = name
        self.frequency = frequency
    }
}

/// Locally-persisted user preferences learned from past missions plus explicit
/// toggles. Pure `Codable` domain model (persistence mapping done in Phase 2).
struct UserPreference: Identifiable, Codable, Hashable, Sendable {
    let id: UUID

    /// Products the user tends to prefer, keyed by category via `category`.
    var preferredProducts: [PreferredProduct]

    var dietaryConstraints: [DietaryConstraint]
    var defaultPeopleCount: Int?
    var defaultBudget: Money?
    var favoriteBrands: [String]

    // MARK: Feature toggles

    /// Nutrition-aware healthier-swap suggestions. Off by default per spec.
    var nutritionAwareEnabled: Bool

    /// Non-blocking sustainability nudges (refill/reusable).
    var sustainabilityNudgesEnabled: Bool

    /// Cadence in days for restock reminders (e.g. 7 for "Sunday Restock").
    var restockCadenceDays: Int?

    /// When the last restock mission ran, used to time restock nudges.
    var lastRestockAt: Date?

    var updatedAt: Date

    init(
        id: UUID = UUID(),
        preferredProducts: [PreferredProduct] = [],
        dietaryConstraints: [DietaryConstraint] = [],
        defaultPeopleCount: Int? = nil,
        defaultBudget: Money? = nil,
        favoriteBrands: [String] = [],
        nutritionAwareEnabled: Bool = false,
        sustainabilityNudgesEnabled: Bool = true,
        restockCadenceDays: Int? = nil,
        lastRestockAt: Date? = nil,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.preferredProducts = preferredProducts
        self.dietaryConstraints = dietaryConstraints
        self.defaultPeopleCount = defaultPeopleCount
        self.defaultBudget = defaultBudget
        self.favoriteBrands = favoriteBrands
        self.nutritionAwareEnabled = nutritionAwareEnabled
        self.sustainabilityNudgesEnabled = sustainabilityNudgesEnabled
        self.restockCadenceDays = restockCadenceDays
        self.lastRestockAt = lastRestockAt
        self.updatedAt = updatedAt
    }

    /// The user's preferred product for a category, if one is remembered.
    nonisolated func preferredProduct(in category: ProductCategory) -> PreferredProduct? {
        preferredProducts
            .filter { $0.category == category }
            .max(by: { $0.frequency < $1.frequency })
    }

    /// A neutral default used on first launch before any learning has occurred.
    nonisolated static var empty: UserPreference {
        UserPreference()
    }
}
