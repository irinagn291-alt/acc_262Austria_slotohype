import Foundation

/// Launch-argument destination. Not a tab.
enum ReviewScreen: String, Sendable, Equatable {
    case today
    case log
    case goals
    case settings

    static func parse(arguments: [String]) -> ReviewScreen? {
        guard let flag = arguments.firstIndex(of: "-ReviewScreen") else { return nil }
        let valueIndex = arguments.index(after: flag)
        guard valueIndex < arguments.endIndex else { return nil }
        return ReviewScreen(rawValue: arguments[valueIndex])
    }

    /// Reads `-ReviewScreen` from the process launch arguments once the caller is ready.
    static func launched() -> ReviewScreen? {
        parse(arguments: ProcessInfo.processInfo.arguments)
    }
}
