import Foundation
import Observation

@MainActor
@Observable
final class PersonalizationViewModel {
    private let personalization: PersonalizationStoring
    let haptics: HapticsServicing

    var preference: UserPreference = .empty
    var isLoaded = false

    init(personalization: PersonalizationStoring, haptics: HapticsServicing) {
        self.personalization = personalization
        self.haptics = haptics
    }

    func load() async {
        preference = (try? await personalization.loadPreferences()) ?? .empty
        isLoaded = true
    }

    func setNutritionAware(_ enabled: Bool) {
        preference.nutritionAwareEnabled = enabled
        persist()
    }

    func setSustainabilityNudges(_ enabled: Bool) {
        preference.sustainabilityNudgesEnabled = enabled
        persist()
    }

    func setDefaultPeople(_ count: Int) {
        preference.defaultPeopleCount = max(1, count)
        persist()
    }

    func setRestockCadence(_ days: Int?) {
        preference.restockCadenceDays = days
        persist()
    }

    func clearPreferredProducts() {
        preference.preferredProducts = []
        persist()
        haptics.play(.warning)
    }

    private func persist() {
        haptics.play(.selection)
        let snapshot = preference
        Task { try? await personalization.savePreferences(snapshot) }
    }
}
