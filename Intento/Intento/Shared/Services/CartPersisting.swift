import Foundation

/// Protocol for persisting cart state to a remote store (e.g. Supabase).
protocol CartPersisting: Sendable {
    /// Loads the user's currently active cart (status = 'active'), or nil if none exists.
    func loadActiveCart(userID: UUID) async throws -> Cart?

    /// Creates or replaces the user's active cart with the given items.
    /// Returns the persisted cart's UUID (the Supabase row id).
    @discardableResult
    func saveCart(_ cart: Cart, userID: UUID, missionID: UUID?) async throws -> UUID

    /// Adds a single item to the active cart, preserving the item's id so local and
    /// remote state stay in sync. Creates the cart if needed.
    func addItem(_ item: CartItem, userID: UUID) async throws

    /// Updates the quantity of an existing cart item. Removes it if quantity <= 0.
    func updateItemQuantity(cartItemID: UUID, quantity: Int) async throws

    /// Removes a single item from the cart.
    func removeItem(cartItemID: UUID) async throws

    /// Marks the active cart as checked out and clears it.
    func checkout(userID: UUID) async throws

    /// Deletes all items and the active cart row (used for cart clearing without order).
    func clearActiveCart(userID: UUID) async throws
}
