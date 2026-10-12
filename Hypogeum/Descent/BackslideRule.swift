/// Twist: three consecutive missed days ascend the delver one level per trio.
struct BackslideRule: Sendable {
    static func apply(missedDays: Int) -> Int {
        max(0, missedDays / 3)
    }
}
