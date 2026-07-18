import XCTest
@testable import Intento

final class IntentParsingTests: XCTestCase {

    func testExtractsPeopleAndBudget() {
        let intent = IntentBuilder.build(from: "Butter chicken for 4 under ₹900")

        XCTAssertEqual(intent.peopleCount, 4)
        XCTAssertEqual(intent.budget, Money(rupees: 900))
        XCTAssertGreaterThan(intent.confidence, 0.5)
    }

    func testInfersDefaultsWhenMissing() {
        let intent = IntentBuilder.build(from: "some snacks")

        XCTAssertEqual(intent.peopleCount, IntentBuilder.defaultPeopleCount)
        XCTAssertTrue(intent.assumptions.contains { $0.key == .peopleCount && $0.wasInferred })
    }

    func testDetectsWordNumbers() {
        let intent = IntentBuilder.build(from: "tacos for six")
        XCTAssertEqual(intent.peopleCount, 6)
    }

    func testDetectsMovieNightOccasion() {
        let intent = IntentBuilder.build(from: "movie night for 3")
        XCTAssertEqual(intent.occasion, .movieNight)
    }

    func testSplitsMultiIntent() {
        let intent = IntentBuilder.build(from: "movie night for 4 + weekly restock")
        XCTAssertTrue(intent.isMultiIntent)
    }

    func testMoneyFormattingRoundsWholeRupees() {
        XCTAssertEqual(Money(rupees: 148).paise, 14800)
        XCTAssertEqual((Money(rupees: 100) * 2).paise, 20000)
    }
}
