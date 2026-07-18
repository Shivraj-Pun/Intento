import Foundation
import FoundationModels

// MARK: - Generable Schema for Guided Generation

/// Schema used by Apple Foundation Models' guided generation to produce structured output.
/// The `@Generable` macro ensures the on-device LLM returns a typed Swift struct
/// that matches this shape — no JSON parsing required.
@available(iOS 26.0, macOS 26.0, *)
@Generable
struct ExtractedIntentSchema: Sendable {
    @Guide(description: "The user's shopping goal summarized clearly")
    var goal: String

    @Guide(description: "Number of people to shop for, or nil if not mentioned")
    var peopleCount: Int?

    @Guide(description: "Budget in Indian Rupees, or nil if not mentioned")
    var budgetRupees: Int?

    @Guide(description: "Dietary constraints from: vegetarian, vegan, eggetarian, jain, gluten_free, dairy_free, nut_free, halal, low_sugar")
    var dietary: [String]

    @Guide(description: "Shopping occasion, one of: everyday, weekly_restock, breakfast, dinner_party, movie_night, birthday, festival, guests_over, baby_care, illness, picnic, cleaning")
    var occasion: String?

    @Guide(description: "Duration in days the shopping should cover, or nil")
    var durationDays: Int?

    @Guide(description: "Items the user already has at home")
    var existingItems: [String]

    @Guide(description: "Specific products or ingredients needed. For recipes list ALL ingredients. Always include at least 3 items.")
    var requiredItems: [String]

    @Guide(description: "Product category from: produce, dairy, meat, bakery, pantry, snacks, beverages, cleaning, party_supplies, baby, first_aid, personal_care, frozen, household")
    var category: String?

    @Guide(description: "Confidence score between 0.0 and 1.0 indicating extraction quality")
    var confidence: Double
}

// MARK: - Apple Foundation Model Intent Extractor

/// Extracts structured shopping intent using Apple's on-device Foundation Models.
/// Runs entirely on-device with zero network dependency, zero token cost, and full privacy.
///
/// Conforms to `LLMIntentExtracting` so it can be swapped in wherever Gemini was used.
/// Requires iOS 26+ and Apple Intelligence-capable hardware (iPhone 15 Pro+, M-series).
@available(iOS 26.0, macOS 26.0, *)
struct AppleFoundationModelIntentExtractor: LLMIntentExtracting {

    // MARK: - LLMIntentExtracting

    func extractIntent(from text: String) async throws -> ShoppingIntent {
        print("[Intento] 🍎 AppleFoundationModelIntentExtractor — starting extraction for: \"\(text)\"")
        let session = LanguageModelSession(instructions: Self.systemInstructions)

        let response = try await session.respond(
            to: Self.userPrompt(for: text),
            generating: ExtractedIntentSchema.self
        )

        let intent = Self.mapToShoppingIntent(schema: response.content, rawText: text)
        print("[Intento] 🍎 AppleFoundationModelIntentExtractor — SUCCESS")
        print("[Intento]    Goal: \(intent.goal)")
        print("[Intento]    RequiredItems: \(intent.requiredItems)")
        print("[Intento]    Occasion: \(intent.occasion?.displayName ?? "nil")")
        print("[Intento]    PeopleCount: \(intent.peopleCount ?? -1)")
        print("[Intento]    Confidence: \(intent.confidence)")
        return intent
    }

    // MARK: - Prompt Configuration

    private static let systemInstructions = """
        You are a shopping intent extractor for an Indian grocery delivery app called Intento.
        You extract structured data from natural language shopping requests.

        CRITICAL RULES FOR requiredItems:
        - For Indian recipes/dishes: list EVERY SINGLE ingredient needed to cook the dish from scratch.
          Example: "dal makhani" needs urad dal, rajma, butter, cream, tomatoes, onion, ginger, garlic, \
          green chillies, kasuri methi, garam masala, red chilli powder, turmeric, cumin seeds, bay leaf, salt, oil.
          Example: "paneer butter masala" needs paneer, butter, cream, tomatoes, onion, cashews, garlic, \
          ginger, green chillies, kasuri methi, garam masala, red chilli powder, turmeric, cumin, sugar, salt, oil.
          Example: "biryani" needs basmati rice, chicken/mutton, onion, yogurt, tomatoes, ginger-garlic paste, \
          green chillies, mint leaves, coriander leaves, biryani masala, bay leaf, cardamom, cloves, cinnamon, \
          star anise, saffron, milk, ghee, salt, oil.
        - MINIMUM 8 ingredients for any recipe. Most Indian dishes need 12-18 ingredients.
        - For category requests (e.g. "cleaning kit"): list at least 5 specific products.
        - For general shopping: list specific items the user would need.
        - Use simple, common Indian grocery store product names (e.g. "urad dal" not "black gram").
        - Include spices, oils, and garnishes — not just main ingredients.

        OTHER RULES:
        - Infer sensible defaults when values are not explicitly stated, and lower confidence accordingly.
        - Set confidence to 1.0 only when ALL fields are explicitly stated by the user.
        - If the user mentions a recipe name, set the goal to the recipe name clearly.
        - For Indian food, default occasion to "everyday" unless context suggests otherwise.
        """

    private static func userPrompt(for text: String) -> String {
        "Extract shopping intent from this request: \"\(text)\""
    }

    // MARK: - Mapping

    /// Maps the Foundation Models `@Generable` output to the app's `ShoppingIntent` domain model.
    private static func mapToShoppingIntent(schema: ExtractedIntentSchema, rawText: String) -> ShoppingIntent {
        let fields = ParsedIntentFields(
            goal: schema.goal.trimmingCharacters(in: .whitespacesAndNewlines),
            peopleCount: schema.peopleCount,
            budgetRupees: schema.budgetRupees,
            dietary: schema.dietary.compactMap { DietaryConstraint(rawValue: $0) },
            occasion: schema.occasion.flatMap { Occasion(rawValue: $0) },
            durationDays: schema.durationDays,
            existingItems: schema.existingItems,
            requiredItems: schema.requiredItems,
            category: schema.category.flatMap { ProductCategory(rawValue: $0) },
            confidenceOverride: schema.confidence
        )

        let fragments = IntentHeuristics.splitSubIntents(in: rawText)
        let subIntents: [SubIntent] = fragments.count > 1
            ? fragments.map { SubIntent(goal: $0) }
            : []

        return IntentBuilder.assemble(rawText: rawText, fields: fields, subIntents: subIntents)
    }
}

// MARK: - Availability Helper

/// Checks whether Apple Foundation Models are available on the current device.
/// Use this to decide at runtime whether to use on-device extraction or fall back.
enum AppleFoundationModelAvailability {
    /// Returns `true` if the device supports Apple Foundation Models at runtime.
    static var isAvailable: Bool {
        guard #available(iOS 26.0, macOS 26.0, *) else {
            print("[Intento] 🍎 Availability: OS version too low (requires iOS 26+)")
            return false
        }
        return checkModelAvailability()
    }

    @available(iOS 26.0, macOS 26.0, *)
    private static func checkModelAvailability() -> Bool {
        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            print("[Intento] 🍎 Availability: SystemLanguageModel is AVAILABLE")
            return true
        default:
            print("[Intento] 🍎 Availability: SystemLanguageModel is NOT available — status: \(model.availability)")
            return false
        }
    }
}
