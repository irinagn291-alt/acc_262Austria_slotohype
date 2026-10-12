import DequeModule
import Foundation

/// Pure fold of day-keyed marks and stored levels into shaft state and turns.
struct TumblerEngine: Sendable {
    func reconcile(
        state: ShaftSnapshot,
        today: DayKey,
        calendar: Calendar
    ) -> ShaftSnapshot {
        var next = state
        let lastTumbler = state.marks
            .filter { $0.kind == .tumbler }
            .map(\.dayKey)
            .max()

        guard let last = lastTumbler else { return next }

        let missed = DayKey.missedDays(from: last, to: today, calendar: calendar)
        if missed >= 1 {
            next = clearingPins(of: next)
        }
        if missed >= 3 {
            next = applyingBackslide(to: next, missed: missed, last: last, calendar: calendar)
        }
        next = writingTrapIfNeeded(state: next, last: last, today: today, calendar: calendar)
        return next
    }

    func turn(
        on day: DayKey,
        state: ShaftSnapshot,
        calendar: Calendar
    ) -> Result<TurnCommit, BlockedTurn> {
        if state.marks.contains(where: { $0.dayKey == day && $0.kind == .tumbler }) {
            return .failure(.alreadyAlignedToday)
        }

        var working = reconcile(state: state, today: day, calendar: calendar)
        guard var plate = working.level(at: working.delverDepth) else {
            return .failure(.noOpenLockplate)
        }

        let seated = plate.pins + 1
        guard seated <= 3 else {
            return .failure(.noOpenLockplate)
        }

        let weekMarks = working.marks.compactMap(\.asTumbler)
        let window = WeekWindow.containing(day, calendar: calendar)
        let weekCountBefore = window.map { VaultWeek.tumblerCount(marks: weekMarks, window: $0) } ?? 0
        let reached = max(working.delverDepth, working.deepestDepth)
        let vaultTarget = weekCountBefore == 4
            ? working.levels
                .filter { $0.isVault && !$0.cracked && $0.index <= reached }
                .max(by: { $0.index < $1.index })
            : nil
        let cracksThisTurn = vaultTarget != nil
        let xp = DelverXP.award(isVaultCrack: cracksThisTurn)

        let hatchOpens = seated == 3
        var descended = false
        plate = Level(
            index: plate.index,
            pins: seated,
            hatchOpen: hatchOpens || plate.hatchOpen,
            isVault: plate.isVault,
            cracked: plate.cracked || (cracksThisTurn && vaultTarget?.index == plate.index)
        )
        working.replace(plate)
        if let vaultTarget, cracksThisTurn, vaultTarget.index != plate.index {
            working.replace(
                Level(
                    index: vaultTarget.index,
                    pins: vaultTarget.pins,
                    hatchOpen: vaultTarget.hatchOpen,
                    isVault: true,
                    cracked: true
                )
            )
        }

        if hatchOpens {
            let deeper = plate.index + 1
            if working.level(at: deeper) == nil {
                working.levels.append(Level.fresh(index: deeper))
            }
            working.delverDepth = deeper
            working.deepestDepth = max(working.deepestDepth, deeper)
            descended = true
        }

        working.totalXP += xp
        let row = LedgerRow(dayKey: day, levelIndex: plate.index, kind: .tumbler, xp: xp)
        working.upsert(row)

        let pin = SeatedPin(
            mark: TumblerMark(dayKey: day, levelIndex: plate.index, xp: xp),
            pinsAfter: seated,
            hatchOpened: hatchOpens,
            descended: descended,
            vaultCracked: cracksThisTurn,
            xpAwarded: xp
        )
        return .success(TurnCommit(snapshot: working, outcome: pin, inserted: row))
    }

    func streak(endingAt day: DayKey, marks: [LedgerRow], calendar: Calendar) -> Int {
        let tumblers = Set(marks.filter { $0.kind == .tumbler }.map(\.dayKey))
        var cursor = day
        if !tumblers.contains(cursor) {
            guard let yesterday = day.adding(days: -1, calendar: calendar),
                  tumblers.contains(yesterday)
            else { return 0 }
            cursor = yesterday
        }
        var count = 0
        while tumblers.contains(cursor) {
            count += 1
            guard let previous = cursor.adding(days: -1, calendar: calendar) else { break }
            cursor = previous
        }
        return count
    }

    func longestStreak(marks: [LedgerRow], calendar: Calendar) -> Int {
        let days = marks.filter { $0.kind == .tumbler }.map(\.dayKey).sorted()
        var best = 0
        var run = 0
        var previous: DayKey?
        for day in days {
            if let previous, day.isYesterdayOfSelf(previous, calendar: calendar) {
                run += 1
            } else {
                run = 1
            }
            best = max(best, run)
            previous = day
        }
        return best
    }

    private func clearingPins(of state: ShaftSnapshot) -> ShaftSnapshot {
        var next = state
        guard var plate = next.level(at: next.delverDepth) else { return next }
        plate = Level(
            index: plate.index,
            pins: 0,
            hatchOpen: plate.hatchOpen,
            isVault: plate.isVault,
            cracked: plate.cracked
        )
        next.replace(plate)
        return next
    }

