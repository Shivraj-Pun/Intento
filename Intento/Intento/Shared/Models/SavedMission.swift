//
//  SavedMission.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// A remembered shopping mission used for personalization and the Home screen
/// "recent missions" / "Time for your Sunday Restock?" surfaces.
///
/// This is a pure `Codable` domain model. The persistence layer (Phase 2,
/// SwiftData) maps to/from its own `@Model` entity so the domain stays free of
/// any storage-framework dependency.
struct SavedMission: Identifiable, Codable, Hashable, Sendable {
    let id: UUID

    /// Short human-readable title, e.g. "Butter chicken for 4".
    var title: String

    /// The original request text.
    var rawIntentText: String

    /// The structured intent, when available.
    var intent: ShoppingIntent?

    /// A snapshot of the cart that was generated/checked out for this mission.
    var cartSnapshot: Cart?

    var occasion: Occasion?
    let createdAt: Date
    var lastUsedAt: Date?

    /// Number of times this mission has been reused.
    var timesUsed: Int

    /// Whether the user pinned this mission for quick access.
    var isPinned: Bool

    init(
        id: UUID = UUID(),
        title: String,
        rawIntentText: String,
        intent: ShoppingIntent? = nil,
        cartSnapshot: Cart? = nil,
        occasion: Occasion? = nil,
        createdAt: Date = Date(),
        lastUsedAt: Date? = nil,
        timesUsed: Int = 0,
        isPinned: Bool = false
    ) {
        self.id = id
        self.title = title
        self.rawIntentText = rawIntentText
        self.intent = intent
        self.cartSnapshot = cartSnapshot
        self.occasion = occasion
        self.createdAt = createdAt
        self.lastUsedAt = lastUsedAt
        self.timesUsed = timesUsed
        self.isPinned = isPinned
    }
}
