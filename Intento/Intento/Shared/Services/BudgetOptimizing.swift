import Foundation

protocol BudgetOptimizing: Sendable {
    func fitToBudget(_ cart: Cart, budget: Money) -> Cart
}
