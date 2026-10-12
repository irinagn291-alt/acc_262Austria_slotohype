import SwiftUI

/// Live verb on the shaft. Three pin seats, one shader sweep when a pin seats.
struct LockplateView: View {
    let level: Level
    let enabled: Bool
    let busy: Bool
    let sweepToken: Int
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var progress: Float = 0

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: ChromeSpace.unit) {
                Text("TODAY")
                    .font(ChromeType.rule(ChromeType.sectionSize))
                    .tracking(0.6)
                    .foregroundStyle(ChromeColor.muted)
                Text("Align today's pin.")
                    .font(ChromeType.display(ChromeType.displaySize))
                    .tracking(-0.8)
                    .lineSpacing(ChromeType.displayLeading)
                    .foregroundStyle(ChromeColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(enabled ? "Tap the open pin. It seats on this plate." : "Today's pin is already seated.")
                    .font(ChromeType.body(ChromeType.bodySize))
                    .lineSpacing(ChromeType.bodyLeading)
                    .foregroundStyle(ChromeColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: ChromeSpace.unit) {
                    ForEach(0..<3, id: \.self) { seat in
                        PinSeat(filled: seat < level.pins, isOpenTap: enabled && seat == level.pins)
                    }
                }
                .padding(.top, ChromeSpace.unit)
            }
            .padding(ChromeSpace.unit * 2)
            .frame(maxWidth: .infinity, minHeight: ChromeSpace.hero, alignment: .leading)
            .background(plateFill)
            .overlay {
                RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous)
                    .strokeBorder(enabled ? ChromeColor.accent : ChromeColor.muted, lineWidth: ChromeSpace.hairline)
            }
            .clipShape(RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(ChromePressStyle())
        .disabled(!enabled || busy)
        .accessibilityLabel("Align today's pin")
        .accessibilityHint("Seats one pin on today's plate.")
        .onChange(of: sweepToken) { _, _ in
            runSweep()
        }
    }

    @ViewBuilder
    private var plateFill: some View {
        let glass = ZStack {
            RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous)
                .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous)
                .fill(ChromeColor.surface.opacity(0.72))
            RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous)
                .fill(ChromeColor.accent.opacity(0.22))
        }
        if reduceMotion {
            glass
        } else {
            let sweep = progress
            glass.visualEffect { content, proxy in
                content.layerEffect(
                    ShaderLibrary.chromeSweep(
                        .float2(proxy.size),
                        .float(sweep)
                    ),
                    maxSampleOffset: .zero
                )
            }
        }
    }

    private func runSweep() {
        guard !reduceMotion else { return }
        progress = 0
        withAnimation(.easeOut(duration: ChromeMotion.fade)) {
            progress = 1
        }
    }
}

struct PinSeat: View {
    let filled: Bool
    var isOpenTap = false

    var body: some View {
        RoundedRectangle(cornerRadius: ChromeRadius.inner, style: .continuous)
            .fill(filled ? ChromeColor.accent : ChromeColor.background)
            .frame(width: ChromeSpace.hit, height: ChromeSpace.unit * 6)
            .overlay {
                if filled {
                    Image(systemName: "circle.fill")
                        .font(ChromeType.caption(ChromeType.captionSize))
                        .foregroundStyle(ChromeColor.background)
                        .accessibilityHidden(true)
                } else if isOpenTap {
                    Text("Align")
                        .font(ChromeType.caption(ChromeType.captionSize))
                        .foregroundStyle(ChromeColor.accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                } else {
                    Image(systemName: "circle")
                        .font(ChromeType.caption(ChromeType.captionSize))
                        .foregroundStyle(ChromeColor.muted)
                        .accessibilityHidden(true)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: ChromeRadius.inner, style: .continuous)
                    .strokeBorder(isOpenTap ? ChromeColor.accent : ChromeColor.muted, lineWidth: isOpenTap ? 2 : ChromeSpace.hairline)
            }
            .accessibilityLabel(filled ? "Pin seated" : (isOpenTap ? "Open pin, align" : "Pin open"))
    }
}

struct HatchGateView: View {
    let open: Bool

    var body: some View {
        Text(open ? "Door open" : "Door locked")
            .font(ChromeType.caption(ChromeType.captionSize))
            .foregroundStyle(ChromeColor.ink)
            .padding(.horizontal, ChromeSpace.unit)
            .frame(minHeight: ChromeSpace.unit * 4)
            .background(ChromeColor.background.opacity(0.45), in: RoundedRectangle(cornerRadius: ChromeRadius.inner, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: ChromeRadius.inner, style: .continuous)
                    .strokeBorder(ChromeColor.muted, lineWidth: ChromeSpace.hairline)
            }
    }
}

struct DelverMarker: View {
    let active: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: ChromeRadius.inner, style: .continuous)
            .fill(active ? ChromeColor.accent : ChromeColor.muted)
            .frame(width: ChromeSpace.unit, height: ChromeSpace.unit * 4)
            .accessibilityLabel(active ? "You are here" : "Cleared depth")
    }
}
