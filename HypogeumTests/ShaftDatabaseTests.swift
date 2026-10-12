import XCTest
@testable import Hypogeum

final class ShaftDatabaseTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        calendar.firstWeekday = 2
        return calendar
    }

    func testTurnSurvivesReload() async throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("hyp-roundtrip-\(UUID().uuidString).sqlite")
        defer { try? FileManager.default.removeItem(at: url) }

        let day = DayKey(raw: 20_260_311)
        let first = try ShaftDatabase(fileURL: url)
        let result = try await first.performTurn(on: day, calendar: calendar)
        guard case .success(let commit) = result else {
            return XCTFail("turn should persist")
        }
        XCTAssertEqual(commit.outcome.xpAwarded, DelverXP.pinValue)

        let reopened = try ShaftDatabase(fileURL: url)
        let snapshot = try await reopened.loadSnapshot()
        XCTAssertEqual(snapshot.totalXP, DelverXP.pinValue)
        XCTAssertEqual(snapshot.marks.count, 1)
        XCTAssertEqual(snapshot.marks.first?.dayKey, day)
        XCTAssertEqual(snapshot.level(at: 0)?.pins, 1)
    }

    func testResetAllDataClearsMarks() async throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("hyp-reset-\(UUID().uuidString).sqlite")
        defer { try? FileManager.default.removeItem(at: url) }

        let store = try ShaftDatabase(fileURL: url)
        _ = try await store.performTurn(on: DayKey(raw: 20_260_311), calendar: calendar)
        try await store.resetAllData()
        let snapshot = try await store.loadSnapshot()
        XCTAssertTrue(snapshot.marks.isEmpty)
        XCTAssertEqual(snapshot.totalXP, 0)
        XCTAssertEqual(snapshot.delverDepth, 0)
        XCTAssertEqual(snapshot.level(at: 0)?.pins, 0)
    }

    func testPrimaryKeyBlocksSecondMarkTheSameDay() async throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("hyp-once-\(UUID().uuidString).sqlite")
        defer { try? FileManager.default.removeItem(at: url) }

        let store = try ShaftDatabase(fileURL: url)
        let day = DayKey(raw: 20_260_311)
        _ = try await store.performTurn(on: day, calendar: calendar)
        let second = try await store.performTurn(on: day, calendar: calendar)
        guard case .failure(let reason) = second else {
            return XCTFail("storage must keep one completion per day")
        }
        XCTAssertEqual(reason, .alreadyAlignedToday)
    }
}
