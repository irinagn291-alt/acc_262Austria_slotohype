import SwiftUI

/// Tabular record of pins, depth, XP, and the longest run.
struct HeroSheet: View {
    let session: ShaftSession

    var body: some View {
        NavigationStack {
            Group {
                switch session.phase {
                case .failed(let message):
                    ShaftStatusPage(
                        title: "The hero record did not load.",
                        line: message,
                        art: "hyp_EmptyList",
                        actionTitle: "Retry",
                        action: { Task { await session.reload(reconcile: false) } },
                        glassBackdrop: true
                    )
                case .loading:
                    ProgressView().tint(ChromeColor.accent).frame(maxWidth: .infinity, maxHeight: .infinity)
                case .ready:
                    if session.pinTotal == 0 {
                        ShaftStatusPage(
                            title: "No pins yet.",
                            line: "Align today's pin on the shaft to start the record.",
                            art: "hyp_EmptyList",
                            actionTitle: "Close",
                            action: { session.sheet = nil },
                            glassBackdrop: true
                        )
                    } else {
                        populated
                    }
                }
            }
            .shaftSheetBackdrop()
            .navigationTitle("Standing")
            .navigationBarTitleDisplayMode(.inline)
            .shaftClose { session.sheet = nil }
        }
    }

    private var populated: some View {
        let held = ChromeNumber.integer(session.snapshot.delverDepth)
        let farthest = ChromeNumber.integer(session.snapshot.deepestDepth)
        return ScrollView {
            VStack(alignment: .leading, spacing: ChromeSpace.unit * 2) {
                VStack(alignment: .leading, spacing: ChromeSpace.unit) {
                    Text("HELD")
                        .font(ChromeType.rule(ChromeType.sectionSize))
                        .tracking(0.6)
                        .foregroundStyle(ChromeColor.muted)
                    Text(held)
                        .font(ChromeType.display(ChromeType.displaySize).monospacedDigit())
                        .tracking(-0.8)
                        .foregroundStyle(ChromeColor.accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                    Text("You hold \(held). The farthest reach is \(farthest).")
                        .font(ChromeType.body(ChromeType.bodySize))
                        .lineSpacing(ChromeType.bodyLeading)
                        .foregroundStyle(ChromeColor.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(ChromeSpace.unit * 2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .chromePlate()
                row("Pins", session.pinTotal)
                row("Streak", session.streak)
                row("Longest streak", session.longestStreak)
            }
            .padding(ChromeSpace.unit * 2)
            .padding(.bottom, ChromeSpace.unit * 6)
        }
    }

    private func row(_ title: String, _ value: Int) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(ChromeType.body(ChromeType.bodySize))
                .foregroundStyle(ChromeColor.ink)
                .lineLimit(1)
            Spacer(minLength: ChromeSpace.unit)
            Text(ChromeNumber.integer(value))
                .font(ChromeType.body(ChromeType.figureSize).monospacedDigit())
                .foregroundStyle(ChromeColor.ink)
                .lineLimit(1)
                .layoutPriority(1)
        }
        .padding(.horizontal, ChromeSpace.unit * 2)
        .frame(maxWidth: .infinity, minHeight: ChromeSpace.hit, alignment: .leading)
        .chromePlate()
    }
}
