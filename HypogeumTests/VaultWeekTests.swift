import XCTest
@testable import Hypogeum

final class VaultWeekTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        calendar.firstWeekday = 2
        return calendar
    }

    func testFiveMarksInTheSameWeekCrack() throws {
        let window = try XCTUnwrap(WeekWindow.containing(DayKey(raw: 20_260_302), calendar: calendar))
        let marks = (0..<5).compactMap { offset -> TumblerMark? in
            guard let day = window.start.adding(days: offset, calendar: calendar) else { return nil }
            return TumblerMark(dayKey: day, levelIndex: 4, xp: 10)
        }
        XCTAssertEqual(marks.count, 5)
        XCTAssertTrue(VaultWeek.crack(marks: marks, window: window))
    }

    func testFourMarksDoNotCrack() throws {
        let window = try XCTUnwrap(WeekWindow.containing(DayKey(raw: 20_260_302), calendar: calendar))
        let marks = (0..<4).compactMap { offset -> TumblerMark? in
            guard let day = window.start.adding(days: offset, calendar: calendar) else { return nil }
            return TumblerMark(dayKey: day, levelIndex: 4, xp: 10)
        }
        XCTAssertFalse(VaultWeek.crack(marks: marks, window: window))
    }
}
