//
//  AppConfig.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Typed, resolved application configuration. The single type the rest of the
/// app reads configuration from. Services and ViewModels receive the values
/// they need injected, so neither the `.env` file nor this type is reached into
/// as a hidden singleton from feature code.
protocol AppConfigProviding: Sendable {
    var llmProvider: String { get }
    var llmAPIKey: String { get }
    var llmBaseURL: URL { get }
    var llmModel: String { get }

    /// When true, the composition root wires up local mock data sources instead
    /// of live network services.
    var useMockServices: Bool { get }

    var currencyCode: String { get }
    var localeIdentifier: String { get }
}

/// Concrete configuration resolved from an `EnvironmentConfigProviding` source.
struct AppConfig: AppConfigProviding, Sendable {
    let llmProvider: String
    let llmAPIKey: String
    let llmBaseURL: URL
    let llmModel: String
    let useMockServices: Bool
    let currencyCode: String
    let localeIdentifier: String

    /// Well-known configuration keys expected in the `.env`.
    enum Key {
        static let llmProvider = "LLM_PROVIDER"
        static let llmAPIKey = "LLM_API_KEY"
        static let llmBaseURL = "LLM_BASE_URL"
        static let llmModel = "LLM_MODEL"
        static let useMockServices = "USE_MOCK_SERVICES"
        static let currencyCode = "CURRENCY_CODE"
        static let localeIdentifier = "LOCALE_IDENTIFIER"
    }

    private static let fallbackBaseURL = URL(string: "https://api.openai.com/v1")!

    init(environment: EnvironmentConfigProviding) {
        self.llmProvider = environment.value(forKey: Key.llmProvider) ?? "openai"
        self.llmAPIKey = environment.value(forKey: Key.llmAPIKey) ?? ""

        if let raw = environment.value(forKey: Key.llmBaseURL), let url = URL(string: raw) {
            self.llmBaseURL = url
        } else {
            self.llmBaseURL = Self.fallbackBaseURL
        }

        self.llmModel = environment.value(forKey: Key.llmModel) ?? "gpt-4o-mini"

        // Defaults to mock services unless explicitly disabled.
        let mockRaw = (environment.value(forKey: Key.useMockServices) ?? "true").lowercased()
        self.useMockServices = !(mockRaw == "false" || mockRaw == "0" || mockRaw == "no")

        self.currencyCode = environment.value(forKey: Key.currencyCode) ?? "INR"
        self.localeIdentifier = environment.value(forKey: Key.localeIdentifier) ?? "en_IN"
    }

    /// Direct initializer for tests and previews.
    init(
        llmProvider: String = "openai",
        llmAPIKey: String = "",
        llmBaseURL: URL = AppConfig.fallbackBaseURL,
        llmModel: String = "gpt-4o-mini",
        useMockServices: Bool = true,
        currencyCode: String = "INR",
        localeIdentifier: String = "en_IN"
    ) {
        self.llmProvider = llmProvider
        self.llmAPIKey = llmAPIKey
        self.llmBaseURL = llmBaseURL
        self.llmModel = llmModel
        self.useMockServices = useMockServices
        self.currencyCode = currencyCode
        self.localeIdentifier = localeIdentifier
    }

    /// Whether a usable LLM API key is present. When false, the composition root
    /// should fall back to the on-device mock intent extractor.
    var hasLLMKey: Bool {
        !llmAPIKey.isEmpty
    }
}

extension AppConfig {
    /// Composition-root bootstrap. Resolves configuration once at launch by
    /// layering the process environment over a bundled `.env`. The resulting
    /// value is injected downstream — feature code never re-reads `.env`.
    static func bootstrap(bundle: Bundle = .main) -> AppConfig {
        var providers: [EnvironmentConfigProviding] = [ProcessInfoEnvironment()]
        if let dotEnv = DotEnvEnvironment(bundle: bundle) {
            providers.append(dotEnv)
        }
        return AppConfig(environment: CompositeEnvironment(providers))
    }
}
