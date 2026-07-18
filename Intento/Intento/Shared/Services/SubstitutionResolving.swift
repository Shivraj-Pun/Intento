//
//  SubstitutionResolving.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Replaces out-of-stock cart items with available alternatives, recording a
/// `SubstitutionRecord` on each affected line so the UI can show a
/// "substituted" label and allow rejection.
protocol SubstitutionResolving: Sendable {
    func resolveSubstitutions(for cart: Cart) async throws -> Cart
}
