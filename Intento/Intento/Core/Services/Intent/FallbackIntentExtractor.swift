import Foundation

/// Tries the primary (Gemini) extractor first. If it fails (rate limit, network, etc.),
/// falls back to the RecipeAwareMockExtractor so the app always works.
struct FallbackIntentExtractor: LLMIntentExtracting {
    let primary: LLMIntentExtracting
    let fallback: LLMIntentExtracting

    init(primary: LLMIntentExtracting, fallback: LLMIntentExtracting = RecipeAwareMockExtractor()) {
        self.primary = primary
        self.fallback = fallback
    }

    func extractIntent(from text: String) async throws -> ShoppingIntent {
        do {
            return try await primary.extractIntent(from: text)
        } catch {
            // Log for debugging but don't crash the user experience
            print("[FallbackIntentExtractor] Primary failed: \(error). Using fallback.")
            return try await fallback.extractIntent(from: text)
        }
    }
}
