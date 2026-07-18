//
//  SustainabilityAdvising.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Produces non-blocking sustainability nudges (refill packs, reusable
/// alternatives) for eligible cart items.
protocol SustainabilityAdvising: Sendable {
    func sustainableAlternatives(for cart: Cart) async throws -> [SustainabilitySuggestion]
}
