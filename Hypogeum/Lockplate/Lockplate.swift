/// Today's working face: three pin seats on the current level.
struct Lockplate: Sendable, Hashable {
    let levelIndex: Int
    let seatedPins: Int
}
