import XCTest
@testable import Hypogeum

final class TumblerEngineTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        calendar.firstWeekday = 2
        return calendar
    }

    private let engine = TumblerEngine()

    func testOneCompletionPerDay() {
        var state = Self.emptyShaft()
        let day = DayKey(raw: 20_260_301)
        guard case .success(let first) = engine.turn(on: day, state: state, calendar: calendar) else {
            return XCTFail("first turn should seat")
        }
        state = first.snapshot
        guard case .failure(let reason) = engine.turn(on: day, state: state, calendar: calendar) else {
            return XCTFail("second turn the same day must block")
        }
        XCTAssertEqual(reason, .alreadyAlignedToday)
    }

    func testStreakContinuesOnlyFromYesterday() {
        var state = Self.emptyShaft()
        let monday = DayKey(raw: 20_260_302)
        let wednesday = DayKey(raw: 20_260_304)
        guard case .success(let first) = engine.turn(on: monday, state: state, calendar: calendar) else {
            return XCTFail("monday")
        }
        state = first.snapshot
        guard case .success(let second) = engine.turn(on: wednesday, state: state, calendar: calendar) else {
            return XCTFail("wednesday")
        }
        XCTAssertEqual(engine.streak(endingAt: wednesday, marks: second.snapshot.marks, calendar: calendar), 1)
        XCTAssertEqual(second.snapshot.levels.first?.pins, 1)
    }

    func testThirdConsecutivePinOpensHatchAndDescends() {
        var state = Self.emptyShaft()
        let days = [20_260_301, 20_260_302, 20_260_303].map(DayKey.init(raw:))
        var last: TurnCommit?
        for day in days {
            guard case .success(let commit) = engine.turn(on: day, state: state, calendar: calendar) else {
                return XCTFail("turn \(day.raw)")
            }
            state = commit.snapshot
            last = commit
        }
        XCTAssertEqual(last?.outcome.pinsAfter, 3)
        XCTAssertEqual(last?.outcome.hatchOpened, true)
        XCTAssertEqual(last?.outcome.descended, true)
        XCTAssertEqual(state.delverDepth, 1)
    }

    func testXPAndHeroLevel() {
        var state = Self.emptyShaft()
        guard case .success(let commit) = engine.turn(on: DayKey(raw: 20_260_301), state: state, calendar: calendar) else {
            return XCTFail("turn")
        }
        state = commit.snapshot
        XCTAssertEqual(commit.outcome.xpAwarded, DelverXP.pinValue)
        XCTAssertEqual(state.totalXP, DelverXP.pinValue)
        XCTAssertEqual(state.delver.heroLevel, 1 + state.totalXP / 100)
    }

    func testMissClearsPinsAndThreeMissesBackslide() {
        var state = Self.emptyShaft()
        let firstDays = [20_260_301, 20_260_302, 20_260_303].map(DayKey.init(raw:))
        for day in firstDays {
            guard case .success(let commit) = engine.turn(on: day, state: state, calendar: calendar) else {
                return XCTFail("seed descent")
            }
            state = commit.snapshot
        }
        XCTAssertEqual(state.delverDepth, 1)
        let afterGap = DayKey(raw: 20_260_307)
        let reconciled = engine.reconcile(state: state, today: afterGap, calendar: calendar)
        XCTAssertEqual(reconciled.delverDepth, 0)
        XCTAssertTrue(reconciled.marks.contains(where: { $0.kind == .backslide }))
        XCTAssertEqual(reconciled.level(at: 0)?.pins, 0)
        XCTAssertEqual(reconciled.level(at: 0)?.hatchOpen, false)
    }

    func testVaultFifthMarkDoublesXP() {
        var state = ShaftSnapshot(
            levels: [Level.fresh(index: 4)],
            marks: [],
            totalXP: 0,
            delverDepth: 4,
            deepestDepth: 4
        )
        let start = DayKey(raw: 20_260_302)
        var lastXP = 0
        for offset in 0..<5 {
            guard let day = start.adding(days: offset, calendar: calendar) else {
                return XCTFail("day")
            }
            guard case .success(let commit) = engine.turn(on: day, state: state, calendar: calendar) else {
                return XCTFail("vault turn")
            }
            state = commit.snapshot
            lastXP = commit.outcome.xpAwarded
        }
        XCTAssertEqual(lastXP, DelverXP.pinValue * 2)
        XCTAssertEqual(state.level(at: 4)?.cracked, true)
    }

    func testOpenMissGapBackslidesOnce() {
        var state = Self.emptyShaft()
        let firstDays = [20_260_301, 20_260_302, 20_260_303].map(DayKey.init(raw:))
        for day in firstDays {
            guard case .success(let commit) = engine.turn(on: day, state: state, calendar: calendar) else {
                return XCTFail("seed descent")
            }
            state = commit.snapshot
        }
        let afterGap = DayKey(raw: 20_260_307)
        let once = engine.reconcile(state: state, today: afterGap, calendar: calendar)
        let twice = engine.reconcile(state: once, today: afterGap, calendar: calendar)
        XCTAssertEqual(once.delverDepth, 0)
        XCTAssertEqual(twice.delverDepth, once.delverDepth)
        XCTAssertEqual(twice.marks.filter { $0.kind == .backslide }.count, 1)
    }

    func testFifthWeekMarkWithoutAVaultKeepsSingleXP() {
        var state = Self.emptyShaft()
        let monday = DayKey(raw: 20_260_302)
        var lastXP = 0
        for offset in 0..<5 {
            guard let day = monday.adding(days: offset, calendar: calendar) else {
                return XCTFail("day")
            }
            guard case .success(let commit) = engine.turn(on: day, state: state, calendar: calendar) else {
                return XCTFail("week turn")
            }
            state = commit.snapshot
            lastXP = commit.outcome.xpAwarded
        }
        XCTAssertEqual(lastXP, DelverXP.pinValue)
        XCTAssertFalse(state.levels.contains(where: \.cracked))
    }

    func testWeekEndTrapCoversEveryMissedVaultWhenEndDayIsTaken() throws {
        let monday = DayKey(raw: 20_260_302)
        let sunday = try XCTUnwrap(monday.adding(days: 6, calendar: calendar))
        let nextMonday = DayKey(raw: 20_260_309)
        let state = ShaftSnapshot(
            levels: [Level.fresh(index: 4), Level.fresh(index: 9)],
            marks: [
                LedgerRow(dayKey: monday, levelIndex: 9, kind: .tumbler, xp: 10),
                LedgerRow(dayKey: sunday, levelIndex: 9, kind: .backslide, xp: 0)
            ],
            totalXP: 10,
            delverDepth: 9,
            deepestDepth: 9
        )
        let once = engine.reconcile(state: state, today: nextMonday, calendar: calendar)
        let traps = once.marks.filter { $0.kind == .trap }
        XCTAssertEqual(Set(traps.map(\.levelIndex)), [4, 9])
        XCTAssertTrue(once.marks.contains { $0.dayKey == sunday && $0.kind == .backslide })
        let twice = engine.reconcile(state: once, today: nextMonday, calendar: calendar)
        XCTAssertEqual(twice.marks.filter { $0.kind == .trap }.count, traps.count)
    }

    private static func emptyShaft() -> ShaftSnapshot {
        ShaftSnapshot(
            levels: [Level.fresh(index: 0)],
            marks: [],
            totalXP: 0,
            delverDepth: 0,
            deepestDepth: 0
        )
    }
}
