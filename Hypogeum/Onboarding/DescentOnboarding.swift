import SwiftUI

/// Three panes. Descend writes defaults and the completion flag. Skip does the same.
struct DescentOnboarding: View {
    let finish: (Bool) -> Void
    @State private var page = 0

    private let panes: [(String, String, String)] = [
        ("hyp_Onboarding1", "The plate is the job.", "You sit on today's plate. A level only moves when a pin seats."),
        ("hyp_Onboarding2", "Align today's pin.", "Three pins in a row open the door. A missed day clears the plate."),
        ("hyp_Onboarding3", "Three misses lift you.", "You move up one level and the door above locks again. A weekly prize still waits on every fifth level.")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: ChromeSpace.unit * 2) {
            HStack {
                Spacer()
                Button("Skip") { finish(true) }
                    .font(ChromeType.body(ChromeType.bodySize))
                    .foregroundStyle(ChromeColor.ink)
                    .frame(minWidth: ChromeSpace.hit, minHeight: ChromeSpace.hit)
            }
            ScrollView {
                let pane = panes[page]
                let paneNumber = ChromeNumber.integer(page + 1)
                let paneCount = ChromeNumber.integer(panes.count)
                VStack(alignment: .leading, spacing: ChromeSpace.unit * 2) {
                    Image(pane.0)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: ChromeSpace.unit * 28)
                        .clipped()
                        .accessibilityHidden(true)
                    Text(pane.1)
                        .font(ChromeType.display(ChromeType.displaySize))
                        .tracking(-0.8)
                        .lineSpacing(ChromeType.displayLeading)
                        .foregroundStyle(ChromeColor.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                    Text(pane.2)
                        .font(ChromeType.body(ChromeType.bodySize))
                        .lineSpacing(ChromeType.bodyLeading)
                        .foregroundStyle(ChromeColor.muted)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Pane \(paneNumber) of \(paneCount)")
                        .font(ChromeType.caption(ChromeType.captionSize).monospacedDigit())
                        .foregroundStyle(ChromeColor.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollDismissesKeyboard(.interactively)
            Button(page == panes.count - 1 ? "Descend" : "Next") {
                if page == panes.count - 1 {
                    finish(false)
                } else {
                    page += 1
                }
            }
            .buttonStyle(ChromeButtonStyle())
        }
        .padding(ChromeSpace.unit * 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(ChromeColor.background.ignoresSafeArea())
    }
}
