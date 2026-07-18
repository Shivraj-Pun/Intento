import Foundation

struct SupabaseProductDTO: Decodable, Sendable {
    let sku: String
    let name: String
    let brand: String?
    let category: String
    let pack_value: Double
    let pack_unit: String
    let price_paise: Int
    let dietary_tags: [String]?
    let tags: [String]?
    let seasonal_tags: [String]?
    let servings_per_pack: Double?
    let nutrition_score: Int?
    let healthier_alternative_sku: String?
    let is_refill_available: Bool
    let refill_alternative_sku: String?
    let is_reusable_alternative: Bool
    let image_name: String?
    let quantity_available: Int
    
    // Convert to the app's Product model
    func toProduct() -> Product? {
        guard let cat = ProductCategory(rawValue: category),
              let unit = MeasurementUnit(rawValue: pack_unit) else {
            return nil
        }
        
        let dietary = (dietary_tags ?? []).compactMap(DietaryConstraint.init(rawValue:))
        
        return Product(
            sku: sku,
            name: name,
            brand: brand,
            category: cat,
            packSize: PackSize(value: pack_value, unit: unit),
            price: Money(paise: price_paise),
            dietaryTags: dietary,
            tags: tags ?? [],
            servingsPerPack: servings_per_pack,
            nutritionScore: nutrition_score,
            healthierAlternativeSKU: healthier_alternative_sku,
            isRefillAvailable: is_refill_available,
            refillAlternativeSKU: refill_alternative_sku,
            isReusableAlternative: is_reusable_alternative,
            seasonalTags: seasonal_tags ?? [],
            imageName: image_name
        )
    }
}
