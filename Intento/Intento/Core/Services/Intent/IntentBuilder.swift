import Foundation

struct ParsedIntentFields: Sendable {
    var goal: String
    var peopleCount: Int?
    var budgetRupees: Int?
    var dietary: [DietaryConstraint]
    var occasion: Occasion?
    var durationDays: Int?
    var existingItems: [String]
    var category: ProductCategory?
    var confidenceOverride: Double?
}

enum IntentBuilder {

    static let defaultPeopleCount = 2

    static func detectFields(from text: String) -> ParsedIntentFields {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let occasion = IntentHeuristics.detectOccasion(in: trimmed)
        return ParsedIntentFields(
            goal: cleanGoal(trimmed),
            peopleCount: IntentHeuristics.detectPeopleCount(in: trimmed),
            budgetRupees: IntentHeuristics.detectBudget(in: trimmed),
            dietary: IntentHeuristics.detectDietary(in: trimmed),
            occasion: occasion,
            durationDays: IntentHeuristics.detectDurationDays(in: trimmed),
            existingItems: IntentHeuristics.detectExistingItems(in: trimmed),
            category: category(for: occasion),
            confidenceOverride: nil
        )
    }

    static func build(from text: String) -> ShoppingIntent {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let fragments = IntentHeuristics.splitSubIntents(in: trimmed)
        let primary = detectFields(from: fragments.first ?? trimmed)

        var subIntents: [SubIntent] = []
        if fragments.count > 1 {
            subIntents = fragments.map { fragment in
                let fields = detectFields(from: fragment)
                return SubIntent(
                    goal: fields.goal,
                    occasion: fields.occasion,
                    peopleCount: fields.peopleCount,
                    confidence: confidence(for: fields)
                )
            }
        }

        return assemble(rawText: trimmed, fields: primary, subIntents: subIntents)
    }

    static func assemble(rawText: String, fields: ParsedIntentFields, subIntents: [SubIntent]) -> ShoppingIntent {
        let resolvedPeople = fields.peopleCount ?? defaultPeopleCount
        let occasion = fields.occasion ?? .everyday
        let confidence = fields.confidenceOverride ?? self.confidence(for: fields)

        let assumptions = makeAssumptions(fields: fields, resolvedPeople: resolvedPeople, resolvedOccasion: occasion)

        return ShoppingIntent(
            rawText: rawText,
            goal: fields.goal.isEmpty ? "Shopping list" : fields.goal,
            peopleCount: resolvedPeople,
            budget: fields.budgetRupees.map { Money(rupees: $0) },
            dietaryConstraints: fields.dietary,
            occasion: occasion,
            existingItems: fields.existingItems,
            category: fields.category,
            durationDays: fields.durationDays ?? (occasion == .weeklyRestock ? 7 : nil),
            subIntents: subIntents,
            confidence: confidence,
            assumptions: assumptions
        )
    }

    static func makeAssumptions(fields: ParsedIntentFields, resolvedPeople: Int, resolvedOccasion: Occasion) -> [AssumptionField] {
        var chips: [AssumptionField] = []

        chips.append(AssumptionField(
            key: .peopleCount,
            valueText: "\(resolvedPeople)",
            wasInferred: fields.peopleCount == nil,
            confidence: fields.peopleCount == nil ? 0.5 : 1.0,
            editableType: .number
        ))

        chips.append(AssumptionField(
            key: .occasion,
            valueText: resolvedOccasion.displayName,
            wasInferred: fields.occasion == nil,
            confidence: fields.occasion == nil ? 0.5 : 1.0,
            editableType: .singleSelect,
            options: Occasion.allCases.map(\.displayName)
        ))

        if let budget = fields.budgetRupees {
            chips.append(AssumptionField(
                key: .budget,
                valueText: Money(rupees: budget).displayString,
                wasInferred: false,
                confidence: 1.0,
                editableType: .currency
            ))
        }

        if !fields.dietary.isEmpty {
            chips.append(AssumptionField(
                key: .dietary,
                valueText: fields.dietary.map(\.displayName).joined(separator: ", "),
                wasInferred: false,
                confidence: 1.0,
                editableType: .multiSelect,
                options: DietaryConstraint.allCases.map(\.displayName)
            ))
        }

        if let duration = fields.durationDays {
            chips.append(AssumptionField(
                key: .duration,
                valueText: "\(duration) days",
                wasInferred: false,
                confidence: 1.0,
                editableType: .number
            ))
        } else if resolvedOccasion == .weeklyRestock {
            chips.append(AssumptionField(
                key: .duration,
                valueText: "7 days",
                wasInferred: true,
                confidence: 0.5,
                editableType: .number
            ))
        }

        if !fields.existingItems.isEmpty {
            chips.append(AssumptionField(
                key: .existingItems,
                valueText: fields.existingItems.joined(separator: ", "),
                wasInferred: false,
                confidence: 1.0,
                editableType: .text
            ))
        }

        return chips
    }

    static func confidence(for fields: ParsedIntentFields) -> Double {
        var score = 0.4
        if fields.peopleCount != nil { score += 0.2 }
        if fields.budgetRupees != nil { score += 0.15 }
        if fields.occasion != nil { score += 0.12 }
        if !fields.dietary.isEmpty { score += 0.08 }
        if fields.durationDays != nil { score += 0.05 }
        if hasRecognizableGoal(fields.goal) { score += 0.15 }
        return min(0.98, max(0.2, score))
    }

    private static func hasRecognizableGoal(_ goal: String) -> Bool {
        let lower = goal.lowercased()
        let keywords = MissionCatalogTags.goalKeywordTags.keys
        if keywords.contains(where: { lower.contains($0) }) { return true }
        return lower.split(separator: " ").count >= 2
    }

    private static func cleanGoal(_ text: String) -> String {
        var goal = text
        let noisePatterns = [
            #"\s*(?:under|below|within|max|budget of|budget|around|about|upto|up to)\s*(?:rs\.?|inr|₹)?\s*\d[\d,]*"#,
            #"\s*(?:rs\.?|inr|₹)\s*\d[\d,]*"#
        ]
        for pattern in noisePatterns {
            goal = goal.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        }
        goal = goal.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = goal.first else { return goal }
        return first.uppercased() + goal.dropFirst()
    }

    private static func category(for occasion: Occasion?) -> ProductCategory? {
        switch occasion {
        case .babyCare: .baby
        case .illness: .firstAid
        case .cleaning: .cleaning
        default: nil
        }
    }
}
