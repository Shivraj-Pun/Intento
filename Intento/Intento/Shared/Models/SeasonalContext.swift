//
//  SeasonalContext.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Coarse seasons used by the seasonal intelligence rules engine (Phase 2).
enum Season: String, Codable, CaseIterable, Hashable, Sendable {
    case winter
    case summer
    case monsoon
    case spring
    case autumn

    nonisolated var displayName: String { rawValue.capitalized }
}

/// Festivals/events that can bias suggestions.
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

/// A snapshot of local seasonal/occasion context, produced by
/// `SeasonalIntelligenceProviding` from simple local rules (no live weather
/// dependency required). Pure data model.
struct SeasonalContext: Codable, Hashable, Sendable {
    let date: Date
    let season: Season
    let festival: Festival
    let month: Int

    /// Free-form tags matched against `Product.seasonalTags` for biasing.
    let activeTags: [String]

    init(
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
