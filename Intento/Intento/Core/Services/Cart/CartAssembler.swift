import Foundation

struct CartAssembler: CartAssembling {
    let planner: MissionPlanner
    let scaler: QuantityScaling
    let substitution: SubstitutionResolving
    let inventory: InventoryServicing
    let preferenceProvider: @Sendable () async -> UserPreference?

    init(
        planner: MissionPlanner,
        scaler: QuantityScaling,
        substitution: SubstitutionResolving,
        inventory: InventoryServicing,
        preferenceProvider: @escaping @Sendable () async -> UserPreference? = { nil }
    ) {
        self.planner = planner
        self.scaler = scaler
        self.substitution = substitution
        self.inventory = inventory
        self.preferenceProvider = preferenceProvider
    }

    func generateCart(for intent: ShoppingIntent) async throws -> Cart {
        let preference = await preferenceProvider()
        let planResult = try await planner.plan(for: intent, preference: preference)

        let items = planResult.products.map { product in
            CartItem(
                product: product,
                quantity: scaler.recommendedQuantity(for: product, intent: intent),
                source: .generated
            )
        }

        var cart = Cart(items: items, budget: intent.budget, unmatchedItems: planResult.unmatchedItems)
        cart = try await substitution.resolveSubstitutions(for: cart)
        cart.estimatedETAMinutes = try await estimatedETA(for: cart)

        if !cart.unmatchedItems.isEmpty {
            print("[Intento] ⚠️ Unmatched items not found in catalog: \(cart.unmatchedItems)")
        }

        return cart
    }

    func generateCartStream(for intent: ShoppingIntent) -> AsyncThrowingStream<CartGenerationUpdate, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let preference = await preferenceProvider()
                    let planResult = try await planner.plan(for: intent, preference: preference)
                    var cart = Cart(items: [], budget: intent.budget, unmatchedItems: planResult.unmatchedItems)

                    if !planResult.unmatchedItems.isEmpty {
                        print("[Intento] ⚠️ Unmatched items not found in catalog: \(planResult.unmatchedItems)")
                    }

                    for product in planResult.products {
                        try Task.checkCancellation()
                        let quantity = scaler.recommendedQuantity(for: product, intent: intent)
                        let status = try await inventory.status(forSKU: product.sku)

                        var item = CartItem(product: product, quantity: quantity, source: .generated)
                        var itemETA = status.etaMinutes

                        if !status.isAvailable {
                            guard let replacement = try await inventory.substitutes(forSKU: product.sku, limit: 1).first else {
                                continue
                            }
                            let record = SubstitutionRecord(
                                originalSKU: product.sku,
                                originalName: product.displayTitle,
                                substituteSKU: replacement.sku,
                                substituteName: replacement.displayTitle,
                                reason: .outOfStock
                            )
                            item = CartItem(product: replacement, quantity: quantity, source: .substitution, substitution: record)
                            itemETA = try await inventory.status(forSKU: replacement.sku).etaMinutes
                        }

                        cart.items.append(item)
                        if let itemETA {
                            cart.estimatedETAMinutes = max(cart.estimatedETAMinutes ?? 0, itemETA)
                        }
                        continuation.yield(CartGenerationUpdate(partialCart: cart, addedItem: item, isComplete: false))
                        try await Task.sleep(nanoseconds: 180_000_000)
                    }

                    continuation.yield(CartGenerationUpdate(partialCart: cart, addedItem: nil, isComplete: true))
                    continuation.finish()
                } catch is CancellationError {
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private func estimatedETA(for cart: Cart) async throws -> Int? {
        let statuses = try await inventory.statuses(forSKUs: cart.items.map { $0.product.sku })
        return statuses.values.compactMap { $0.etaMinutes }.max()
    }
}
