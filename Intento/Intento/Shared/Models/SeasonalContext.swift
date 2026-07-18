import Foundation

enum Season: String, Codable, CaseIterable, Hashable, Sendable {
    case winter
    case summer
    case monsoon
    case spring
    case autumn

    nonisolated var displayName: String { rawValue.capitalized }
}

enum Festival: String, Codable, CaseIterable, Hashable, Sendable {
    case none
    case diwali
    case holi
    case christmas
    case eid
    case newYear = "new_year"
    case independenceDay = "independence_day"
    case raksha = "raksha_bandhan"

    nonisolated var displayName: String {
        switch self {
        case .none: "None"
        case .diwali: "Diwali"
        case .holi: "Holi"
        case .christmas: "Christmas"
        case .eid: "Eid"
        case .newYear: "New Year"
        case .independenceDay: "Independence Day"
        case .raksha: "Raksha Bandhan"
        }
    }
}

struct SeasonalContext: Codable, Hashable, Sendable {
    let date: Date
    let season: Season
    let festival: Festival
    let month: Int

    let activeTags: [String]

    nonisolated init(
        date: Date,
        season: Season,
        festival: Festival = .none,
        month: Int,
        activeTags: [String] = []
    ) {
        self.date = date
        self.season = season
        self.festival = festival
        self.month = month
        self.activeTags = activeTags
    }
}
