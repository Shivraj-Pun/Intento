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

    var requiredItems: [String]

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
        requiredItems: [String] = [],
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
        self.requiredItems = requiredItems
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

    // MARK: - Codable (gracefully handles missing requiredItems in legacy data)

    private enum CodingKeys: String, CodingKey {
        case id, rawText, goal, peopleCount, budget, dietaryConstraints
        case occasion, existingItems, requiredItems, category, durationDays
        case subIntents, confidence, assumptions, createdAt
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        rawText = try container.decode(String.self, forKey: .rawText)
        goal = try container.decode(String.self, forKey: .goal)
        peopleCount = try container.decodeIfPresent(Int.self, forKey: .peopleCount)
        budget = try container.decodeIfPresent(Money.self, forKey: .budget)
        dietaryConstraints = try container.decodeIfPresent([DietaryConstraint].self, forKey: .dietaryConstraints) ?? []
        occasion = try container.decodeIfPresent(Occasion.self, forKey: .occasion)
        existingItems = try container.decodeIfPresent([String].self, forKey: .existingItems) ?? []
        requiredItems = try container.decodeIfPresent([String].self, forKey: .requiredItems) ?? []
        category = try container.decodeIfPresent(ProductCategory.self, forKey: .category)
        durationDays = try container.decodeIfPresent(Int.self, forKey: .durationDays)
        subIntents = try container.decodeIfPresent([SubIntent].self, forKey: .subIntents) ?? []
        confidence = try container.decodeIfPresent(Double.self, forKey: .confidence) ?? 1.0
        assumptions = try container.decodeIfPresent([AssumptionField].self, forKey: .assumptions) ?? []
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
    }
}
