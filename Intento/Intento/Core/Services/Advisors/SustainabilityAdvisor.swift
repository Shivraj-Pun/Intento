import Foundation

struct SustainabilityAdvisor: SustainabilityAdvising {
    let catalog: ProductCatalogServicing

    init(catalog: ProductCatalogServicing) {
        self.catalog = catalog
    }

    func sustainableAlternatives(for cart: Cart) async throws -> [SustainabilitySuggestion] {
        var suggestions: [SustainabilitySuggestion] = []

        for item in cart.items {
            let product = item.product

            if product.isRefillAvailable,
               let refillSKU = product.refillAlternativeSKU,
               let refill = try await catalog.product(forSKU: refillSKU) {
                let saving = product.price - refill.price
                let message = saving.paise > 0 ? "Save \(saving.displayString) with a refill pack" : "Cut down on packaging"
                suggestions.append(SustainabilitySuggestion(
                    kind: .refillPack,
                    originalSKU: product.sku,
                    originalName: product.displayTitle,
                    suggestedSKU: refill.sku,
                    suggestedName: refill.displayTitle,
                    message: message
                ))
                continue
            }

            if !product.isReusableAlternative {
                let sameCategory = try await catalog.products(in: product.category)
                if let reusable = sameCategory.first(where: { $0.isReusableAlternative }) {
                    suggestions.append(SustainabilitySuggestion(
                        kind: .reusableAlternative,
                        originalSKU: product.sku,
                        originalName: product.displayTitle,
                        suggestedSKU: reusable.sku,
                        suggestedName: reusable.displayTitle,
                        message: "Switch to a reusable option"
                    ))
                }
            }
        }

        return suggestions
    }
}
