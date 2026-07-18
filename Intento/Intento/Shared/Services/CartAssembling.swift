import Foundation

struct CartGenerationUpdate: Sendable {
    let partialCart: Cart
    let addedItem: CartItem?
    let isComplete: Bool

    nonisolated init(partialCart: Cart, addedItem: CartItem?, isComplete: Bool) {
        self.partialCart = partialCart
        self.addedItem = addedItem
        self.isComplete = isComplete
    }
}

protocol CartAssembling: Sendable {
    func generateCart(for intent: ShoppingIntent) async throws -> Cart

    func generateCartStream(for intent: ShoppingIntent) -> AsyncThrowingStream<CartGenerationUpdate, Error>
}
