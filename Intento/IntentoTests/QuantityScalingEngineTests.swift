import XCTest
@testable import Intento

final class QuantityScalingEngineTests: XCTestCase {

    private func makeProduct(category: ProductCategory, servingsPerPack: Double?) -> Product {
        Product(
            sku: "TEST",
            name: "Test",
            category: category,
            packSize: PackSize(value: 1, unit: .piece),
            price: Money(rupees: 100),
            servingsPerPack: servingsPerPack
        )
    }

    private func makeIntent(people: Int?, durationDays: Int?) -> ShoppingIntent {
        ShoppingIntent(rawText: "test", goal: "test", peopleCount: people, durationDays: durationDays)
    }

    func testScalesWithHeadcount() {
        let engine = QuantityScalingEngine()
        let product = makeProduct(category: .snacks, servingsPerPack: 2)
        let intent = makeIntent(people: 6, durationDays: nil)

        let quantity = engine.recommendedQuantity(for: product, intent: intent)

        XCTAssertEqual(quantity, 4)
    }

    func testNeverReturnsLessThanOne() {
        let engine = QuantityScalingEngine()
        let product = makeProduct(category: .pantry, servingsPerPack: 100)
        let intent = makeIntent(people: 1, durationDays: nil)

        XCTAssertGreaterThanOrEqual(engine.recommendedQuantity(for: product, intent: intent), 1)
    }

    func testDurationIncreasesQuantity() {
        let engine = QuantityScalingEngine()
        let product = makeProduct(category: .dairy, servingsPerPack: 4)

        let single = engine.recommendedQuantity(for: product, intent: makeIntent(people: 4, durationDays: 1))
        let weekly = engine.recommendedQuantity(for: product, intent: makeIntent(people: 4, durationDays: 7))

        XCTAssertGreaterThan(weekly, single)
    }

    func testMissingServingsFallsBackToRule() {
        let engine = QuantityScalingEngine()
        let product = makeProduct(category: .beverages, servingsPerPack: nil)
        let intent = makeIntent(people: 3, durationDays: nil)

        XCTAssertGreaterThanOrEqual(engine.recommendedQuantity(for: product, intent: intent), 1)
    }
}
