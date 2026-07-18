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
    let auth: AuthServicing

    init(config: AppConfig, personalization: PersonalizationStoring, auth: AuthServicing) {
        self.config = config
        self.personalization = personalization
        self.auth = auth

        let catalog = SupabaseProductCatalogService(client: SupabaseManager.client)
        let inventory = SupabaseInventoryService(client: SupabaseManager.client, catalog: catalog)
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
        print("[Intento] 🔧 Configuring intent extractor — provider: \"\(config.llmProvider)\", useMockServices: \(config.useMockServices)")

        guard !config.useMockServices else {
            print("[Intento] ⚠️ useMockServices=true → Using RecipeAwareMockExtractor")
            return RecipeAwareMockExtractor()
        }

        // Apple Foundation Models — on-device, no API key needed, privacy-first
        if config.llmProvider.lowercased() == "apple" {
            print("[Intento] 🍎 Provider is 'apple' — checking Foundation Models availability...")
            if AppleFoundationModelAvailability.isAvailable {
                if #available(iOS 26.0, macOS 26.0, *) {
                    print("[Intento] ✅ Apple Foundation Models AVAILABLE — using on-device extraction")
                    let apple = AppleFoundationModelIntentExtractor()
                    return FallbackIntentExtractor(primary: apple)
                }
            }
            print("[Intento] ❌ Apple Foundation Models NOT available on this device — falling back to mock")
            return FallbackIntentExtractor(primary: RecipeAwareMockExtractor())
        }

        // Gemini (cloud) — kept intact but no longer the default path
        if config.llmProvider.lowercased() == "gemini", config.hasLLMKey {
            print("[Intento] 🌐 Provider is 'gemini' with API key — using Gemini cloud extraction")
            let gemini = GeminiIntentExtractor(
                apiKey: config.llmAPIKey,
                baseURL: config.llmBaseURL,
                model: config.llmModel
            )
            return FallbackIntentExtractor(primary: gemini)
        }

        print("[Intento] ⚠️ No valid provider configured — falling back to RecipeAwareMockExtractor")
        return RecipeAwareMockExtractor()
    }

}
