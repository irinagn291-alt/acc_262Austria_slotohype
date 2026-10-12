import SwiftUI

/// Tinted-glass primary and a separate destructive treatment.
struct ChromeButtonStyle: ButtonStyle {
    enum Kind {
        case primary
        case destructive
    }

    var kind: Kind = .primary
    var isLoading: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        ChromeButtonBody(configuration: configuration, kind: kind, isLoading: isLoading)
    }
}

private struct ChromeButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let kind: ChromeButtonStyle.Kind
    let isLoading: Bool
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .font(ChromeType.body(ChromeType.bodySize))
            .lineSpacing(ChromeType.bodyLeading)
            .foregroundStyle(ChromeColor.ink)
            .frame(maxWidth: .infinity, minHeight: ChromeSpace.hit)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous)
                        .fill(.ultraThinMaterial)
                    if kind == .primary {
                        RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous)
                            .fill(ChromeColor.accent.opacity(configuration.isPressed ? 0.42 : 0.22))
                    } else {
                        RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous)
                            .fill(ChromeColor.surface.opacity(configuration.isPressed ? 0.55 : 0.92))
                    }
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous)
                    .strokeBorder(kind == .primary && isEnabled ? ChromeColor.accent : ChromeColor.muted, lineWidth: ChromeSpace.hairline)
            }
            .opacity(isEnabled && !isLoading ? 1 : 0.4)
            .animation(reduceMotion ? nil : .easeOut(duration: ChromeMotion.fade), value: configuration.isPressed)
    }
}

/// Opacity press for tiles. No travel.
struct ChromePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ChromePressBody(configuration: configuration)
    }
}

private struct ChromePressBody: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .opacity(isEnabled ? (configuration.isPressed ? 0.55 : 1) : 0.4)
            .animation(reduceMotion ? nil : .easeOut(duration: ChromeMotion.fade), value: configuration.isPressed)
    }
}

/// Flat plate. Surface fill plus a low-opacity wash, hairline stays with the caller.
struct ChromeGlassBackground: View {
    var tint: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous)
                .fill(ChromeColor.surface)
            RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous)
                .fill(tint)
        }
    }
}

struct ChromePlate: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(ChromeColor.surface)
            .overlay {
                RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous)
                    .strokeBorder(ChromeColor.muted, lineWidth: ChromeSpace.hairline)
            }
            .clipShape(RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous))
    }
}

extension View {
    func chromePlate() -> some View {
        modifier(ChromePlate())
    }

    func shaftSheetBackdrop() -> some View {
        background {
            ZStack {
                Rectangle().fill(ChromeColor.surface)
                ChromeColor.ink.opacity(0.06)
            }
            .ignoresSafeArea()
        }
    }

    func shaftClose(_ action: @escaping () -> Void) -> some View {
        toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: action) {
                    Image(systemName: "xmark")
                        .font(ChromeType.body(ChromeType.bodySize))
                        .foregroundStyle(ChromeColor.ink)
                        .frame(width: ChromeSpace.hit, height: ChromeSpace.hit)
                        .contentShape(Rectangle())
                }
                .buttonStyle(ChromePressStyle())
                .accessibilityLabel("Close")
            }
        }
    }
}
