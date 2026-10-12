/// Gate between two depths. Three consecutive pins open it.
struct Hatch: Sendable, Hashable {
    let levelIndex: Int
    let isOpen: Bool
}
