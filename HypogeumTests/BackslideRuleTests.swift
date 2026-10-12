import XCTest
@testable import Hypogeum

final class BackslideRuleTests: XCTestCase {
    func testOneMissDoesNotAscend() {
        XCTAssertEqual(BackslideRule.apply(missedDays: 1), 0)
    }

    func testThreeMissesAscendOneLevel() {
        XCTAssertEqual(BackslideRule.apply(missedDays: 3), 1)
    }

    func testSixMissesAscendTwoLevels() {
        XCTAssertEqual(BackslideRule.apply(missedDays: 6), 2)
    }
}
