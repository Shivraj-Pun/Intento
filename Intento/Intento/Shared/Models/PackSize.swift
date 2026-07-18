//
//  PackSize.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Describes the quantity contained in a single pack of a product,
/// e.g. 500 g, 1 L, 6 pcs.
struct PackSize: Codable, Hashable, Sendable {
    let value: Double
    let unit: MeasurementUnit

    init(value: Double, unit: MeasurementUnit) {
        self.value = value
        self.unit = unit
    }

    /// Human-readable label such as "500 g", "1 L", "6 pcs".
    nonisolated var displayLabel: String {
        let numberString: String
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            numberString = String(Int(value))
        } else {
            numberString = String(format: "%.2g", value)
        }

        switch unit {
        case .piece:
            return "\(numberString) \(value == 1 ? "pc" : "pcs")"
        case .dozen:
            return "\(numberString) dozen"
        case .bunch:
            return "\(numberString) \(value == 1 ? "bunch" : "bunches")"
        default:
            return "\(numberString) \(unit.shortLabel)"
        }
    }
}
