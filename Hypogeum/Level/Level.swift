/// One depth in the shaft. Pins 0...3, hatch flag, vault on every fifth index.
struct Level: Sendable, Hashable, Identifiable {
    let index: Int
    let pins: Int
    let hatchOpen: Bool
    let isVault: Bool
    let cracked: Bool

    var id: Int { index }

    var pinCount: PinCount {
        PinCount(pins) ?? .empty
    }

    static func isVaultIndex(_ index: Int) -> Bool {
        (index + 1) % 5 == 0
    }

    static func fresh(index: Int, pins: Int = 0) -> Level {
        Level(
            index: index,
            pins: pins,
            hatchOpen: false,
            isVault: isVaultIndex(index),
            cracked: false
        )
    }
}
