import Foundation

struct Money: Codable, Hashable, Comparable, Sendable {

    private(set) var paise: Int

    nonisolated init(paise: Int) {
        self.paise = paise
    }

    nonisolated init(rupees: Double) {
        self.paise = Int((rupees * 100).rounded())
    }

    nonisolated init(rupees: Int) {
        self.paise = rupees * 100
    }

    nonisolated var rupees: Double {
        Double(paise) / 100.0
    }

    nonisolated static let zero = Money(paise: 0)

    nonisolated static func < (lhs: Money, rhs: Money) -> Bool {
        lhs.paise < rhs.paise
    }

    nonisolated static func + (lhs: Money, rhs: Money) -> Money {
        Money(paise: lhs.paise + rhs.paise)
    }

    nonisolated static func - (lhs: Money, rhs: Money) -> Money {
        Money(paise: lhs.paise - rhs.paise)
    }

    nonisolated static func * (lhs: Money, quantity: Int) -> Money {
        Money(paise: lhs.paise * quantity)
    }

    nonisolated static func * (lhs: Money, factor: Double) -> Money {
        Money(paise: Int((Double(lhs.paise) * factor).rounded()))
    }

    nonisolated func formatted(currencyCode: String = "INR",
                               localeIdentifier: String = "en_IN") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.locale = Locale(identifier: localeIdentifier)
        formatter.maximumFractionDigits = (paise % 100 == 0) ? 0 : 2
        return formatter.string(from: NSNumber(value: rupees)) ?? "₹\(rupees)"
    }

    nonisolated var displayString: String {
        formatted()
    }
}
