/// Seated pins on one lockplate. Stored range is 0...3.
struct PinCount: Sendable, Hashable {
    let value: Int

    init?(_ value: Int) {
        guard (0...3).contains(value) else { return nil }
        self.value = value
    }

    static let empty = PinCount(0) ?? PinCount(unchecked: 0)

    /// Programmer error: only used after a CHECK or a prior validated count.
    fileprivate init(unchecked value: Int) {
        self.value = value
    }

    func seatingOne() -> PinCount? {
        PinCount(value + 1)
    }
}

struct Pin: Sendable, Hashable, Identifiable {
    let seat: Int

    var id: Int { seat }
}
