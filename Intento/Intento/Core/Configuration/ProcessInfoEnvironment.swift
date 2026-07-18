import Foundation

struct ProcessInfoEnvironment: EnvironmentConfigProviding {
    private let environment: [String: String]

    init(environment: [String: String] = ProcessInfo.processInfo.environment) {
        self.environment = environment
    }

    func value(forKey key: String) -> String? {
        guard let value = environment[key], !value.isEmpty else { return nil }
        return value
    }
}
