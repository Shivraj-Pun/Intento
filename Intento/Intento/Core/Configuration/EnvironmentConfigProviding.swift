//
//  EnvironmentConfigProviding.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Abstracts a raw source of `KEY=VALUE` configuration entries. This keeps the
/// origin of configuration (a bundled `.env`, process environment, a remote
/// config service, etc.) swappable. ViewModels and services never depend on
/// this directly; they receive resolved values via `AppConfig`.
protocol EnvironmentConfigProviding: Sendable {
    /// The raw string value for a key, or `nil` if absent/empty.
    func value(forKey key: String) -> String?
}
