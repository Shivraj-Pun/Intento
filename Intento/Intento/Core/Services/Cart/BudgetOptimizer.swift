import Foundation

struct BudgetOptimizer: BudgetOptimizing {

    func fitToBudget(_ cart: Cart, budget: Money) -> Cart {
        guard budget.paise > 0, cart.subtotal > budget else { return cart }

        var items = cart.items
        var subtotal = cart.subtotal

        let trimOrder: [CartItemSource] = [.suggestion, .personalization, .substitution, .generated, .userAdded]

        // First pass: reduce quantities
        for source in trimOrder {
            if subtotal <= budget { break }
            let indices = items.indices.filter { items[$0].source == source }
            let sortedByCost = indices.sorted { items[$0].lineTotal > items[$1].lineTotal }

            for index in sortedByCost {
                if subtotal <= budget { break }
                while items[index].quantity > 1 && subtotal > budget {
                    items[index].quantity -= 1
                    subtotal = subtotal - items[index].product.price
                }
            }
        }

        // Second pass: remove items entirely (except userAdded) if still over budget
        let removeOrder: [CartItemSource] = [.suggestion, .personalization, .substitution, .generated]
        for source in removeOrder {
            if subtotal <= budget { break }
            let indices = items.indices.filter { items[$0].source == source && items[$0].quantity > 0 }
            let sortedByCost = indices.sorted { items[$0].lineTotal > items[$1].lineTotal }

            for index in sortedByCost {
                if subtotal <= budget { break }
                subtotal = subtotal - items[index].lineTotal
                items[index].quantity = 0
            }
        }

        items.removeAll { $0.quantity <= 0 }

        var result = cart
        result.items = items
        result.budget = budget
        return result
    }
}
