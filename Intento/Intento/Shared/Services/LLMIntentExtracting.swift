import Foundation

protocol LLMIntentExtracting: Sendable {
    func extractIntent(from text: String) async throws -> ShoppingIntent
}
