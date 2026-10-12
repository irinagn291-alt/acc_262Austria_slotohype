import Foundation

/// YYYYMMDD day stamp from Calendar.startOfDay. Identity for one completion per day.
struct DayKey: Sendable, Hashable, Comparable, Identifiable {
    let raw: Int

    var id: Int { raw }

    init(raw: Int) {
        self.raw = raw
    }

    init(date: Date, calendar: Calendar = .current) {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        raw = year * 10_000 + month * 100 + day
    }

    static func today(calendar: Calendar = .current, now: Date = Date()) -> DayKey {
        DayKey(date: now, calendar: calendar)
    }

    func date(calendar: Calendar = .current) -> Date? {
        var components = DateComponents()
        components.year = raw / 10_000
        components.month = (raw / 100) % 100
        components.day = raw % 100
        return calendar.date(from: components).map { calendar.startOfDay(for: $0) }
    }

    func adding(days: Int, calendar: Calendar) -> DayKey? {
        guard let base = date(calendar: calendar),
              let shifted = calendar.date(byAdding: .day, value: days, to: base)
        else { return nil }
        return DayKey(date: shifted, calendar: calendar)
    }

    /// True when this key is exactly one calendar day after `earlier`.
    func isYesterdayOfSelf(_ earlier: DayKey, calendar: Calendar) -> Bool {
        earlier.adding(days: 1, calendar: calendar) == self
    }

    static func < (lhs: DayKey, rhs: DayKey) -> Bool {
        lhs.raw < rhs.raw
    }

    /// Inclusive gap minus one: yesterday → 0, two days ago → 1.
    static func missedDays(from last: DayKey, to today: DayKey, calendar: Calendar) -> Int {
        guard today > last,
              let start = last.date(calendar: calendar),
              let end = today.date(calendar: calendar)
        else { return 0 }
        let days = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        return max(0, days - 1)
    }
}
