import Foundation

struct CompositeEnvironment: EnvironmentConfigProviding {
    private let providers: [EnvironmentConfigProviding]

    init(_ providers: [EnvironmentConfigProviding]) {
        self.providers = providers
    }

    func value(forKey key: String) -> String? {
        for provider in providers {
            if let value = provider.value(forKey: key) {
                return value
            }
        }
        return nil
    }
}
