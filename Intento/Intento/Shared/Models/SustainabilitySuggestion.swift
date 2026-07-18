//
//  SustainabilitySuggestion.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// The kind of eco-friendly nudge being offered.
enum SustainabilityKind: String, Codable, Hashable, Sendable {
    case refillPack = "refill_pack"
    case reusableAlternative = "reusable_alternative"
    case bulkPack = "bulk_pack"

    nonisolated var displayName: String {
        switch self {
        case .refillPack: "Refill pack"
        case .reusableAlternative: "Reusable option"
        case .bulkPack: "Bulk pack"
        }
    }
}

/// A non-blocking suggestion to swap a cart item for a more sustainable
/// alternative. Presented as a dismissible chip (Phase 2). Pure data model.
struct SustainabilitySuggestion: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let kind: SustainabilityKind

    /// The cart item this suggestion applies to.
    let originalSKU: String
    let originalName: String

    /// The suggested alternative.
    let suggestedSKU: String
    let suggestedName: String

    /// Optional short message, e.g. "Save ₹40 and one plastic pouch".
    let message: String?

    init(
        id: UUID = UUID(),
        kind: SustainabilityKind,
        originalSKU: String,
        originalName: String,
        suggestedSKU: String,
        suggestedName: String,
        message: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.originalSKU = originalSKU
        self.originalName = originalName
        self.suggestedSKU = suggestedSKU
        self.suggestedName = suggestedName
        self.message = message
    }
}
