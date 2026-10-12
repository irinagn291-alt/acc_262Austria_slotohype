import SwiftUI

/// Reminder, haptics, contact, onboarding, and a named reset of the shaft.
struct SettingsSheet: View {
    @Bindable var session: ShaftSession
    @State private var confirmReset = false
    @State private var time = Date()

    var body: some View {
        NavigationStack {
            Group {
                switch session.phase {
                case .failed(let message):
                    ShaftStatusPage(
                        title: "Settings could not read the shaft.",
                        line: message,
                        art: "hyp_EmptyList",
                        actionTitle: "Retry",
                        action: { Task { await session.boot() } },
                        glassBackdrop: true
                    )
                case .loading:
                    ShaftStatusPage(
                        title: "Settings are still loading.",
                        line: "The reminder time appears when the shaft file answers.",
                        art: "hyp_EmptyList",
                        actionTitle: "Retry",
                        action: { Task { await session.boot() } },
                        glassBackdrop: true
                    )
                case .ready:
                    form
                }
            }
            .shaftSheetBackdrop()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .shaftClose { session.sheet = nil }
        }
        .onAppear { time = date(from: session.reminderMinutes) }
        .confirmationDialog(
            "Reset the Hypogeum shaft?",
            isPresented: $confirmReset,
            titleVisibility: .visible
        ) {
            Button("Reset shaft", role: .destructive) {
                Task { await session.resetShaft() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This deletes every saved mark. Level, points, and place return to the opening plate.")
        }
    }

    private var form: some View {
        Form {
            Section {
                DatePicker("Daily reminder", selection: $time, displayedComponents: .hourAndMinute)
                    .font(ChromeType.body(ChromeType.bodySize))
                    .onChange(of: time) { _, newValue in
                        let parts = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                        let minutes = (parts.hour ?? 9) * 60 + (parts.minute ?? 0)
                        Task { await session.setReminder(minutes: minutes) }
                    }
                Toggle("Haptics", isOn: Binding(
                    get: { session.hapticsEnabled },
                    set: { value in Task { await session.setHaptics(value) } }
                ))
            }
            .listRowBackground(ChromeColor.surface)

            Section {
                if let contact = URL(string: "https://hypogeum-shaft.pro/contact-us") {
                    Link(destination: contact) {
                        HStack {
                            Text("Contact")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .accessibilityHidden(true)
                        }
                        .frame(minHeight: ChromeSpace.hit)
                        .contentShape(Rectangle())
                    }
                    .font(ChromeType.body(ChromeType.bodySize))
                    .accessibilityLabel("Contact")
                }
                Button("Show the descent again") {
                    session.markOnboardingAgain()
                }
                .font(ChromeType.body(ChromeType.bodySize))
                .frame(minHeight: ChromeSpace.hit)
                Button("Reset shaft") { confirmReset = true }
                    .font(ChromeType.body(ChromeType.bodySize))
                    .foregroundStyle(ChromeColor.ink)
                    .frame(minHeight: ChromeSpace.hit)
            }
            .listRowBackground(ChromeColor.surface)
        }
        .scrollContentBackground(.hidden)
        .tint(ChromeColor.ink)
    }

    private func date(from minutes: Int) -> Date {
        var parts = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        parts.hour = minutes / 60
        parts.minute = minutes % 60
        return Calendar.current.date(from: parts) ?? Date()
    }
}
