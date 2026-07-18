import Foundation

enum Occasion: String, Codable, CaseIterable, Hashable, Sendable, Identifiable {
    case everyday
    case weeklyRestock = "weekly_restock"
    case breakfast
    case dinnerParty = "dinner_party"
    case movieNight = "movie_night"
    case birthday
    case festival
    case guestsOver = "guests_over"
    case babyCare = "baby_care"
    case illness
    case picnic
    case cleaning

    nonisolated var id: String { rawValue }

    nonisolated var displayName: String {
        switch self {
        case .everyday: "Everyday"
        case .weeklyRestock: "Weekly Restock"
        case .breakfast: "Breakfast"
        case .dinnerParty: "Dinner Party"
        case .movieNight: "Movie Night"
        case .birthday: "Birthday"
        case .festival: "Festival"
        case .guestsOver: "Guests Over"
        case .babyCare: "Baby Care"
        case .illness: "Illness / Recovery"
        case .picnic: "Picnic"
        case .cleaning: "Cleaning Day"
        }
    }
}
