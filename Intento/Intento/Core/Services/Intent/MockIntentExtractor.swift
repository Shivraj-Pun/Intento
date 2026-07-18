import Foundation

struct MockIntentExtractor: LLMIntentExtracting {
    func extractIntent(from text: String) async throws -> ShoppingIntent {
        try await Task.sleep(nanoseconds: 250_000_000)
        return IntentBuilder.build(from: text)
    }
}
