import Foundation
import SQLite3

/// Single sqlite3 handle. The UI never sees a statement or cursor.
actor ShaftDatabase {
    private let box: ConnectionBox
    private let db: OpaquePointer
    private let engine = TumblerEngine()

    init(fileURL: URL) throws {
        let parent = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)
        let box = ConnectionBox()
        var handle: OpaquePointer?
        let flags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
        let openCode = fileURL.path.withCString { path in
            sqlite3_open_v2(path, &handle, flags, nil)
        }
        guard openCode == SQLITE_OK, let handle else {
            if let handle { sqlite3_close(handle) }
            throw ShaftStoreError.open(openCode)
        }
        box.handle = handle
        try Schema.exec(handle, "PRAGMA journal_mode = WAL;")
        try Schema.exec(handle, "PRAGMA foreign_keys = ON;")
        try Migration.apply(to: handle)
        self.box = box
        self.db = handle
        try ShaftBootstrap.ensureEmptyShaft(handle)
    }

    static func applicationSupport() throws -> ShaftDatabase {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let folder = root.appendingPathComponent("Slotohype", isDirectory: true)
        return try ShaftDatabase(fileURL: folder.appendingPathComponent("shaft.sqlite"))
    }

    deinit {
        box.close()
    }

    func loadSnapshot() async throws -> ShaftSnapshot {
        try Task.checkCancellation()
        return try readSnapshot()
    }

    func reconcile(asOf day: DayKey, calendar: Calendar = .current) async throws -> ShaftSnapshot {
        try Task.checkCancellation()
        let current = try readSnapshot()
        let next = engine.reconcile(state: current, today: day, calendar: calendar)
        try persist(snapshot: next, replacingMarks: true)
        return next
    }

    func performTurn(on day: DayKey, calendar: Calendar = .current) async throws -> Result<TurnCommit, BlockedTurn> {
        try Task.checkCancellation()
        let current = try readSnapshot()
        let result = engine.turn(on: day, state: current, calendar: calendar)
        if case .success(let commit) = result {
            try persist(snapshot: commit.snapshot, replacingMarks: true)
        }
        return result
    }

    func resetAllData() async throws {
        try Task.checkCancellation()
        try begin()
        do {
            try Schema.exec(db, "DELETE FROM mark;")
            try Schema.exec(db, "DELETE FROM level;")
            try Schema.exec(db, "DELETE FROM meta;")
            try insertLevel(Level.fresh(index: 0))
            try writeMeta(MetaKey.totalXP, "0")
            try writeMeta(MetaKey.delverDepth, "0")
            try writeMeta(MetaKey.deepestDepth, "0")
            try writeMeta(MetaKey.schemaVersion, "1")
            try commit()
        } catch {
            try rollback()
            throw error
        }
    }

    func metaValue(_ key: String) async throws -> String? {
        try Task.checkCancellation()
        return try readMeta(key)
    }

    func setMeta(_ key: String, value: String) async throws {
        try Task.checkCancellation()
        try writeMeta(key, value)
    }

    private func readSnapshot() throws -> ShaftSnapshot {
        var levels: [Level] = []
        let levelStmt = try cached(
            "SELECT idx, pins, hatch_open, is_vault, cracked FROM level ORDER BY idx;"
        )
        try reset(levelStmt)
        while try Statement.step(db, levelStmt) == SQLITE_ROW {
            levels.append(
                Level(
                    index: Statement.int(levelStmt, 0),
                    pins: Statement.int(levelStmt, 1),
                    hatchOpen: Statement.int(levelStmt, 2) != 0,
                    isVault: Statement.int(levelStmt, 3) != 0,
                    cracked: Statement.int(levelStmt, 4) != 0
                )
            )
        }

        var marks: [LedgerRow] = []
        let markStmt = try cached(
            "SELECT day_key, level_idx, kind, xp FROM mark ORDER BY day_key;"
        )
        try reset(markStmt)
        while try Statement.step(db, markStmt) == SQLITE_ROW {
            guard let kindName = Statement.text(markStmt, 2),
                  let kind = LedgerKind(rawValue: kindName)
            else { continue }
            marks.append(
                LedgerRow(
                    dayKey: DayKey(raw: Statement.int(markStmt, 0)),
                    levelIndex: Statement.int(markStmt, 1),
                    kind: kind,
                    xp: Statement.int(markStmt, 3)
                )
            )
        }

        let totalXP = Int(try readMeta(MetaKey.totalXP) ?? "0") ?? 0
        let depth = Int(try readMeta(MetaKey.delverDepth) ?? "0") ?? 0
        let deepest = Int(try readMeta(MetaKey.deepestDepth) ?? "0") ?? 0
        return ShaftSnapshot(
            levels: levels,
            marks: marks,
            totalXP: totalXP,
            delverDepth: depth,
            deepestDepth: deepest
        )
    }

    private func persist(snapshot: ShaftSnapshot, replacingMarks: Bool) throws {
        try begin()
        do {
            for level in snapshot.levels {
                try upsertLevel(level)
            }
            if replacingMarks {
                try Schema.exec(db, "DELETE FROM mark;")
                for row in snapshot.marks {
                    try insertMark(row)
                }
            }
            try writeMeta(MetaKey.totalXP, String(snapshot.totalXP))
            try writeMeta(MetaKey.delverDepth, String(snapshot.delverDepth))
            try writeMeta(MetaKey.deepestDepth, String(snapshot.deepestDepth))
            try commit()
        } catch {
            try rollback()
            throw error
        }
    }

    private func insertLevel(_ level: Level) throws {
        let stmt = try cached(
            "INSERT INTO level (idx, pins, hatch_open, is_vault, cracked) VALUES (?, ?, ?, ?, ?);"
        )
        try reset(stmt)
        try Statement.bindInt(stmt, 1, level.index)
        try Statement.bindInt(stmt, 2, level.pins)
        try Statement.bindInt(stmt, 3, level.hatchOpen ? 1 : 0)
        try Statement.bindInt(stmt, 4, level.isVault ? 1 : 0)
        try Statement.bindInt(stmt, 5, level.cracked ? 1 : 0)
        try Statement.step(db, stmt)
    }

    private func upsertLevel(_ level: Level) throws {
        let stmt = try cached(
            """
            INSERT INTO level (idx, pins, hatch_open, is_vault, cracked) VALUES (?, ?, ?, ?, ?)
            ON CONFLICT(idx) DO UPDATE SET
                pins = excluded.pins,
                hatch_open = excluded.hatch_open,
                is_vault = excluded.is_vault,
                cracked = excluded.cracked;
            """
        )
        try reset(stmt)
        try Statement.bindInt(stmt, 1, level.index)
        try Statement.bindInt(stmt, 2, level.pins)
        try Statement.bindInt(stmt, 3, level.hatchOpen ? 1 : 0)
        try Statement.bindInt(stmt, 4, level.isVault ? 1 : 0)
        try Statement.bindInt(stmt, 5, level.cracked ? 1 : 0)
        try Statement.step(db, stmt)
    }

    private func insertMark(_ row: LedgerRow) throws {
        let stmt = try cached(
            "INSERT INTO mark (day_key, level_idx, kind, xp) VALUES (?, ?, ?, ?);"
        )
        try reset(stmt)
        try Statement.bindInt(stmt, 1, row.dayKey.raw)
        try Statement.bindInt(stmt, 2, row.levelIndex)
        try Statement.bindText(stmt, 3, row.kind.rawValue)
        try Statement.bindInt(stmt, 4, row.xp)
        try Statement.step(db, stmt)
    }

    private func readMeta(_ key: String) throws -> String? {
        let stmt = try cached("SELECT value FROM meta WHERE key = ?;")
        try reset(stmt)
        try Statement.bindText(stmt, 1, key)
        let code = try Statement.step(db, stmt)
        guard code == SQLITE_ROW else { return nil }
        return Statement.text(stmt, 0)
    }

    private func writeMeta(_ key: String, _ value: String) throws {
        let stmt = try cached(
            "INSERT INTO meta (key, value) VALUES (?, ?) ON CONFLICT(key) DO UPDATE SET value = excluded.value;"
        )
        try reset(stmt)
        try Statement.bindText(stmt, 1, key)
        try Statement.bindText(stmt, 2, value)
        try Statement.step(db, stmt)
    }

    private func begin() throws {
        try Schema.exec(db, "BEGIN IMMEDIATE;")
    }

    private func commit() throws {
        try Schema.exec(db, "COMMIT;")
    }

    private func rollback() throws {
        try Schema.exec(db, "ROLLBACK;")
    }

    private func cached(_ sql: String) throws -> OpaquePointer {
        if let existing = box.statements[sql] {
            return existing
        }
        let stmt = try Statement.prepare(db, sql)
        box.statements[sql] = stmt
        return stmt
    }

    private func reset(_ stmt: OpaquePointer) throws {
        let resetCode = sqlite3_reset(stmt)
        guard resetCode == SQLITE_OK else { throw ShaftStoreError.step(resetCode, "reset") }
        let clearCode = sqlite3_clear_bindings(stmt)
        guard clearCode == SQLITE_OK else { throw ShaftStoreError.bind(clearCode) }
    }
}

/// Owns the C handle. The actor is the only caller while it is alive; `close()`
/// runs from `deinit` after that actor has stopped, so the handle never crosses threads.
final class ConnectionBox: @unchecked Sendable {
    var handle: OpaquePointer?
    var statements: [String: OpaquePointer] = [:]

    func close() {
        for (_, stmt) in statements {
            sqlite3_finalize(stmt)
        }
        statements.removeAll()
        if let handle {
            sqlite3_close(handle)
        }
        self.handle = nil
    }
}
