//
//  CompositeEnvironment.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Resolves keys against an ordered list of providers, returning the first
/// non-empty match. Lets us layer sources, e.g. process environment overrides
/// on top of a bundled `.env`.
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
