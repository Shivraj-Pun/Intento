import Foundation

enum CartItemSource: String, Codable, Hashable, Sendable {
    case generated
    case substitution
    case userAdded
    case suggestion
    case personalization
}

struct CartItem: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var product: Product
    var quantity: Int
    var source: CartItemSource

    var substitution: SubstitutionRecord?

    nonisolated init(
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

    nonisolated var lineTotal: Money {
        product.price * quantity
    }
}
