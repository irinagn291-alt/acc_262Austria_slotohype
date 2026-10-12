/// Avatar of the descent. Depth is the current Level index; hero level is computed.
struct Delver: Sendable, Hashable {
    let depth: Int
    let totalXP: Int
    let deepestDepth: Int

    var heroLevel: Int {
        DelverXP.heroLevel(totalXP: totalXP)
    }
}

enum DelverXP: Sendable {
    static let pinValue = 10

    static func heroLevel(totalXP: Int) -> Int {
        1 + totalXP / 100
    }

    static func award(isVaultCrack: Bool) -> Int {
        isVaultCrack ? pinValue * 2 : pinValue
    }
}
