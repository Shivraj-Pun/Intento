//
//  Money.swift
//  Intento (Ask Blinkit)
//
//  A precise monetary value type for Indian Rupee amounts.
//

import Foundation

/// A precise monetary value stored in integer minor units (paise) to avoid
/// floating-point rounding errors in budget calculations.
///
/// Pure value type with no UI dependency, fully unit-testable.
struct Money: Codable, Hashable, Comparable, Sendable {

    /// Amount in paise (1 rupee = 100 paise).
    private(set) var paise: Int

    init(paise: Int) {
        self.paise = paise
    }

    init(rupees: Double) {
        self.paise = Int((rupees * 100).rounded())
    }

    init(rupees: Int) {
        self.paise = rupees * 100
    }

    /// The value expressed in rupees.
    nonisolated var rupees: Double {
        Double(paise) / 100.0
    }

    static let zero = Money(paise: 0)

    // MARK: - Comparable / Arithmetic

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

    // MARK: - Formatting

    /// Localised currency string, e.g. "₹1,299" or "₹66.50".
    nonisolated func formatted(currencyCode: String = "INR",
                               localeIdentifier: String = "en_IN") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.locale = Locale(identifier: localeIdentifier)
        formatter.maximumFractionDigits = (paise % 100 == 0) ? 0 : 2
        return formatter.string(from: NSNumber(value: rupees)) ?? "₹\(rupees)"
    }

    /// Convenience formatted string using default Indian Rupee locale.
    nonisolated var displayString: String {
        formatted()
    }
}
