import Foundation

protocol SubstitutionResolving: Sendable {
    func resolveSubstitutions(for cart: Cart) async throws -> Cart
}
