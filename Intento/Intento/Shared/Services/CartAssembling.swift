//
//  CartAssembling.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// A single stage emitted while a cart is being assembled, enabling the
/// "price & ETA live during generation" progressive UI. Pure data.
struct CartGenerationUpdate: Sendable {
    let partialCart: Cart
    let addedItem: CartItem?
    let isComplete: Bool
}

/// Orchestrates intent → cart: selects SKUs, applies quantity scaling, resolves
/// inventory/substitutions, and fits to budget. The high-level engine that
/// composes the lower-level logic protocols below.
protocol CartAssembling: Sendable {
    /// Generate a complete cart for an intent in one call.
    func generateCart(for intent: ShoppingIntent) async throws -> Cart

    /// Generate a cart while streaming progressive updates for animated UI.
    func generateCartStream(for intent: ShoppingIntent) -> AsyncThrowingStream<CartGenerationUpdate, Error>
}
