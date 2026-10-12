import SwiftUI

/// Twist screen. Three consecutive misses ascend the delver and relock the hatch.
struct BackslideDepthView: View {
    let session: ShaftSession

    var body: some View {
        NavigationStack {
            let events = session.snapshot.marks.filter { $0.kind == .backslide }
            Group {
            if events.isEmpty {
                ShaftStatusPage(
                    title: "No backslide yet.",
                    line: "Three missed days in a row lift you one level and lock the door above.",
                    art: "hyp_TwistHero",
                    actionTitle: "Close",
                    action: { session.sheet = nil },
                    glassBackdrop: true
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: ChromeSpace.unit * 2) {
                        Image("hyp_TwistHero")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: ChromeSpace.unit * 28)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .accessibilityHidden(true)
                        Text("Backslide")
                            .font(ChromeType.display(ChromeType.displaySize))
                            .tracking(-0.8)
                            .foregroundStyle(ChromeColor.ink)
                            .lineLimit(2)
                            .minimumScaleFactor(0.9)
                        Text("A missed day clears the pins. Three missed days in a row move you up one level and lock the door above. Points stay.")
                            .font(ChromeType.body(ChromeType.bodySize))
                            .foregroundStyle(ChromeColor.muted)
                        ForEach(events) { row in
                            let held = ChromeNumber.integer(row.levelIndex)
                            let farthest = ChromeNumber.integer(session.snapshot.deepestDepth)
                            VStack(alignment: .leading, spacing: ChromeSpace.unit) {
                                Text(ChromeNumber.dayKey(row.dayKey.raw))
                                    .font(ChromeType.body(ChromeType.bodySize).monospacedDigit())
                                    .foregroundStyle(ChromeColor.ink)
                                Text("Held level \(held). Farthest remains \(farthest).")
                                    .font(ChromeType.body(ChromeType.bodySize))
                                    .foregroundStyle(ChromeColor.ink)
                            }
                            .padding(ChromeSpace.unit * 2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .chromePlate()
                        }
                    }
                    .padding(ChromeSpace.unit * 2)
                }
            }
            }
            .shaftSheetBackdrop()
            .navigationTitle("Backslide")
            .navigationBarTitleDisplayMode(.inline)
            .shaftClose { session.sheet = nil }
        }
    }
}
