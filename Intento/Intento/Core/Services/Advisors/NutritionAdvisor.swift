import Foundation

struct NutritionAdvisor: NutritionAdvising {
    let catalog: ProductCatalogServicing

    init(catalog: ProductCatalogServicing) {
        self.catalog = catalog
    }

    func healthierAlternative(for product: Product, within budget: Money?) async throws -> Product? {
        if let explicitSKU = product.healthierAlternativeSKU,
           let explicit = try await catalog.product(forSKU: explicitSKU) {
            if fits(explicit, budget: budget) { return explicit }
        }

        let sameCategory = try await catalog.products(in: product.category)
        let currentScore = product.nutritionScore ?? -1

        let candidates = sameCategory.filter { candidate in
            candidate.sku != product.sku
                && (candidate.nutritionScore ?? -1) > currentScore
                && fits(candidate, budget: budget)
        }

        return candidates.max { lhs, rhs in
            (lhs.nutritionScore ?? 0) < (rhs.nutritionScore ?? 0)
        }
    }

    private func fits(_ product: Product, budget: Money?) -> Bool {
        guard let budget else { return true }
        return product.price <= budget
    }
}
