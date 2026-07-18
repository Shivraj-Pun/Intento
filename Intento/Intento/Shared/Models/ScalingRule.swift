import Foundation

enum RoundingStrategy: String, Codable, Hashable, Sendable {
    case up
    case nearest
    case down

    nonisolated func apply(to rawQuantity: Double) -> Int {
        let rounded: Double
        switch self {
        case .up: rounded = rawQuantity.rounded(.up)
        case .nearest: rounded = rawQuantity.rounded()
        case .down: rounded = rawQuantity.rounded(.down)
        }
        return max(1, Int(rounded))
    }
}

struct ScalingRule: Codable, Hashable, Sendable {
    let category: ProductCategory

    let servingsPerPerson: Double

    let perDayMultiplier: Double

    let rounding: RoundingStrategy

    nonisolated init(
        category: ProductCategory,
        servingsPerPerson: Double,
        perDayMultiplier: Double = 1.0,
        rounding: RoundingStrategy = .up
    ) {
        self.category = category
        self.servingsPerPerson = servingsPerPerson
        self.perDayMultiplier = perDayMultiplier
        self.rounding = rounding
    }
}
