import Foundation

/// Calendar week bounds used to gate the vault boss.
struct WeekWindow: Sendable, Equatable {
    let start: DayKey
    let end: DayKey

    static func containing(_ day: DayKey, calendar: Calendar) -> WeekWindow? {
        guard let date = day.date(calendar: calendar) else { return nil }
        let startOfDay = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: startOfDay)
        let firstWeekday = calendar.firstWeekday
        var delta = weekday - firstWeekday
        if delta < 0 { delta += 7 }
        guard let weekStart = calendar.date(byAdding: .day, value: -delta, to: startOfDay),
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)
        else { return nil }
        return WeekWindow(
            start: DayKey(date: weekStart, calendar: calendar),
            end: DayKey(date: weekEnd, calendar: calendar)
        )
    }

    func contains(_ day: DayKey) -> Bool {
        day >= start && day <= end
    }
}
