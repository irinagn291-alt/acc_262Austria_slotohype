import SQLite3

enum ShaftBootstrap {
    static func ensureEmptyShaft(_ db: OpaquePointer) throws {
        let stmt = try Statement.prepare(db, "SELECT COUNT(*) FROM level;")
        defer { sqlite3_finalize(stmt) }
        let code = try Statement.step(db, stmt)
        let count = code == SQLITE_ROW ? Statement.int(stmt, 0) : 0
        guard count == 0 else { return }
        let insert = try Statement.prepare(
            db,
            "INSERT INTO level (idx, pins, hatch_open, is_vault, cracked) VALUES (?, ?, ?, ?, ?);"
        )
        defer { sqlite3_finalize(insert) }
        let origin = Level.fresh(index: 0)
        try Statement.bindInt(insert, 1, origin.index)
        try Statement.bindInt(insert, 2, origin.pins)
        try Statement.bindInt(insert, 3, origin.hatchOpen ? 1 : 0)
        try Statement.bindInt(insert, 4, origin.isVault ? 1 : 0)
        try Statement.bindInt(insert, 5, origin.cracked ? 1 : 0)
        try Statement.step(db, insert)
        try writeMeta(db, MetaKey.totalXP, "0")
        try writeMeta(db, MetaKey.delverDepth, "0")
        try writeMeta(db, MetaKey.deepestDepth, "0")
        try writeMeta(db, MetaKey.schemaVersion, "1")
    }

    private static func writeMeta(_ db: OpaquePointer, _ key: String, _ value: String) throws {
        let stmt = try Statement.prepare(
            db,
            "INSERT INTO meta (key, value) VALUES (?, ?) ON CONFLICT(key) DO UPDATE SET value = excluded.value;"
        )
        defer { sqlite3_finalize(stmt) }
        try Statement.bindText(stmt, 1, key)
        try Statement.bindText(stmt, 2, value)
        try Statement.step(db, stmt)
    }
}

enum Schema {
    static let currentUserVersion = 1

    static func createV1(_ db: OpaquePointer) throws {
        try exec(
            db,
            """
            CREATE TABLE IF NOT EXISTS level (
                idx INTEGER PRIMARY KEY,
                pins INTEGER NOT NULL CHECK(pins BETWEEN 0 AND 3),
                hatch_open INTEGER NOT NULL,
                is_vault INTEGER NOT NULL,
                cracked INTEGER NOT NULL
            );
            CREATE TABLE IF NOT EXISTS mark (
                day_key INTEGER PRIMARY KEY,
                level_idx INTEGER NOT NULL REFERENCES level(idx),
                kind TEXT NOT NULL,
                xp INTEGER NOT NULL
            );
            CREATE TABLE IF NOT EXISTS meta (
                key TEXT PRIMARY KEY,
                value TEXT NOT NULL
            );
            CREATE INDEX IF NOT EXISTS mark_level_idx ON mark(level_idx);
            CREATE INDEX IF NOT EXISTS mark_kind_idx ON mark(kind);
            """
        )
    }

    static func exec(_ db: OpaquePointer, _ sql: String) throws {
        var errorPointer: UnsafeMutablePointer<CChar>?
        let code = sqlite3_exec(db, sql, nil, nil, &errorPointer)
        if code != SQLITE_OK {
            let message = errorPointer.map { String(cString: $0) } ?? "sqlite exec \(code)"
            sqlite3_free(errorPointer)
            throw ShaftStoreError.exec(code, message)
        }
    }

    static func userVersion(_ db: OpaquePointer) throws -> Int {
        let stmt = try Statement.prepare(db, "PRAGMA user_version;")
        defer { sqlite3_finalize(stmt) }
        let code = try Statement.step(db, stmt)
        guard code == SQLITE_ROW else { return 0 }
        return Statement.int(stmt, 0)
    }

    static func setUserVersion(_ db: OpaquePointer, _ version: Int) throws {
        try exec(db, "PRAGMA user_version = \(version);")
    }
}
