import Foundation

enum SubstitutionReason: String, Codable, Hashable, Sendable {
    case outOfStock = "out_of_stock"
    case lowStock = "low_stock"
    case budget
    case healthierSwap = "healthier_swap"
    case sustainabilityRefill = "sustainability_refill"

    nonisolated var displayName: String {
        switch self {
        case .outOfStock: "Out of stock"
        case .lowStock: "Low stock"
        case .budget: "Cheaper option"
        case .healthierSwap: "Healthier swap"
        case .sustainabilityRefill: "Eco refill"
        }
    }
}

struct SubstitutionRecord: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let originalSKU: String
    let originalName: String
    let substituteSKU: String
    let substituteName: String
    let reason: SubstitutionReason

    var isAccepted: Bool
    let createdAt: Date

    nonisolated init(
        id: UUID = UUID(),
        originalSKU: String,
        originalName: String,
        substituteSKU: String,
        substituteName: String,
        reason: SubstitutionReason,
        isAccepted: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.originalSKU = originalSKU
        self.originalName = originalName
        self.substituteSKU = substituteSKU
        self.substituteName = substituteName
        self.reason = reason
        self.isAccepted = isAccepted
        self.createdAt = createdAt
    }
}
