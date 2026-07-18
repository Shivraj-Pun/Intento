import Foundation
import Observation

@MainActor
@Observable
final class GlobalCartViewModel {
    var items: [CartItem] = []
    
    var subtotal: Money {
        items.map { $0.lineTotal }.reduce(.zero, +)
    }
    
    var isEmpty: Bool {
        items.isEmpty
    }
    
    func add(_ product: Product) {
        if let index = items.firstIndex(where: { $0.product.sku == product.sku }) {
            items[index].quantity += 1
        } else {
            items.append(CartItem(id: UUID(), product: product, quantity: 1, source: .userAdded))
        }
    }
    
    func increment(_ item: CartItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].quantity += 1
        }
    }
    
    func decrement(_ item: CartItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            if items[index].quantity > 1 {
                items[index].quantity -= 1
            } else {
                items.remove(at: index)
            }
        }
    }
    
    func remove(_ item: CartItem) {
        items.removeAll { $0.id == item.id }
    }
    
    func placeOrder() -> OrderConfirmation {
        let count = items.reduce(0) { $0 + $1.quantity }
        let total = subtotal
        
        let digits = (0..<6).map { _ in String(Int.random(in: 0...9)) }.joined()
        let confirmation = OrderConfirmation(
            orderNumber: "ORD-\(digits)",
            itemCount: count,
            total: total,
            etaMinutes: 15
        )
        
        items.removeAll()
        return confirmation
    }
}
