import SwiftUI

/// Palette, type, space, and radius for the shaft chrome. One accessor each.
/// Named colours: background #000000, surface #1E1E1E, ink #FFFFFF, accent #F9D4FF, muted #A5A5A5.
enum ChromeColor {
    static let background = Color("background")
    static let surface = Color("surface")
    static let ink = Color("ink")
    static let accent = Color("accent")
    static let muted = Color("muted")
}

enum ChromeType {
    static func display(_ size: CGFloat) -> Font {
        Font.custom("Verdana-Bold", size: size, relativeTo: .largeTitle)
    }

    static func rule(_ size: CGFloat) -> Font {
        Font.custom("Verdana-Bold", size: size, relativeTo: .caption)
    }

    static func body(_ size: CGFloat) -> Font {
        Font.custom("Verdana", size: size, relativeTo: .body)
    }

    static func caption(_ size: CGFloat) -> Font {
        Font.custom("Verdana", size: size, relativeTo: .caption)
    }

    static let displaySize: CGFloat = 34
    static let sectionSize: CGFloat = 13
    static let bodySize: CGFloat = 16
    static let captionSize: CGFloat = 12
    static let figureSize: CGFloat = 22
    /// Extra leading so display 34 sits on a 40pt line.
    static let displayLeading: CGFloat = 6
    /// Extra leading so body 16 sits on a 24pt line.
    static let bodyLeading: CGFloat = 8
    /// Extra leading so caption 12 sits on a 16pt line.
    static let captionLeading: CGFloat = 4
}

enum ChromeSpace {
    static let unit: CGFloat = 8
    static let hairline: CGFloat = 1
    static let hit: CGFloat = 44
    static let ghost: CGFloat = 80
    static let hero: CGFloat = 176
    static let rail: CGFloat = 88
}

enum ChromeRadius {
    static let outer: CGFloat = 14
    static let inner: CGFloat = 6
}

enum ChromeMotion {
    static let fade: Double = 0.18
}

enum ChromeNumber {
    static func integer(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    static func dayKey(_ raw: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.usesGroupingSeparator = false
        return formatter.string(from: NSNumber(value: raw)) ?? "0"
    }
}
