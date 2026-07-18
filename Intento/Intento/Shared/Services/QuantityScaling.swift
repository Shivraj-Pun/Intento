import Foundation

protocol QuantityScaling: Sendable {
    func recommendedQuantity(for product: Product, intent: ShoppingIntent) -> Int
}
