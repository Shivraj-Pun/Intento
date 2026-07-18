import Foundation

struct PlannedItem: Sendable {
    let product: Product
    let score: Int
}

/// Result of mission planning — includes matched products and any items that couldn't be found in the catalog.
struct PlanResult: Sendable {
    let products: [Product]
    let unmatchedItems: [String]
}

struct MissionPlanner {
    let catalog: ProductCatalogServicing

    private let maxItems = 16
    private let maxPerCategoryForBroadMissions = 3

    init(catalog: ProductCatalogServicing) {
        self.catalog = catalog
    }

    func plan(for intent: ShoppingIntent, preference: UserPreference?) async throws -> PlanResult {
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

            let haystack = (product.name + " " + (product.brand ?? "") + " " + product.tags.joined(separator: " ")).lowercased()
            if goalTokens.contains(where: { $0.count > 2 && haystack.contains($0) }) { score += 2 }

            // Only apply preference and nutrition boosts if the product already matches the intent somewhat
            if score > 0 {
                if let preferred = preference?.preferredProduct(in: product.category), preferred.sku == product.sku {
                    score += 4
                }
                if let scoreValue = product.nutritionScore { score += scoreValue == 4 ? 1 : 0 }
            }

            if score > 0 { scored.append(PlannedItem(product: product, score: score)) }
        }

        scored.sort { lhs, rhs in
            if lhs.score != rhs.score { return lhs.score > rhs.score }
            return lhs.product.price.paise < rhs.product.price.paise
        }

        let selected = isBroadMission ? limitPerCategory(scored) : scored
        return PlanResult(products: Array(selected.prefix(maxItems).map(\.product)), unmatchedItems: [])
    }

    /// Plans the cart by matching requiredItems against the catalog using fuzzy name search.
    /// Each required item gets the best-matching product from the catalog.
    /// Items that can't be matched are collected in `unmatchedItems`.
    private func planWithRequiredItems(intent: ShoppingIntent, allProducts: [Product], preference: UserPreference?) -> PlanResult {
        var selected: [Product] = []
        var usedSKUs: Set<String> = []
        var unmatched: [String] = []
        let intentTags = tags(for: intent)

        for requiredItem in intent.requiredItems {
            let normalized = requiredItem.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            guard !normalized.isEmpty else { continue }
            
            // Check if the required item is something the user already has
            let isExisting = intent.existingItems.contains { token in
                let trimmed = token.lowercased().trimmingCharacters(in: .whitespaces)
                guard trimmed.count > 2 else { return false }
                return normalized.contains(trimmed) || trimmed.contains(normalized)
            }
            guard !isExisting else { continue }

            let tokens = normalized.split(separator: " ").map(String.init)

            // Score each product against this required item
            var bestMatch: (product: Product, score: Int)? = nil

            for product in allProducts {
                guard !usedSKUs.contains(product.sku) else { continue }
                guard passesDietary(product, constraints: intent.dietaryConstraints) else { continue }
                guard !isExistingItem(product, existing: intent.existingItems) else { continue }

                let haystack = (product.name + " " + (product.brand ?? "") + " " + product.tags.joined(separator: " ")).lowercased()

                var score = 0
                let productNameLower = product.name.lowercased()
                let productTokens = productNameLower.split(separator: " ").map(String.init)

                // Exact match (highest signal)
                if productNameLower == normalized || productNameLower == normalized + "s" {
                    score += 50
                } else if productTokens.contains(normalized) || productTokens.contains(normalized + "s") {
                    score += 20
                } else if productNameLower.contains(normalized) {
                    score += 10
                } else if normalized.contains(productNameLower) {
                    score += 8
                }

                // Token matching
                let matchedTokens = tokens.filter { token in
                    token.count > 2 && haystack.contains(token)
                }
                score += matchedTokens.count * 3

                // Penalize longer names to favor core matches over accessory items (like Masala/Paste)
                score -= productTokens.count

                // Tag exact match (very strong signal)
                if product.tags.contains(where: { $0.lowercased() == normalized || tokens.contains($0.lowercased()) }) {
                    score += 25
                }
                
                // Boost for intent context
                let overlappingContextTags = intentTags.intersection(Set(product.tags))
                score += overlappingContextTags.count * 10

                // Prefer user's preferred product
                if let preferred = preference?.preferredProduct(in: product.category), preferred.sku == product.sku {
                    score += 2
                }

                // Require a meaningful match (at least 5 points) to prevent single-token overlaps
                // like "powder" matching "coriander powder" when asking for "cocoa powder".
                if score >= 5 {
                    if bestMatch == nil || score > bestMatch!.score ||
                       (score == bestMatch!.score && product.price.paise < bestMatch!.product.price.paise) {
                        bestMatch = (product, score)
                    }
                }
            }

            if let match = bestMatch {
                selected.append(match.product)
                usedSKUs.insert(match.product.sku)
            } else {
                unmatched.append(requiredItem)
            }
        }

        return PlanResult(products: Array(selected.prefix(maxItems)), unmatchedItems: unmatched)
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
            case .vegetarian:
                if product.category == .meat { return false }
            case .nonVegetarian:
                // Non-vegetarians can eat anything, so no restriction here, 
                // but if we had strict "only meat" we would check here.
                continue
            case .eggetarian:
                if product.category == .meat { return false }
            case .vegan:
                if product.category == .meat || product.category == .dairy { return false }
                if product.dietaryTags.contains(.eggetarian) { return false }
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
