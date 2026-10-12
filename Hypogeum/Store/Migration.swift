import SQLite3

enum Migration {
    static func apply(to db: OpaquePointer) throws {
        var version = try Schema.userVersion(db)
        if version < 1 {
            try Schema.createV1(db)
            try Schema.setUserVersion(db, 1)
            version = 1
        }
        if version < Schema.currentUserVersion {
            try Schema.setUserVersion(db, Schema.currentUserVersion)
        }
    }
}
