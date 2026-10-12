enum ShaftStoreError: Error, Sendable, Equatable {
    case open(Int32)
    case prepare(Int32, String)
    case bind(Int32)
    case step(Int32, String)
    case exec(Int32, String)
    case unexpectedNull
}

enum MetaKey {
    static let totalXP = "total_xp"
    static let delverDepth = "delver_depth"
    static let deepestDepth = "deepest_depth"
    static let reminderTime = "reminder_time"
    static let schemaVersion = "schema_version"
    static let demoSeed = "hyp.demo.v1"
}
