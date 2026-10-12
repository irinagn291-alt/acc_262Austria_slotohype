import XCTest
@testable import Hypogeum

final class DayKeyTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        calendar.firstWeekday = 2
        return calendar
    }

    func testYYYYMMDDFromStartOfDay() {
        var components = DateComponents()
        components.year = 2026
        components.month = 3
        components.day = 15
        let date = calendar.date(from: components) ?? Date.distantPast
        XCTAssertEqual(DayKey(date: date, calendar: calendar).raw, 20_260_315)
    }

    func testMissedDaysBetweenNeighboursIsZero() {
        let monday = DayKey(raw: 20_260_302)
        let tuesday = DayKey(raw: 20_260_303)
        XCTAssertEqual(DayKey.missedDays(from: monday, to: tuesday, calendar: calendar), 0)
        XCTAssertTrue(tuesday.isYesterdayOfSelf(monday, calendar: calendar))
    }

    func testThreeCalendarGapsAreThreeMisses() {
        let first = DayKey(raw: 20_260_301)
        let fifth = DayKey(raw: 20_260_305)
        XCTAssertEqual(DayKey.missedDays(from: first, to: fifth, calendar: calendar), 3)
    }
}
