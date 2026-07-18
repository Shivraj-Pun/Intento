import Foundation

protocol SustainabilityAdvising: Sendable {
    func sustainableAlternatives(for cart: Cart) async throws -> [SustainabilitySuggestion]
}
