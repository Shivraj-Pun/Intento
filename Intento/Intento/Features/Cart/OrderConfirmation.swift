import Foundation

struct OrderConfirmation: Identifiable, Hashable, Sendable {
    let id: UUID
    let orderNumber: String
    let itemCount: Int
    let total: Money
    let etaMinutes: Int?
    let placedAt: Date

    init(id: UUID = UUID(), orderNumber: String, itemCount: Int, total: Money, etaMinutes: Int?, placedAt: Date = Date()) {
        self.id = id
        self.orderNumber = orderNumber
        self.itemCount = itemCount
        self.total = total
        self.etaMinutes = etaMinutes
        self.placedAt = placedAt
    }
}
