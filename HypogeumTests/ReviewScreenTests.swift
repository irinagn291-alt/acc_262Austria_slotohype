import XCTest
@testable import Hypogeum

final class ReviewScreenTests: XCTestCase {
    func testParsesTodayLogGoalsAndSettings() {
        XCTAssertEqual(ReviewScreen.parse(arguments: ["-ReviewScreen", "today"]), .today)
        XCTAssertEqual(ReviewScreen.parse(arguments: ["-ReviewScreen", "log"]), .log)
        XCTAssertEqual(ReviewScreen.parse(arguments: ["-ReviewScreen", "goals"]), .goals)
        XCTAssertEqual(ReviewScreen.parse(arguments: ["-ReviewScreen", "settings"]), .settings)
    }

    func testMissingValueIsNil() {
        XCTAssertNil(ReviewScreen.parse(arguments: ["-ReviewScreen"]))
        XCTAssertNil(ReviewScreen.parse(arguments: []))
    }
}
