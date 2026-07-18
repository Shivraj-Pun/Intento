import XCTest
@testable import Intento

final class BudgetOptimizerTests: XCTestCase {

    private func product(_ sku: String, rupees: Int) -> Product {
        Product(
            sku: sku,
            name: sku,
            category: .snacks,
            packSize: PackSize(value: 1, unit: .piece),
            price: Money(rupees: rupees)
        )
    }

    func testKeepsCartUnchangedWhenWithinBudget() {
        let optimizer = BudgetOptimizer()
        let cart = Cart(items: [
            CartItem(product: product("A", rupees: 100), quantity: 1, source: .generated)
        ], budget: Money(rupees: 500))

        let result = optimizer.fitToBudget(cart, budget: Money(rupees: 500))

        XCTAssertEqual(result.subtotal, Money(rupees: 100))
        XCTAssertEqual(result.items.count, 1)
    }

    func testDropsSuggestionItemsFirst() {
        let optimizer = BudgetOptimizer()
        let cart = Cart(items: [
            CartItem(product: product("CORE", rupees: 400), quantity: 1, source: .generated),
            CartItem(product: product("EXTRA", rupees: 300), quantity: 1, source: .suggestion)
        ])

        let result = optimizer.fitToBudget(cart, budget: Money(rupees: 450))

        XCTAssertTrue(result.items.contains { $0.product.sku == "CORE" })
        XCTAssertFalse(result.items.contains { $0.product.sku == "EXTRA" })
        XCTAssertLessThanOrEqual(result.subtotal, Money(rupees: 450))
    }

    func testReducesQuantityToFit() {
        let optimizer = BudgetOptimizer()
        let cart = Cart(items: [
            CartItem(product: product("ITEM", rupees: 100), quantity: 10, source: .generated)
        ])

        let result = optimizer.fitToBudget(cart, budget: Money(rupees: 350))

        XCTAssertLessThanOrEqual(result.subtotal, Money(rupees: 350))
        XCTAssertGreaterThanOrEqual(result.items.first?.quantity ?? 0, 1)
    }
}
