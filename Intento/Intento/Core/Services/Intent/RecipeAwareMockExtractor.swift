import Foundation

/// A mock intent extractor that simulates LLM responses for 6 pre-fed queries.
/// Used when no API key is configured — demonstrates the full flow with realistic data.
/// Falls back to the heuristic IntentBuilder for unrecognized inputs.
struct RecipeAwareMockExtractor: LLMIntentExtracting {

    func extractIntent(from text: String) async throws -> ShoppingIntent {
        // Simulate network latency
        try await Task.sleep(nanoseconds: 400_000_000)

        if let matched = matchPreFedRecipe(text) {
            return matched
        }

        // Fallback: use on-device heuristic parser
        return IntentBuilder.build(from: text)
    }

    // MARK: - Pre-fed Recipe Matching

    private func matchPreFedRecipe(_ text: String) -> ShoppingIntent? {
        let lower = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        for recipe in Self.preFedRecipes {
            for keyword in recipe.keywords {
                if lower.contains(keyword) {
                    return buildIntent(from: recipe, rawText: text, inputText: lower)
                }
            }
        }
        return nil
    }

    private func buildIntent(from recipe: PreFedRecipe, rawText: String, inputText: String) -> ShoppingIntent {
        let peopleCount = IntentHeuristics.detectPeopleCount(in: inputText) ?? recipe.defaultPeople
        let budget = IntentHeuristics.detectBudget(in: inputText)

        let fields = ParsedIntentFields(
            goal: recipe.goal,
            peopleCount: peopleCount,
            budgetRupees: budget,
            dietary: recipe.dietary,
            occasion: recipe.occasion,
            durationDays: nil,
            existingItems: IntentHeuristics.detectExistingItems(in: inputText),
            requiredItems: recipe.requiredItems,
            category: recipe.category,
            confidenceOverride: recipe.confidence
        )

        return IntentBuilder.assemble(rawText: rawText, fields: fields, subIntents: [])
    }

    // MARK: - Pre-fed Data

    private struct PreFedRecipe {
        let keywords: [String]
        let goal: String
        let requiredItems: [String]
        let occasion: Occasion?
        let category: ProductCategory?
        let dietary: [DietaryConstraint]
        let defaultPeople: Int
        let confidence: Double
    }

    private static let preFedRecipes: [PreFedRecipe] = [
        // 1. Shahi Paneer
        PreFedRecipe(
            keywords: ["shahi paneer"],
            goal: "Shahi Paneer",
            requiredItems: [
                "paneer", "cream", "cashew", "tomato", "onion",
                "ginger", "garlic", "garam masala", "turmeric",
                "kashmiri chilli", "cardamom", "cloves", "cinnamon",
                "bay leaves", "curd", "oil", "salt", "coriander"
            ],
            occasion: .dinnerParty,
            category: nil,
            dietary: [.vegetarian],
            defaultPeople: 3,
            confidence: 0.92
        ),

        // 2. White Sauce Pasta
        PreFedRecipe(
            keywords: ["white sauce pasta", "white pasta", "alfredo"],
            goal: "White Sauce Pasta",
            requiredItems: [
                "penne pasta", "butter", "flour", "milk", "cheese",
                "garlic", "black pepper", "cream", "salt", "olive oil",
                "oregano", "mixed herbs", "mushroom", "capsicum", "corn"
            ],
            occasion: .everyday,
            category: nil,
            dietary: [.vegetarian],
            defaultPeople: 2,
            confidence: 0.95
        ),

        // 3. Butter Chicken
        PreFedRecipe(
            keywords: ["butter chicken"],
            goal: "Butter Chicken",
            requiredItems: [
                "chicken boneless", "butter", "cream", "tomato",
                "onion", "ginger", "garlic", "garam masala",
                "kashmiri chilli", "turmeric", "curd", "salt",
                "oil", "cardamom", "naan", "coriander"
            ],
            occasion: .dinnerParty,
            category: nil,
            dietary: [],
            defaultPeople: 4,
            confidence: 0.94
        ),

        // 4. House Cleaning Kit
        PreFedRecipe(
            keywords: ["cleaning kit", "house cleaning", "deep clean", "cleaning supplies"],
            goal: "House Cleaning Kit",
            requiredItems: [
                "floor cleaner", "toilet cleaner", "dishwash",
                "glass cleaner", "scrub pad", "garbage bags",
                "detergent", "handwash"
            ],
            occasion: .cleaning,
            category: .cleaning,
            dietary: [],
            defaultPeople: 1,
            confidence: 0.96
        ),

        // 5. Movie Night
        PreFedRecipe(
            keywords: ["movie night", "movie snacks", "netflix"],
            goal: "Movie Night Snacks",
            requiredItems: [
                "popcorn", "nachos", "salsa", "coca-cola",
                "chocolate", "chips", "pepsi"
            ],
            occasion: .movieNight,
            category: nil,
            dietary: [.vegetarian],
            defaultPeople: 4,
            confidence: 0.93
        ),

        // 6. Healthy Breakfast
        PreFedRecipe(
            keywords: ["healthy breakfast", "breakfast for"],
            goal: "Healthy Breakfast",
            requiredItems: [
                "oats", "banana", "milk", "eggs", "brown bread",
                "honey", "greek yogurt", "green tea", "peanut butter"
            ],
            occasion: .breakfast,
            category: nil,
            dietary: [.vegetarian],
            defaultPeople: 2,
            confidence: 0.91
        )
    ]
}
