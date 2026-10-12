import SwiftUI

/// Chooses onboarding or the shaft. The shaft stays mounted after the first descent.
struct ContentView: View {
    @State private var session = ShaftSession()

    var body: some View {
        Group {
            if session.phase == .loading && !session.onboarded {
                ProgressView()
                    .tint(ChromeColor.accent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(ChromeColor.background)
            } else if session.phase == .ready && !session.onboarded {
                DescentOnboarding { skipped in
                    Task { await session.finishOnboarding(skipped: skipped) }
                }
            } else {
                ShaftMapView(session: session)
            }
        }
        .task { await session.boot() }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
