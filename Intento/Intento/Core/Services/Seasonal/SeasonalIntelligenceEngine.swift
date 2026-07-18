import Foundation

struct SeasonalIntelligenceEngine: SeasonalIntelligenceProviding {

    func currentContext(for date: Date) -> SeasonalContext {
        let month = Calendar.current.component(.month, from: date)
        let season = season(forMonth: month)
        let festival = festival(forDate: date, month: month)

        var tags: [String] = [season.rawValue]
        if festival != .none { tags.append(festival.rawValue) }

        return SeasonalContext(date: date, season: season, festival: festival, month: month, activeTags: tags)
    }

    func boostedCategories(for context: SeasonalContext) -> [ProductCategory] {
        var categories: [ProductCategory] = []
        switch context.season {
        case .summer:
            categories.append(contentsOf: [.beverages, .produce])
        case .winter:
            categories.append(contentsOf: [.produce, .pantry])
        case .monsoon:
            categories.append(contentsOf: [.snacks, .beverages])
        case .spring, .autumn:
            categories.append(.produce)
        }
        if context.festival != .none {
            categories.append(contentsOf: [.partySupplies, .snacks, .beverages])
        }
        return Array(Set(categories))
    }

    private func season(forMonth month: Int) -> Season {
        switch month {
        case 12, 1, 2: .winter
        case 3, 4: .spring
        case 5, 6: .summer
        case 7, 8, 9: .monsoon
        default: .autumn
        }
    }

    private func festival(forDate date: Date, month: Int) -> Festival {
        switch month {
        case 10, 11: .diwali
        case 3: .holi
        case 12: .christmas
        case 1: .newYear
        case 8: .independenceDay
        default: .none
        }
    }
}
