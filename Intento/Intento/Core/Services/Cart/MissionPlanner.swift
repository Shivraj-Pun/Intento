import Foundation

struct PlannedItem: Sendable {
    let product: Product
    let score: Int
}

struct MissionPlanner {
    let catalog: ProductCatalogServicing

    private let maxItems = 16
    private let maxPerCategoryForBroadMissions = 3

    init(catalog: ProductCatalogServicing) {
        self.catalog = catalog
    }

    func plan(for intent: ShoppingIntent, preference: UserPreference?) async throws -> [Product] {
        let all = try await catalog.allProducts()

        // If requiredItems are provided (from LLM or mock), prioritize direct matching
        if !intent.requiredItems.isEmpty {
            return planWithRequiredItems(intent: intent, allProducts: all, preference: preference)
        }

        let desiredTags = tags(for: intent)
        let desiredCategories = categories(for: intent)
        let goalTokens = intent.goal.lowercased().split(separator: " ").map(String.init)
        let isBroadMission = desiredTags.isEmpty && !desiredCategories.isEmpty

        var scored: [PlannedItem] = []
        for product in all {
            guard passesDietary(product, constraints: intent.dietaryConstraints) else { continue }
            guard !isExistingItem(product, existing: intent.existingItems) else { continue }

            var score = 0
            let productTags = Set(product.tags)
            score += desiredTags.intersection(productTags).count * 3
            if desiredCategories.contains(product.category) { score += 2 }

            let haystack = (product.name + " " + (product.brand ?? "")).lowercased()
            if goalTokens.contains(where: { $0.count > 2 && haystack.contains($0) }) { score += 2 }

            if let preferred = preference?.preferredProduct(in: product.category), preferred.sku == product.sku {
                score += 4
            }
            if let scoreValue = product.nutritionScore { score += scoreValue == 4 ? 1 : 0 }

            if score > 0 { scored.append(PlannedItem(product: product, score: score)) }
        }

        scored.sort { lhs, rhs in
            if lhs.score != rhs.score { return lhs.score > rhs.score }
            return lhs.product.price.paise < rhs.product.price.paise
        }

        let selected = isBroadMission ? limitPerCategory(scored) : scored
        return Array(selected.prefix(maxItems).map(\.product))
    }

    /// Plans the cart by matching requiredItems against the catalog using fuzzy name search.
    /// Each required item gets the best-matching product from the catalog.
    private func planWithRequiredItems(intent: ShoppingIntent, allProducts: [Product], preference: UserPreference?) -> [Product] {
        var selected: [Product] = []
        var usedSKUs: Set<String> = []

        for requiredItem in intent.requiredItems {
            let normalized = requiredItem.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            guard !normalized.isEmpty else { continue }

            let tokens = normalized.split(separator: " ").map(String.init)

            // Score each product against this required item
            var bestMatch: (product: Product, score: Int)? = nil

            for product in allProducts {
                guard !usedSKUs.contains(product.sku) else { continue }
                guard passesDietary(product, constraints: intent.dietaryConstraints) else { continue }
                guard !isExistingItem(product, existing: intent.existingItems) else { continue }

                let haystack = (product.name + " " + (product.brand ?? "") + " " + product.tags.joined(separator: " ")).lowercased()

                var score = 0

                // Exact name containment (highest signal)
                if product.name.lowercased().contains(normalized) {
                    score += 10
                } else if normalized.contains(product.name.lowercased()) {
                    score += 8
                }

                // Token matching
                let matchedTokens = tokens.filter { token in
                    token.count > 2 && haystack.contains(token)
                }
                score += matchedTokens.count * 3

                // Tag exact match
                if product.tags.contains(where: { $0.lowercased() == normalized || tokens.contains($0.lowercased()) }) {
                    score += 5
                }

                // Prefer user's preferred product
                if let preferred = preference?.preferredProduct(in: product.category), preferred.sku == product.sku {
                    score += 2
                }

                if score > 0 {
                    if bestMatch == nil || score > bestMatch!.score ||
                       (score == bestMatch!.score && product.price.paise < bestMatch!.product.price.paise) {
                        bestMatch = (product, score)
                    }
                }
            }

            if let match = bestMatch {
                selected.append(match.product)
                usedSKUs.insert(match.product.sku)
            }
        }

        return Array(selected.prefix(maxItems))
    }

    private func limitPerCategory(_ items: [PlannedItem]) -> [PlannedItem] {
        var counts: [ProductCategory: Int] = [:]
        var result: [PlannedItem] = []
        for item in items {
            let count = counts[item.product.category, default: 0]
            if count < maxPerCategoryForBroadMissions {
                counts[item.product.category] = count + 1
                result.append(item)
            }
        }
        return result
    }

    private func tags(for intent: ShoppingIntent) -> Set<String> {
        var result: Set<String> = []
        if let occasion = intent.occasion, let occasionTags = MissionCatalogTags.occasionTags[occasion] {
            result.formUnion(occasionTags)
        }
        let goal = intent.goal.lowercased()
        for (keyword, keywordTags) in MissionCatalogTags.goalKeywordTags where goal.contains(keyword) {
            result.formUnion(keywordTags)
        }
        for sub in intent.subIntents {
            let subGoal = sub.goal.lowercased()
            for (keyword, keywordTags) in MissionCatalogTags.goalKeywordTags where subGoal.contains(keyword) {
                result.formUnion(keywordTags)
            }
            if let occasion = sub.occasion, let occasionTags = MissionCatalogTags.occasionTags[occasion] {
                result.formUnion(occasionTags)
            }
        }
        return result
    }

    private func categories(for intent: ShoppingIntent) -> Set<ProductCategory> {
        var result: Set<ProductCategory> = []
        if let category = intent.category { result.insert(category) }
        if let occasion = intent.occasion, let cats = MissionCatalogTags.occasionCategories[occasion] {
            result.formUnion(cats)
        }
        let goal = intent.goal.lowercased()
        for (keyword, cats) in MissionCatalogTags.goalKeywordCategories where goal.contains(keyword) {
            result.formUnion(cats)
        }
        for sub in intent.subIntents {
            if let occasion = sub.occasion, let cats = MissionCatalogTags.occasionCategories[occasion] {
                result.formUnion(cats)
            }
        }
        return result
    }

    private func passesDietary(_ product: Product, constraints: [DietaryConstraint]) -> Bool {
        guard !constraints.isEmpty else { return true }
        let exemptCategories: Set<ProductCategory> = [.cleaning, .baby, .firstAid, .personalCare, .household]
        if exemptCategories.contains(product.category) { return true }

        for constraint in constraints {
            switch constraint {
            case .vegetarian, .jain:
                if product.category == .meat { return false }
            case .eggetarian:
                if product.category == .meat { return false }
            case .vegan:
                if product.category == .meat || product.category == .dairy { return false }
                if product.dietaryTags.contains(.eggetarian) { return false }
            case .glutenFree, .dairyFree, .nutFree, .lowSugar, .halal:
                continue
            }
        }
        return true
    }

    private func isExistingItem(_ product: Product, existing: [String]) -> Bool {
        guard !existing.isEmpty else { return false }
        let name = product.name.lowercased()
        return existing.contains { token in
            let trimmed = token.lowercased().trimmingCharacters(in: .whitespaces)
            guard trimmed.count > 2 else { return false }
            return name.contains(trimmed) || trimmed.contains(name)
        }
    }
}
