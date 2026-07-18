//
//  ShoppingIntent.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// A qualitative bucket derived from a numeric confidence score.
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

    /// Low confidence should trigger a clarifying prompt instead of guessing.
    nonisolated var shouldRequestClarification: Bool {
        self == .low
    }
}

/// One component of a compound (multi-intent) request, e.g. the "movie night"
/// portion of "movie night for 4 + weekly restock".
struct SubIntent: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var goal: String
    var occasion: Occasion?
    var peopleCount: Int?
    var confidence: Double

    init(
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

/// Structured representation of a natural-language shopping request, produced by
/// the `LLMIntentExtracting` service. Pure data model.
struct ShoppingIntent: Identifiable, Codable, Hashable, Sendable {
    let id: UUID

    /// The original user text (typed or transcribed from speech).
    var rawText: String

    /// A concise restatement of the primary goal, e.g. "Butter chicken for 4".
    var goal: String

    var peopleCount: Int?
    var budget: Money?
    var dietaryConstraints: [DietaryConstraint]
    var occasion: Occasion?

    /// Items the user already owns; excluded from the generated cart.
    var existingItems: [String]

    /// Primary shopping category, when the request is category-scoped.
    var category: ProductCategory?

    /// Duration in days for duration-based scaling (e.g. a week's restock).
    var durationDays: Int?

    /// Components of a compound request; empty for a single intent.
    var subIntents: [SubIntent]

    /// Overall extraction confidence in the range 0...1.
    var confidence: Double

    /// The inferred/stated fields surfaced as editable chips.
    var assumptions: [AssumptionField]

    let createdAt: Date

    init(
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

    /// Fields the user did not state explicitly (surfaced for confirmation).
    nonisolated var inferredAssumptions: [AssumptionField] {
        assumptions.filter(\.wasInferred)
    }
}
