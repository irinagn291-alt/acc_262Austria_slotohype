/// Weekly boss on every fifth level. Five tumbler marks in one week crack it.
struct Vault: Sendable, Hashable, Identifiable {
    let levelIndex: Int
    let cracked: Bool

    var id: Int { levelIndex }
}
