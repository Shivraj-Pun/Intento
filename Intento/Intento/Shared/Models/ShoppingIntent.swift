import Foundation

enum ConfidenceLevel: String, Codable, Hashable, Sendable {
    case low
    case medium
    case high

    nonisolated init(score: Double) {
        switch score {
        case ..<0.5: self = .low
        case ..<0.8: self = .medium
        default: self = .high
        }
    }

    nonisolated var displayName: String {
        switch self {
        case .low: "Low confidence"
        case .medium: "Fairly confident"
        case .high: "High confidence"
        }
    }

    nonisolated var shouldRequestClarification: Bool {
        self == .low
    }
}

struct SubIntent: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var goal: String
    var occasion: Occasion?
    var peopleCount: Int?
    var confidence: Double

    nonisolated init(
        id: UUID = UUID(),
        goal: String,
        occasion: Occasion? = nil,
        peopleCount: Int? = nil,
        confidence: Double = 1.0
    ) {
        self.id = id
        self.goal = goal
        self.occasion = occasion
        self.peopleCount = peopleCount
        self.confidence = confidence
    }
}

struct ShoppingIntent: Identifiable, Codable, Hashable, Sendable {
    let id: UUID

    var rawText: String

    var goal: String

    var peopleCount: Int?
    var budget: Money?
    var dietaryConstraints: [DietaryConstraint]
    var occasion: Occasion?

    var existingItems: [String]

    var category: ProductCategory?

    var durationDays: Int?

    var subIntents: [SubIntent]

    var confidence: Double

    var assumptions: [AssumptionField]

    let createdAt: Date

    nonisolated init(
        id: UUID = UUID(),
        rawText: String,
        goal: String,
        peopleCount: Int? = nil,
        budget: Money? = nil,
        dietaryConstraints: [DietaryConstraint] = [],
        occasion: Occasion? = nil,
        existingItems: [String] = [],
        category: ProductCategory? = nil,
        durationDays: Int? = nil,
        subIntents: [SubIntent] = [],
        confidence: Double = 1.0,
        assumptions: [AssumptionField] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.rawText = rawText
        self.goal = goal
        self.peopleCount = peopleCount
        self.budget = budget
        self.dietaryConstraints = dietaryConstraints
        self.occasion = occasion
        self.existingItems = existingItems
        self.category = category
        self.durationDays = durationDays
        self.subIntents = subIntents
        self.confidence = confidence
        self.assumptions = assumptions
        self.createdAt = createdAt
    }

    nonisolated var confidenceLevel: ConfidenceLevel {
        ConfidenceLevel(score: confidence)
    }

    nonisolated var isMultiIntent: Bool {
        subIntents.count > 1
    }

    nonisolated var inferredAssumptions: [AssumptionField] {
        assumptions.filter(\.wasInferred)
    }
}
