import Foundation

extension AppContainer {
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(personalization: personalization, seasonal: seasonal, haptics: haptics)
    }

    func makeAskViewModel(initialText: String = "") -> AskViewModel {
        AskViewModel(
            intentExtractor: intentExtractor,
            speech: speech,
            haptics: haptics,
            initialText: initialText
        )
    }

    func makeCartViewModel(intent: ShoppingIntent) -> CartViewModel {
        CartViewModel(
            intent: intent,
            assembler: cartAssembler,
            budgetOptimizer: budgetOptimizer,
            catalog: catalog,
            inventory: inventory,
            nutrition: nutrition,
            sustainability: sustainability,
            personalization: personalization,
            cartService: cartService,
            auth: auth,
            haptics: haptics,
            currencyCode: config.currencyCode,
            localeIdentifier: config.localeIdentifier
        )
    }

    func makeGlobalCartViewModel() -> GlobalCartViewModel {
        GlobalCartViewModel(cartService: cartService, auth: auth)
    }

    func makePersonalizationViewModel() -> PersonalizationViewModel {
        PersonalizationViewModel(personalization: personalization, haptics: haptics)
    }
}
