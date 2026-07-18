import Foundation

struct SavedMission: Identifiable, Codable, Hashable, Sendable {
    let id: UUID

    var title: String

    var rawIntentText: String

    var intent: ShoppingIntent?

    var cartSnapshot: Cart?

    var occasion: Occasion?
    let createdAt: Date
    var lastUsedAt: Date?

    var timesUsed: Int

    var isPinned: Bool

    nonisolated init(
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
