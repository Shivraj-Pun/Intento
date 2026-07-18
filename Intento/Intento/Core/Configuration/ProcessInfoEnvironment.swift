//
//  ProcessInfoEnvironment.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Reads configuration from the process environment. Useful for CI, unit tests,
/// and Xcode scheme environment variables, and as a higher-priority override of
/// a bundled `.env`.
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
