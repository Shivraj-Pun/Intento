//
//  ProductDTO.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Wire/JSON representation of a catalog entry. Kept separate from the domain
/// `Product`/`InventoryStatus` models so the on-disk format can evolve
/// independently. Prices are expressed in whole rupees for readability.
struct ProductDTO: Codable, Sendable {
    let sku: String
    let name: String
    let brand: String?
    let category: String
    let packValue: Double
    let packUnit: String
    let priceRupees: Double
    let stock: Int
    let etaMinutes: Int?
    let dietary: [String]?
    let tags: [String]?
    let servingsPerPack: Double?
    let nutritionScore: Int?
    let healthierAlternativeSKU: String?
    let refillAvailable: Bool?
    let refillAlternativeSKU: String?
    let reusableAlternative: Bool?
    let seasonalTags: [String]?
    let imageName: String?
}

/// Top-level JSON envelope for the bundled catalog.
struct CatalogFileDTO: Codable, Sendable {
    let products: [ProductDTO]
}

extension ProductDTO {
    /// Maps this DTO to a domain `Product`. Unknown enum raw values are skipped
    /// gracefully (unknown category → `nil`, returned to the caller).
    func toProduct() -> Product? {
        guard let category = ProductCategory(rawValue: category),
              let unit = MeasurementUnit(rawValue: packUnit) else {
            return nil
        }

        let dietaryTags = (dietary ?? []).compactMap(DietaryConstraint.init(rawValue:))

        return Product(
            sku: sku,
            name: name,
            brand: brand,
            category: category,
            packSize: PackSize(value: packValue, unit: unit),
            price: Money(rupees: priceRupees),
            dietaryTags: dietaryTags,
            tags: tags ?? [],
            servingsPerPack: servingsPerPack,
            nutritionScore: nutritionScore,
            healthierAlternativeSKU: healthierAlternativeSKU,
            isRefillAvailable: refillAvailable ?? false,
            refillAlternativeSKU: refillAlternativeSKU,
            isReusableAlternative: reusableAlternative ?? false,
            seasonalTags: seasonalTags ?? [],
            imageName: imageName
        )
    }

    /// Maps this DTO to its inventory record.
    func toInventoryStatus() -> InventoryStatus {
        InventoryStatus(sku: sku, quantityAvailable: stock, etaMinutes: etaMinutes)
    }
}
