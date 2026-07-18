import Foundation

struct SubstitutionResolver: SubstitutionResolving {
    let inventory: InventoryServicing

    init(inventory: InventoryServicing) {
        self.inventory = inventory
    }

    func resolveSubstitutions(for cart: Cart) async throws -> Cart {
        var newItems: [CartItem] = []

        for item in cart.items {
            let status = try await inventory.status(forSKU: item.product.sku)
            if status.isAvailable {
                newItems.append(item)
                continue
            }

            let candidates = try await inventory.substitutes(forSKU: item.product.sku, limit: 1)
            guard let replacement = candidates.first else {
                newItems.append(item)
                continue
            }

            let record = SubstitutionRecord(
                originalSKU: item.product.sku,
                originalName: item.product.displayTitle,
                substituteSKU: replacement.sku,
                substituteName: replacement.displayTitle,
                reason: .outOfStock
            )

            let substituted = CartItem(
                id: item.id,
                product: replacement,
                quantity: item.quantity,
                source: .substitution,
                substitution: record
            )
            newItems.append(substituted)
        }

        var result = cart
        result.items = newItems
        return result
    }
}
