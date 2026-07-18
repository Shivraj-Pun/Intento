//
//  CartItem.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// How a cart item came to be in the cart.
enum CartItemSource: String, Codable, Hashable, Sendable {
    case generated          // added by the intent-to-cart engine
    case substitution       // added to replace an unavailable item
    case userAdded          // manually added by the user
    case suggestion         // seasonal / nutrition / sustainability suggestion
    case personalization    // added from remembered preferences
}

/// A single line in the cart: a product, a quantity (number of packs), and
/// provenance metadata. Pure data model.
struct CartItem: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var product: Product
    var quantity: Int
    var source: CartItemSource

    /// Present when this item replaced a different product.
    var substitution: SubstitutionRecord?

    init(
        id: UUID = UUID(),
        product: Product,
        quantity: Int = 1,
        source: CartItemSource = .generated,
        substitution: SubstitutionRecord? = nil
    ) {
        self.id = id
        self.product = product
        self.quantity = max(0, quantity)
        self.source = source
        self.substitution = substitution
    }

    nonisolated var isSubstitution: Bool {
        substitution != nil
    }

    /// Total price for this line (unit price × quantity).
    nonisolated var lineTotal: Money {
        product.price * quantity
    }
}
