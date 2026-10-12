/// Dated completion row. dayKey is the one-completion-per-day identity.
struct TumblerMark: Sendable, Hashable, Identifiable {
    let dayKey: DayKey
    let levelIndex: Int
    let xp: Int

    var id: Int { dayKey.raw }
}
