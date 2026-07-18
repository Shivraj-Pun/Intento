import Foundation

protocol NutritionAdvising: Sendable {
    func healthierAlternative(for product: Product, within budget: Money?) async throws -> Product?
}
