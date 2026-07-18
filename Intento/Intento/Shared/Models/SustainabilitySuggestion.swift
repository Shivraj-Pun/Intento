import Foundation

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

struct SustainabilitySuggestion: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let kind: SustainabilityKind

    let originalSKU: String
    let originalName: String

    let suggestedSKU: String
    let suggestedName: String

    let message: String?

    nonisolated init(
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
