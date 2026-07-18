import Foundation
import Observation

@MainActor
@Observable
final class AskViewModel {
    enum Phase: Equatable {
        case idle
        case understanding
        case ready
        case failed
    }

    private let intentExtractor: LLMIntentExtracting
    private let speech: SpeechRecognizing
    let haptics: HapticsServicing

    var inputText: String
    var phase: Phase = .idle
    var intent: ShoppingIntent?
    var assumptions: [AssumptionField] = []
    var errorMessage: String?
    var isListening = false
    var speechAuthDenied = false

    private var speechTask: Task<Void, Never>?

    var needsClarification: Bool {
        guard let intent else { return false }
        return intent.confidenceLevel.shouldRequestClarification
    }

    var confidence: Double { intent?.confidence ?? 0 }
    var confidenceLevel: ConfidenceLevel { intent?.confidenceLevel ?? .low }

    init(
        intentExtractor: LLMIntentExtracting,
        speech: SpeechRecognizing,
        haptics: HapticsServicing,
        initialText: String = ""
    ) {
        self.intentExtractor = intentExtractor
        self.speech = speech
        self.haptics = haptics
        self.inputText = initialText
    }

    func submit() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        stopVoice()
        phase = .understanding
        errorMessage = nil

        do {
            let extracted = try await intentExtractor.extractIntent(from: text)
            intent = extracted
            assumptions = extracted.assumptions
            phase = .ready
            haptics.play(extracted.confidenceLevel == .low ? .warning : .success)
        } catch {
            errorMessage = Self.message(for: error)
            phase = .failed
            haptics.play(.error)
        }
    }

    func reset() {
        phase = .idle
        intent = nil
        assumptions = []
        errorMessage = nil
    }

    func updateAssumption(_ field: AssumptionField, to newValue: String) {
        guard var currentIntent = intent else { return }
        apply(key: field.key, value: newValue, to: &currentIntent)

        if let index = assumptions.firstIndex(where: { $0.id == field.id }) {
            assumptions[index].valueText = newValue.isEmpty ? assumptions[index].valueText : newValue
            assumptions[index].wasInferred = false
            assumptions[index].confidence = 1.0
        }
        currentIntent.assumptions = assumptions
        intent = currentIntent
        haptics.play(.chipEdit)
    }

    func toggleVoice() async {
        if isListening {
            stopVoice()
        } else {
            await startVoice()
        }
    }

    func startVoice() async {
        let authorized = await speech.requestAuthorization()
        guard authorized else {
            speechAuthDenied = true
            haptics.play(.error)
            return
        }
        speechAuthDenied = false
        isListening = true
        haptics.play(.selection)

        speechTask = Task { [weak self] in
            guard let self else { return }
            do {
                for try await transcript in self.speech.startTranscribing() {
                    self.inputText = transcript
                }
            } catch {
                self.errorMessage = Self.message(for: error)
            }
            self.isListening = false
        }
    }

    func stopVoice() {
        guard isListening else { return }
        speech.stopTranscribing()
        speechTask?.cancel()
        speechTask = nil
        isListening = false
        haptics.play(.selection)
    }

    private func apply(key: AssumptionKey, value: String, to intent: inout ShoppingIntent) {
        let digits = value.filter(\.isNumber)
        switch key {
        case .peopleCount:
            if let count = Int(digits) { intent.peopleCount = max(1, count) }
        case .budget:
            if let amount = Int(digits) {
                intent.budget = Money(rupees: amount)
            } else if value.trimmingCharacters(in: .whitespaces).isEmpty {
                intent.budget = nil
            }
        case .occasion:
            intent.occasion = Occasion.allCases.first { $0.displayName == value }
        case .duration:
            if let days = Int(digits) { intent.durationDays = max(1, days) }
        case .dietary:
            let names = value.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            intent.dietaryConstraints = names.compactMap { name in
                DietaryConstraint.allCases.first { $0.displayName == name }
            }
        case .existingItems:
            intent.existingItems = value.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        case .goal, .category:
            break
        }
    }

    static func message(for error: Error) -> String {
        if let llmError = error as? LLMIntentError {
            switch llmError {
            case .missingAPIKey: return "No AI key configured. Using the on-device parser."
            case .invalidResponse: return "The AI response could not be read. Please try again."
            case .httpError(let status, _): return "The AI service returned an error (\(status))."
            }
        }
        return "Something went wrong understanding that. Please try again."
    }
}
