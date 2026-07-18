import Foundation

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

struct CatalogFileDTO: Codable, Sendable {
    let products: [ProductDTO]
}

extension ProductDTO {
    nonisolated func toProduct() -> Product? {
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

    nonisolated func toInventoryStatus() -> InventoryStatus {
        InventoryStatus(sku: sku, quantityAvailable: stock, etaMinutes: etaMinutes)
    }
}
