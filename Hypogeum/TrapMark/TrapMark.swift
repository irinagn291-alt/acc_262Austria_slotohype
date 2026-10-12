/// Week-end vault miss. Same ledger as tumbler rows, distinct kind.
struct TrapMark: Sendable, Hashable, Identifiable {
    let dayKey: DayKey
    let levelIndex: Int

    var id: Int { dayKey.raw }
}

enum LedgerKind: String, Sendable {
    case tumbler
    case trap
    case backslide
}

struct LedgerRow: Sendable, Hashable, Identifiable {
    let dayKey: DayKey
    let levelIndex: Int
    let kind: LedgerKind
    let xp: Int

    var id: Int { dayKey.raw }

    var asTumbler: TumblerMark? {
        guard kind == .tumbler else { return nil }
        return TumblerMark(dayKey: dayKey, levelIndex: levelIndex, xp: xp)
    }

    var asTrap: TrapMark? {
        guard kind == .trap else { return nil }
        return TrapMark(dayKey: dayKey, levelIndex: levelIndex)
    }
}
