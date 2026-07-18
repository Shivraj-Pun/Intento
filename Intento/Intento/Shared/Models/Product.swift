import Foundation

struct Product: Identifiable, Codable, Hashable, Sendable {

    let id: String
    let sku: String
    let name: String
    let brand: String?
    let category: ProductCategory
    let packSize: PackSize
    let price: Money

    let dietaryTags: [DietaryConstraint]

    let tags: [String]

    let servingsPerPack: Double?

    let nutritionScore: Int?

    let healthierAlternativeSKU: String?

    let isRefillAvailable: Bool

    let refillAlternativeSKU: String?

    let isReusableAlternative: Bool

    let seasonalTags: [String]

    let imageName: String?

    nonisolated init(
        sku: String,
        name: String,
        brand: String? = nil,
        category: ProductCategory,
        packSize: PackSize,
        price: Money,
        dietaryTags: [DietaryConstraint] = [],
        tags: [String] = [],
        servingsPerPack: Double? = nil,
        nutritionScore: Int? = nil,
        healthierAlternativeSKU: String? = nil,
        isRefillAvailable: Bool = false,
        refillAlternativeSKU: String? = nil,
        isReusableAlternative: Bool = false,
        seasonalTags: [String] = [],
        imageName: String? = nil
    ) {
        self.id = sku
        self.sku = sku
        self.name = name
        self.brand = brand
        self.category = category
        self.packSize = packSize
        self.price = price
        self.dietaryTags = dietaryTags
        self.tags = tags
        self.servingsPerPack = servingsPerPack
        self.nutritionScore = nutritionScore
        self.healthierAlternativeSKU = healthierAlternativeSKU
        self.isRefillAvailable = isRefillAvailable
        self.refillAlternativeSKU = refillAlternativeSKU
        self.isReusableAlternative = isReusableAlternative
        self.seasonalTags = seasonalTags
        self.imageName = imageName
    }

    nonisolated var displayTitle: String {
        if let brand, !brand.isEmpty {
            return "\(brand) \(name)"
        }
        return name
    }

    nonisolated func satisfies(_ constraints: [DietaryConstraint]) -> Bool {
        let tagSet = Set(dietaryTags)
        return constraints.allSatisfy { tagSet.contains($0) }
    }
}