    private func applyingBackslide(
        to state: ShaftSnapshot,
        missed: Int,
        last: DayKey,
        calendar: Calendar
    ) -> ShaftSnapshot {
        var next = state
        let owed = BackslideRule.apply(missedDays: missed)
        guard owed > 0 else { return next }
        let recorded = next.marks.filter { $0.kind == .backslide && $0.dayKey > last }.count
        let pending = owed - recorded
        guard pending > 0 else { return next }

        for offset in 0..<pending {
            let preferred = last.adding(days: 3 * (recorded + offset + 1), calendar: calendar) ?? last
            guard let stamp = openDay(after: last, preferred: preferred, marks: next.marks, calendar: calendar) else {
                break
            }
            let newDepth = max(0, next.delverDepth - 1)
            if newDepth != next.delverDepth, var left = next.level(at: next.delverDepth) {
                left = Level(
                    index: left.index,
                    pins: left.pins,
                    hatchOpen: false,
                    isVault: left.isVault,
                    cracked: left.cracked
                )
                next.replace(left)
            }
            next.delverDepth = newDepth
            if var current = next.level(at: newDepth) {
                current = Level(
                    index: current.index,
                    pins: 0,
                    hatchOpen: false,
                    isVault: current.isVault,
                    cracked: current.cracked
                )
                next.replace(current)
            }
            next.upsert(LedgerRow(dayKey: stamp, levelIndex: newDepth, kind: .backslide, xp: 0))
        }
        return next
    }

    /// A free day after the last tumbler. The journal row is what stops the same gap from climbing again.
    private func openDay(
        after last: DayKey,
        preferred: DayKey,
        marks: [LedgerRow],
        calendar: Calendar
    ) -> DayKey? {
        if preferred > last, !marks.contains(where: { $0.dayKey == preferred }) {
            return preferred
        }
        var cursor = preferred
        for _ in 0..<21 {
            guard let earlier = cursor.adding(days: -1, calendar: calendar), earlier > last else { break }
            if !marks.contains(where: { $0.dayKey == earlier }) { return earlier }
            cursor = earlier
        }
        cursor = preferred
        for _ in 0..<21 {
            guard let later = cursor.adding(days: 1, calendar: calendar) else { break }
            if !marks.contains(where: { $0.dayKey == later }) { return later }
            cursor = later
        }
        return nil
    }

    private func writingTrapIfNeeded(
        state: ShaftSnapshot,
        last: DayKey,
        today: DayKey,
        calendar: Calendar
    ) -> ShaftSnapshot {
        var next = state
        guard let lastWindow = WeekWindow.containing(last, calendar: calendar),
              let todayWindow = WeekWindow.containing(today, calendar: calendar),
              lastWindow != todayWindow
        else { return next }

        let weekMarks = next.marks.compactMap(\.asTumbler)
        if VaultWeek.crack(marks: weekMarks, window: lastWindow) {
            return next
        }

        let missedVaults = next.levels.filter { level in
            level.isVault && !level.cracked && level.index <= next.deepestDepth
        }
        guard !missedVaults.isEmpty else { return next }

        for vault in missedVaults {
            let already = next.marks.contains { row in
                row.kind == .trap && row.levelIndex == vault.index && lastWindow.contains(row.dayKey)
            }
            if already { continue }
            guard let stamp = openDay(after: lastWindow.start.adding(days: -1, calendar: calendar) ?? lastWindow.start, preferred: lastWindow.end, marks: next.marks, calendar: calendar),
                  lastWindow.contains(stamp)
            else { continue }
            next.upsert(LedgerRow(dayKey: stamp, levelIndex: vault.index, kind: .trap, xp: 0))
        }
        return next
    }
}

struct ShaftSnapshot: Sendable {
    var levels: Deque<Level>
    var marks: [LedgerRow]
    var totalXP: Int
    var delverDepth: Int
    var deepestDepth: Int

    init(
        levels: some Sequence<Level>,
        marks: [LedgerRow],
        totalXP: Int,
        delverDepth: Int,
        deepestDepth: Int
    ) {
        self.levels = Deque(levels)
        self.marks = marks
        self.totalXP = totalXP
        self.delverDepth = delverDepth
        self.deepestDepth = deepestDepth
    }

    var delver: Delver {
        Delver(depth: delverDepth, totalXP: totalXP, deepestDepth: deepestDepth)
    }

    func level(at index: Int) -> Level? {
        levels.first(where: { $0.index == index })
    }

    mutating func replace(_ level: Level) {
        if let idx = levels.firstIndex(where: { $0.index == level.index }) {
            levels[idx] = level
        } else if let first = levels.first, level.index < first.index {
            levels.prepend(level)
        } else {
            levels.append(level)
        }
    }

    mutating func upsert(_ row: LedgerRow) {
        marks.removeAll { $0.dayKey == row.dayKey }
        marks.append(row)
        marks.sort { $0.dayKey < $1.dayKey }
    }
}

struct SeatedPin: Sendable, Equatable {
    let mark: TumblerMark
    let pinsAfter: Int
    let hatchOpened: Bool
    let descended: Bool
    let vaultCracked: Bool
    let xpAwarded: Int
}

enum BlockedTurn: Error, Sendable, Equatable {
    case alreadyAlignedToday
    case noOpenLockplate
}

struct TurnCommit: Sendable {
    let snapshot: ShaftSnapshot
    let outcome: SeatedPin
    let inserted: LedgerRow
}
