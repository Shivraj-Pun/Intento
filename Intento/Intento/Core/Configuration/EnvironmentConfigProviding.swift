import Foundation

protocol EnvironmentConfigProviding: Sendable {
    func value(forKey key: String) -> String?
}
