import Foundation
import Supabase

actor SupabaseCartService: CartPersisting {
    private let client: SupabaseClient
    private let catalog: ProductCatalogServicing
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    /// Memoized active-cart resolution per user. Concurrent callers await the same
    /// in-flight resolution instead of each creating a separate cart (prevents the
    /// race that produced multiple "active" carts for one user).
    private var activeCartResolution: [UUID: Task<UUID, Error>] = [:]

    init(client: SupabaseClient, catalog: ProductCatalogServicing) {
        self.client = client
        self.catalog = catalog
    }

    // MARK: - Load Active Cart

    func loadActiveCart(userID: UUID) async throws -> Cart? {
        // Fetch the active cart row for this user
        let cartRows: [SupabaseCartRow] = try await client.database
            .from("carts")
            .select()
            .eq("user_id", value: userID.uuidString)
            .eq("status", value: "active")
            .order("created_at", ascending: false)
            .limit(1)
            .execute()
            .value

        guard let cartRow = cartRows.first else { return nil }

        // Fetch all items belonging to this cart
        let itemRows: [SupabaseCartItemRow] = try await client.database
            .from("cart_items")
            .select()
            .eq("cart_id", value: cartRow.id.uuidString)
            .execute()
            .value

        // Resolve product SKUs to full Product objects
        let skus = itemRows.map(\.product_sku)
        let products = try await catalog.products(forSKUs: skus)
        let productMap = Dictionary(uniqueKeysWithValues: products.map { ($0.sku, $0) })

        // Build CartItem array
        let cartItems: [CartItem] = itemRows.compactMap { row in
            guard let product = productMap[row.product_sku] else { return nil }
            let source = CartItemSource(rawValue: row.source) ?? .generated
            let substitution: SubstitutionRecord? = {
                guard let jsonStr = row.substitution,
                      let data = jsonStr.data(using: .utf8) else { return nil }
                return try? self.decoder.decode(SubstitutionRecord.self, from: data)
            }()
            return CartItem(
                id: row.id,
                product: product,
                quantity: row.quantity,
                source: source,
                substitution: substitution
            )
        }

        let budget: Money? = cartRow.budget_paise.map { Money(paise: $0) }

        return Cart(
            id: cartRow.id,
            items: cartItems,
            budget: budget,
            estimatedETAMinutes: cartRow.estimated_eta_minutes,
            nearBudgetThreshold: cartRow.near_budget_threshold
        )
    }

    // MARK: - Save Cart (create or replace)

    @discardableResult
    func saveCart(_ cart: Cart, userID: UUID, missionID: UUID?) async throws -> UUID {
        // Delete existing active cart for this user (replace strategy)
        try await deleteActiveCart(userID: userID)
        // The active cart id is changing — drop any memoized resolution.
        invalidateActiveCartCache(for: userID)

        // Insert new cart row
        let cartInsert = SupabaseCartInsert(
            id: cart.id,
            user_id: userID,
            budget_paise: cart.budget?.paise,
            estimated_eta_minutes: cart.estimatedETAMinutes,
            near_budget_threshold: cart.nearBudgetThreshold,
            status: "active",
            mission_id: missionID
        )

        try await client.database
            .from("carts")
            .insert(cartInsert)
            .execute()

        // Insert all cart items
        if !cart.items.isEmpty {
            let itemInserts = cart.items.map { item in
                let substitutionJSON: String? = {
                    guard let sub = item.substitution,
                          let data = try? self.encoder.encode(sub) else { return nil }
                    return String(data: data, encoding: .utf8)
                }()
                return SupabaseCartItemInsert(
                    id: item.id,
                    cart_id: cart.id,
                    product_sku: item.product.sku,
                    quantity: item.quantity,
                    source: item.source.rawValue,
                    substitution: substitutionJSON
                )
            }

            try await client.database
                .from("cart_items")
                .insert(itemInserts)
                .execute()
        }

        return cart.id
    }

    // MARK: - Add Item

    func addItem(_ item: CartItem, userID: UUID) async throws {
        let cartID = try await activeCartID(for: userID)

        // Check if product already exists in cart
        let existing: [SupabaseCartItemRow] = try await client.database
            .from("cart_items")
            .select()
            .eq("cart_id", value: cartID.uuidString)
            .eq("product_sku", value: item.product.sku)
            .execute()
            .value

        if let existingItem = existing.first {
            // Product already present — bump the quantity on the existing row.
            let newQuantity = existingItem.quantity + item.quantity
            try await client.database
                .from("cart_items")
                .update(SupabaseCartItemQuantityUpdate(quantity: newQuantity))
                .eq("id", value: existingItem.id.uuidString)
                .execute()
        } else {
            // Insert new item, preserving the caller's id so local == remote.
            let substitutionJSON: String? = {
                guard let sub = item.substitution,
                      let data = try? self.encoder.encode(sub) else { return nil }
                return String(data: data, encoding: .utf8)
            }()
            let insert = SupabaseCartItemInsert(
                id: item.id,
                cart_id: cartID,
                product_sku: item.product.sku,
                quantity: item.quantity,
                source: item.source.rawValue,
                substitution: substitutionJSON
            )
            try await client.database
                .from("cart_items")
                .insert(insert)
                .execute()
        }

        // Touch updated_at on the cart
        try await touchCart(cartID)
    }

    // MARK: - Update Item Quantity

    func updateItemQuantity(cartItemID: UUID, quantity: Int) async throws {
        if quantity <= 0 {
            try await removeItem(cartItemID: cartItemID)
            return
        }

        try await client.database
            .from("cart_items")
            .update(SupabaseCartItemQuantityUpdate(quantity: quantity))
            .eq("id", value: cartItemID.uuidString)
            .execute()
    }

    // MARK: - Remove Item

    func removeItem(cartItemID: UUID) async throws {
        try await client.database
            .from("cart_items")
            .delete()
            .eq("id", value: cartItemID.uuidString)
            .execute()
    }

    // MARK: - Checkout

    func checkout(userID: UUID) async throws {
        let cartRows: [SupabaseCartRow] = try await client.database
            .from("carts")
            .select()
            .eq("user_id", value: userID.uuidString)
            .eq("status", value: "active")
            .limit(1)
            .execute()
            .value

        guard let cartRow = cartRows.first else { return }

        struct StatusUpdate: Encodable {
            let status: String
            let updated_at: String
        }

        try await client.database
            .from("carts")
            .update(StatusUpdate(status: "checked_out", updated_at: ISO8601DateFormatter().string(from: Date())))
            .eq("id", value: cartRow.id.uuidString)
            .execute()

        // The active cart is now checked out — next add should start a fresh cart.
        invalidateActiveCartCache(for: userID)
    }

    // MARK: - Clear Active Cart

    func clearActiveCart(userID: UUID) async throws {
        try await deleteActiveCart(userID: userID)
    }

    // MARK: - Private Helpers

    /// Returns the active cart ID for the user, creating one if none exists.
    ///
    /// Uses a memoized `Task` so that many concurrent `addItem` calls (e.g. when the
    /// Ask tab adds a whole cart at once) all await the SAME resolution rather than
    /// each fetching-then-creating a new cart. The synchronous check-and-store below
    /// runs atomically within the actor, so only the first caller starts the work.
    private func activeCartID(for userID: UUID) async throws -> UUID {
        if let inFlight = activeCartResolution[userID] {
            return try await inFlight.value
        }

        let task = Task { [self] () throws -> UUID in
            try await self.resolveActiveCartID(for: userID)
        }
        activeCartResolution[userID] = task

        do {
            return try await task.value
        } catch {
            // Allow a fresh attempt on the next call if this resolution failed.
            activeCartResolution[userID] = nil
            throw error
        }
    }

    /// Fetches the existing active cart or creates a new one. Only ever invoked by
    /// the memoized task in `activeCartID(for:)`.
    private func resolveActiveCartID(for userID: UUID) async throws -> UUID {
        let cartRows: [SupabaseCartRow] = try await client.database
            .from("carts")
            .select()
            .eq("user_id", value: userID.uuidString)
            .eq("status", value: "active")
            .order("created_at", ascending: false)
            .limit(1)
            .execute()
            .value

        if let existing = cartRows.first {
            return existing.id
        }

        // Create a new active cart
        let newID = UUID()
        let insert = SupabaseCartInsert(
            id: newID,
            user_id: userID,
            budget_paise: nil,
            estimated_eta_minutes: nil,
            near_budget_threshold: 0.9,
            status: "active",
            mission_id: nil
        )

        try await client.database
            .from("carts")
            .insert(insert)
            .execute()

        return newID
    }

    /// Clears any memoized active-cart resolution for a user, forcing the next
    /// `addItem` to re-resolve (used after checkout / delete / replace).
    private func invalidateActiveCartCache(for userID: UUID) {
        activeCartResolution[userID] = nil
    }

    /// Deletes the active cart and its items for a user.
    private func deleteActiveCart(userID: UUID) async throws {
        // Any memoized cart id is about to become invalid.
        invalidateActiveCartCache(for: userID)

        let cartRows: [SupabaseCartRow] = try await client.database
            .from("carts")
            .select()
            .eq("user_id", value: userID.uuidString)
            .eq("status", value: "active")
            .execute()
            .value

        for cartRow in cartRows {
            // Delete items first (FK constraint)
            try await client.database
                .from("cart_items")
                .delete()
                .eq("cart_id", value: cartRow.id.uuidString)
                .execute()

            // Delete cart row
            try await client.database
                .from("carts")
                .delete()
                .eq("id", value: cartRow.id.uuidString)
                .execute()
        }
    }

    /// Updates the `updated_at` timestamp on a cart row.
    private func touchCart(_ cartID: UUID) async throws {
        struct TouchUpdate: Encodable {
            let updated_at: String
        }
        try await client.database
            .from("carts")
            .update(TouchUpdate(updated_at: ISO8601DateFormatter().string(from: Date())))
            .eq("id", value: cartID.uuidString)
            .execute()
    }
}
