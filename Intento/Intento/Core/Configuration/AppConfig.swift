import Foundation

protocol AppConfigProviding: Sendable {
    var llmProvider: String { get }
    var llmAPIKey: String { get }
    var llmBaseURL: URL { get }
    var llmModel: String { get }

    var useMockServices: Bool { get }

    var currencyCode: String { get }
    var localeIdentifier: String { get }
}

struct AppConfig: AppConfigProviding, Sendable {
    let llmProvider: String
    let llmAPIKey: String
    let llmBaseURL: URL
    let llmModel: String
    let useMockServices: Bool
    let currencyCode: String
    let localeIdentifier: String

    enum Key {
        static let llmProvider = "LLM_PROVIDER"
        static let llmAPIKey = "LLM_API_KEY"
        static let llmBaseURL = "LLM_BASE_URL"
        static let llmModel = "LLM_MODEL"
        static let useMockServices = "USE_MOCK_SERVICES"
        static let currencyCode = "CURRENCY_CODE"
        static let localeIdentifier = "LOCALE_IDENTIFIER"
    }

    private static let fallbackBaseURL = URL(string: "https://generativelanguage.googleapis.com/v1beta")!

    init(environment: EnvironmentConfigProviding) {
        self.llmProvider = environment.value(forKey: Key.llmProvider) ?? "apple"
        self.llmAPIKey = environment.value(forKey: Key.llmAPIKey) ?? ""

        if let raw = environment.value(forKey: Key.llmBaseURL), let url = URL(string: raw) {
            self.llmBaseURL = url
        } else {
            self.llmBaseURL = Self.fallbackBaseURL
        }

        self.llmModel = environment.value(forKey: Key.llmModel) ?? "gemini-2.0-flash"

        let mockRaw = (environment.value(forKey: Key.useMockServices) ?? "false").lowercased()
        self.useMockServices = !(mockRaw == "false" || mockRaw == "0" || mockRaw == "no")

        self.currencyCode = environment.value(forKey: Key.currencyCode) ?? "INR"
        self.localeIdentifier = environment.value(forKey: Key.localeIdentifier) ?? "en_IN"
    }

    init(
        llmProvider: String = "apple",
        llmAPIKey: String = "",
        llmBaseURL: URL = AppConfig.fallbackBaseURL,
        llmModel: String = "gemini-2.0-flash",
        useMockServices: Bool = false,
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

    var hasLLMKey: Bool {
        !llmAPIKey.isEmpty
    }
}

extension AppConfig {
    static func bootstrap(bundle: Bundle = .main) -> AppConfig {
        var providers: [EnvironmentConfigProviding] = [ProcessInfoEnvironment()]
        if let dotEnv = DotEnvEnvironment(bundle: bundle) {
            providers.append(dotEnv)
        }
        return AppConfig(environment: CompositeEnvironment(providers))
    }
}
