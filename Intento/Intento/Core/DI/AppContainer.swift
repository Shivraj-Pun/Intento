import Foundation

@MainActor
final class AppContainer {
    let config: AppConfig

    let catalog: ProductCatalogServicing
    let inventory: InventoryServicing
    let intentExtractor: LLMIntentExtracting
    let scaler: QuantityScaling
    let substitution: SubstitutionResolving
    let cartAssembler: CartAssembling
    let budgetOptimizer: BudgetOptimizing
    let seasonal: SeasonalIntelligenceProviding
    let nutrition: NutritionAdvising
    let sustainability: SustainabilityAdvising
    let haptics: HapticsServicing
    let speech: SpeechRecognizing
    let personalization: PersonalizationStoring

    init(config: AppConfig, personalization: PersonalizationStoring, snapshot: CatalogSnapshot? = nil) {
        self.config = config
        self.personalization = personalization

        let resolvedSnapshot = snapshot ?? AppContainer.loadSnapshot()
        let catalog = MockProductCatalogService(snapshot: resolvedSnapshot)
        let inventory = MockInventoryService(inventory: resolvedSnapshot.inventory, catalog: catalog)
        self.catalog = catalog
        self.inventory = inventory

        let scaler = QuantityScalingEngine()
        let substitution = SubstitutionResolver(inventory: inventory)
        let planner = MissionPlanner(catalog: catalog)
        self.scaler = scaler
        self.substitution = substitution
        self.budgetOptimizer = BudgetOptimizer()

        self.cartAssembler = CartAssembler(
            planner: planner,
            scaler: scaler,
            substitution: substitution,
            inventory: inventory,
            preferenceProvider: {
                try? await personalization.loadPreferences()
            }
        )

        self.seasonal = SeasonalIntelligenceEngine()
        self.nutrition = NutritionAdvisor(catalog: catalog)
        self.sustainability = SustainabilityAdvisor(catalog: catalog)
        self.haptics = SystemHapticsService()

        self.intentExtractor = AppContainer.makeIntentExtractor(config: config)

        #if os(iOS)
        self.speech = SpeechRecognizer()
        #else
        self.speech = NoopSpeechRecognizer()
        #endif
    }

    static func makeIntentExtractor(config: AppConfig) -> LLMIntentExtracting {
        guard !config.useMockServices, config.hasLLMKey, config.llmProvider.lowercased() == "gemini" else {
            return RecipeAwareMockExtractor()
        }
        let gemini = GeminiIntentExtractor(
            apiKey: config.llmAPIKey,
            baseURL: config.llmBaseURL,
            model: config.llmModel
        )
        return FallbackIntentExtractor(primary: gemini)
    }

    static func loadSnapshot() -> CatalogSnapshot {
        (try? CatalogDecoder().loadBundledCatalog()) ?? .empty
    }
}
