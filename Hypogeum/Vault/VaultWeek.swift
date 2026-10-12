/// Calendar-week gate for the vault. Five tumbler marks crack it for double XP.
struct VaultWeek: Sendable {
    static func crack(marks: [TumblerMark], window: WeekWindow) -> Bool {
        marks.filter { window.contains($0.dayKey) }.count >= 5
    }

    static func tumblerCount(marks: [TumblerMark], window: WeekWindow) -> Int {
        marks.filter { window.contains($0.dayKey) }.count
    }
}
