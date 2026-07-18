import Foundation

protocol SeasonalIntelligenceProviding: Sendable {
    func currentContext(for date: Date) -> SeasonalContext

    func boostedCategories(for context: SeasonalContext) -> [ProductCategory]
}
