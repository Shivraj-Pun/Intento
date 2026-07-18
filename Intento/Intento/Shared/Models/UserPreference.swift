import Foundation

struct PreferredProduct: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var category: ProductCategory
    var sku: String
    var name: String

    var frequency: Int

    nonisolated init(
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

struct UserPreference: Identifiable, Codable, Hashable, Sendable {
    let id: UUID

    var preferredProducts: [PreferredProduct]

    var dietaryConstraints: [DietaryConstraint]
    var defaultPeopleCount: Int?
    var defaultBudget: Money?
    var favoriteBrands: [String]

    var nutritionAwareEnabled: Bool

    var sustainabilityNudgesEnabled: Bool

    var restockCadenceDays: Int?

    var lastRestockAt: Date?

    var updatedAt: Date

    nonisolated init(
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

    nonisolated func preferredProduct(in category: ProductCategory) -> PreferredProduct? {
        preferredProducts
            .filter { $0.category == category }
            .max(by: { $0.frequency < $1.frequency })
    }

    nonisolated static var empty: UserPreference {
        UserPreference()
    }
}
