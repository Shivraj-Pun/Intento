//
//  LLMIntentExtracting.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Extracts a structured `ShoppingIntent` from free-form natural language.
///
/// Concrete implementations (a live LLM client and a deterministic on-device
/// mock) are provided in Phase 2. Consumers depend only on this protocol.
protocol LLMIntentExtracting: Sendable {
    /// Parse the user's request into a structured intent, including inferred
    /// assumption chips and a confidence score.
    func extractIntent(from text: String) async throws -> ShoppingIntent
}
