import Foundation

/// Tries the primary extractor first. If it fails (model unavailable, generation error, etc.),
/// falls back to the RecipeAwareMockExtractor so the app always works.
struct FallbackIntentExtractor: LLMIntentExtracting {
    let primary: LLMIntentExtracting
    let fallback: LLMIntentExtracting

    init(primary: LLMIntentExtracting, fallback: LLMIntentExtracting = RecipeAwareMockExtractor()) {
        self.primary = primary
        self.fallback = fallback
    }

    func extractIntent(from text: String) async throws -> ShoppingIntent {
        let primaryName = String(describing: type(of: primary))
        let fallbackName = String(describing: type(of: fallback))
        print("[Intento] 🔄 FallbackIntentExtractor — trying primary: \(primaryName)")
        do {
            let result = try await primary.extractIntent(from: text)
            print("[Intento] ✅ Primary extractor (\(primaryName)) succeeded")
            return result
        } catch {
            print("[Intento] ❌ Primary extractor (\(primaryName)) FAILED: \(error)")
            print("[Intento] 🔄 Falling back to: \(fallbackName)")
            return try await fallback.extractIntent(from: text)
        }
    }
}
