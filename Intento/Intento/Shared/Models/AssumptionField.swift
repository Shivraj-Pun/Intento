import Foundation

enum AssumptionKey: String, Codable, CaseIterable, Hashable, Sendable {
    case goal
    case peopleCount = "people_count"
    case budget
    case dietary
    case occasion
    case duration
    case category
    case existingItems = "existing_items"

    nonisolated var displayLabel: String {
        switch self {
        case .goal: "Goal"
        case .peopleCount: "People"
        case .budget: "Budget"
        case .dietary: "Dietary"
        case .occasion: "Occasion"
        case .duration: "Duration"
        case .category: "Category"
        case .existingItems: "Already Have"
        }
    }
}

enum AssumptionEditableType: String, Codable, Hashable, Sendable {
    case number
    case currency
    case text
    case singleSelect = "single_select"
    case multiSelect = "multi_select"
}

struct AssumptionField: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let key: AssumptionKey
    var displayLabel: String
    var valueText: String

    var wasInferred: Bool
    var confidence: Double
    var editableType: AssumptionEditableType

    var options: [String]

    nonisolated init(
        id: UUID = UUID(),
        key: AssumptionKey,
        displayLabel: String? = nil,
        valueText: String,
        wasInferred: Bool,
        confidence: Double = 1.0,
        editableType: AssumptionEditableType,
        options: [String] = []
    ) {
        self.id = id
        self.key = key
        self.displayLabel = displayLabel ?? key.displayLabel
        self.valueText = valueText
        self.wasInferred = wasInferred
        self.confidence = confidence
        self.editableType = editableType
        self.options = options
    }
}
