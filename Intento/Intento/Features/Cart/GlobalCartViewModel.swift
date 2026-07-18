import Foundation
import Observation
import Combine

@MainActor
@Observable
final class GlobalCartViewModel {
    var items: [CartItem] = []
    var isLoading = false

    private let cartService: CartPersisting
    private let auth: AuthServicing
    private var hasLoaded = false
    private var userID: UUID?
    private var authCancellable: AnyCancellable?

    /// Serializes persistence operations so they apply in the same order they were
    /// issued (e.g. an item's insert always completes before a later quantity update).
    private var persistenceTail: Task<Void, Never>?

    init(cartService: CartPersisting, auth: AuthServicing) {
        self.cartService = cartService
        self.auth = auth

        // Observe auth state to track the current user ID
        authCancellable = auth.authStatePublisher.sink { [weak self] state in
            Task { @MainActor in
                guard let self else { return }
                switch state {
                case .loggedIn(let user):
                    self.userID = user.id
                case .loggedOut:
                    self.userID = nil
                    self.items = []
                    self.hasLoaded = false
                }
            }
        }
    }

    var subtotal: Money {
        items.map { $0.lineTotal }.reduce(.zero, +)
    }

    var isEmpty: Bool {
        items.isEmpty
    }

    // MARK: - Load from Supabase

    func loadIfNeeded() async {
        guard !hasLoaded, let userID else { return }
        hasLoaded = true
        isLoading = true
        defer { isLoading = false }

        do {
            if let cart = try await cartService.loadActiveCart(userID: userID) {
                items = cart.items
            }
        } catch {
            print("[Intento] ⚠️ Failed to load cart from Supabase: \(error)")
        }
    }

    // MARK: - Mutations

    func add(_ product: Product) {
        if let index = items.firstIndex(where: { $0.product.sku == product.sku }) {
            items[index].quantity += 1
            persistUpdateQuantity(item: items[index])
        } else {
            let newItem = CartItem(id: UUID(), product: product, quantity: 1, source: .userAdded)
            items.append(newItem)
            persistAddItem(item: newItem)
        }
    }

    func increment(_ item: CartItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].quantity += 1
            persistUpdateQuantity(item: items[index])
        }
    }

    func decrement(_ item: CartItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            if items[index].quantity > 1 {
                items[index].quantity -= 1
                persistUpdateQuantity(item: items[index])
            } else {
                items.remove(at: index)
                persistRemoveItem(cartItemID: item.id)
            }
        }
    }

    func remove(_ item: CartItem) {
        items.removeAll { $0.id == item.id }
        persistRemoveItem(cartItemID: item.id)
    }

    func placeOrder() -> OrderConfirmation {
        let count = items.reduce(0) { $0 + $1.quantity }
        let total = subtotal

        let digits = (0..<6).map { _ in String(Int.random(in: 0...9)) }.joined()
        let confirmation = OrderConfirmation(
            orderNumber: "ORD-\(digits)",
            itemCount: count,
            total: total,
            etaMinutes: 15
        )

        items.removeAll()
        hasLoaded = false
        persistCheckout()
        return confirmation
    }

    // MARK: - Private Persistence Helpers

    /// Chains a persistence operation onto the serial tail so operations run strictly
    /// in the order they were enqueued, avoiding update-before-insert races.
    private func enqueuePersistence(_ operation: @escaping @Sendable () async -> Void) {
        let previous = persistenceTail
        persistenceTail = Task { @MainActor in
            await previous?.value
            await operation()
        }
    }

    private func persistAddItem(item: CartItem) {
        guard let userID else { return }
        let service = cartService
        enqueuePersistence {
            do {
                try await service.addItem(item, userID: userID)
            } catch {
                print("[Intento] ⚠️ Failed to persist add item: \(error)")
            }
        }
    }

    private func persistUpdateQuantity(item: CartItem) {
        let service = cartService
        enqueuePersistence {
            do {
                try await service.updateItemQuantity(cartItemID: item.id, quantity: item.quantity)
            } catch {
                print("[Intento] ⚠️ Failed to persist quantity update: \(error)")
            }
        }
    }

    private func persistRemoveItem(cartItemID: UUID) {
        let service = cartService
        enqueuePersistence {
            do {
                try await service.removeItem(cartItemID: cartItemID)
            } catch {
                print("[Intento] ⚠️ Failed to persist item removal: \(error)")
            }
        }
    }

    private func persistCheckout() {
        guard let userID else { return }
        let service = cartService
        enqueuePersistence {
            do {
                try await service.checkout(userID: userID)
            } catch {
                print("[Intento] ⚠️ Failed to persist checkout: \(error)")
            }
        }
    }
}
