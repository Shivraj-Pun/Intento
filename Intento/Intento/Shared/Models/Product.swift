//
//  Product.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// A purchasable catalog item (SKU). Pure data model with no UI or service
/// dependency. Inventory/stock lives in `InventoryStatus` to keep catalog and
/// availability concerns separate.
struct Product: Identifiable, Codable, Hashable, Sendable {

    /// Stable identifier. Equal to `sku`.
    let id: String
    let sku: String
    let name: String
    let brand: String?
    let category: ProductCategory
    let packSize: PackSize
    let price: Money

    /// Dietary attributes this product satisfies (e.g. vegan, gluten-free).
    let dietaryTags: [DietaryConstraint]

    /// Free-form tags used for search, matching, and rule biasing
    /// (e.g. "organic", "fresh", "party", "refill").
    let tags: [String]

    // MARK: Portion scaling support

    /// Approximate servings a single pack provides. Used by the quantity
    /// scaling engine for headcount-based scaling.
    let servingsPerPack: Double?

    // MARK: Nutrition-aware suggestions

    /// Nutrition rating from 0 (least healthy) to 4 (healthiest), maps to A–E.
    let nutritionScore: Int?

    /// SKU of a healthier product within a comparable price band, if any.
    let healthierAlternativeSKU: String?

    // MARK: Sustainability nudges

    /// Whether a refill pack exists for this product.
    let isRefillAvailable: Bool

    /// SKU of the refill-pack alternative, if any.
    let refillAlternativeSKU: String?

    /// Whether this product is itself a reusable / eco alternative.
    let isReusableAlternative: Bool

    // MARK: Seasonal / occasion intelligence

    /// Tags such as "winter", "summer", "diwali" used by the rules engine.
    let seasonalTags: [String]

    /// Asset or SF Symbol name for imagery (Phase 2 UI).
    let imageName: String?

    init(
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

    /// Convenience display title including brand when present.
    nonisolated var displayTitle: String {
        if let brand, !brand.isEmpty {
            return "\(brand) \(name)"
        }
        return name
    }

    /// Whether this product satisfies every one of the given constraints.
    nonisolated func satisfies(_ constraints: [DietaryConstraint]) -> Bool {
        let tagSet = Set(dietaryTags)
        return constraints.allSatisfy { tagSet.contains($0) }
    }
}
