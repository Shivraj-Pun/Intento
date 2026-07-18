//
//  AssumptionField.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Which intent field an assumption chip represents.
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

/// The kind of editor an assumption chip should present.
enum AssumptionEditableType: String, Codable, Hashable, Sendable {
    case number
    case currency
    case text
    case singleSelect = "single_select"
    case multiSelect = "multi_select"
}

/// An editable "assumption chip". Represents a field of the intent that was
/// either explicitly stated by the user or inferred by the extractor. Inferred
/// fields (`wasInferred == true`) are surfaced for quick correction, and any
/// edit triggers cart regeneration (Phase 2).
struct AssumptionField: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let key: AssumptionKey
    var displayLabel: String
    var valueText: String

    /// True when the value was inferred rather than explicitly stated.
    var wasInferred: Bool
    var confidence: Double
    var editableType: AssumptionEditableType

    /// Options offered for select-type fields (e.g. occasions, dietary tags).
    var options: [String]

    init(
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
