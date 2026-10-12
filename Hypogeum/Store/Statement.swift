import SQLite3

enum Statement {
    static let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    static func prepare(_ db: OpaquePointer, _ sql: String) throws -> OpaquePointer {
        var stmt: OpaquePointer?
        let code = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        guard code == SQLITE_OK, let stmt else {
            let message = String(cString: sqlite3_errmsg(db))
            throw ShaftStoreError.prepare(code, message)
        }
        return stmt
    }

    static func bindInt(_ stmt: OpaquePointer, _ index: Int32, _ value: Int) throws {
        let code = sqlite3_bind_int(stmt, index, Int32(clamping: value))
        guard code == SQLITE_OK else { throw ShaftStoreError.bind(code) }
    }

    static func bindText(_ stmt: OpaquePointer, _ index: Int32, _ value: String) throws {
        let code = value.withCString { pointer in
            sqlite3_bind_text(stmt, index, pointer, -1, transient)
        }
        guard code == SQLITE_OK else { throw ShaftStoreError.bind(code) }
    }

    @discardableResult
    static func step(_ db: OpaquePointer, _ stmt: OpaquePointer) throws -> Int32 {
        let code = sqlite3_step(stmt)
        if code != SQLITE_DONE && code != SQLITE_ROW {
            throw ShaftStoreError.step(code, String(cString: sqlite3_errmsg(db)))
        }
        return code
    }

    static func int(_ stmt: OpaquePointer, _ index: Int32) -> Int {
        Int(sqlite3_column_int64(stmt, index))
    }

    static func text(_ stmt: OpaquePointer, _ index: Int32) -> String? {
        guard let pointer = sqlite3_column_text(stmt, index) else { return nil }
        return String(cString: pointer)
    }
}
