import Foundation
import Observation
import UIKit
import UserNotifications

/// Owns the live shaft between the store and the screens. The map never reloads on dismiss.
@MainActor
@Observable
final class ShaftSession {
    enum Phase: Equatable {
        case loading
        case ready
        case failed(String)
    }

    enum Sheet: String, Identifiable {
        case journal
        case hero
        case settings
        case backslide

        var id: String { rawValue }
    }

    private(set) var phase: Phase = .loading
    private(set) var snapshot = ShaftSnapshot(levels: [], marks: [], totalXP: 0, delverDepth: 0, deepestDepth: 0)
    private(set) var showSpinner = false
    var onboarded = false
    var sheet: Sheet?
    var expandedIndex: Int?
    var sweepToken = 0
    var notice: String?
    var hapticsEnabled = true
    var reminderMinutes = 9 * 60
    private var database: ShaftDatabase?
    private var didReadReview = false
    private var turning = false

    var isTurning: Bool { turning }

    func boot() async {
        if database == nil {
            do {
                database = try ShaftDatabase.applicationSupport()
            } catch {
                phase = .failed("The shaft file could not open. Retry keeps the same folder.")
                return
            }
        }
        await seedSimulatorIfNeeded()
        if case .failed = phase { return }
        await reload(reconcile: true)
        await loadPreferences()
    }

    func reload(reconcile: Bool) async {
        guard let database else { return }
        let started = Date()
        showSpinner = false
        let spinner = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(150))
            if !Task.isCancelled { showSpinner = true }
        }
        do {
            let calendar = Calendar.current
            let today = DayKey.today(calendar: calendar)
            let next = try await {
                if reconcile {
                    try await database.reconcile(asOf: today, calendar: calendar)
                } else {
                    try await database.loadSnapshot()
                }
            }()
            snapshot = next
            phase = .ready
        } catch {
            phase = .failed("The shaft could not be read. Retry loads the same file.")
        }
        spinner.cancel()
        if Date().timeIntervalSince(started) < 0.15 {
            showSpinner = false
        }
    }

    func alignToday() async {
        guard let database, !turning else { return }
        turning = true
        defer { turning = false }
        let calendar = Calendar.current
        let today = DayKey.today(calendar: calendar)
        do {
            let result = try await database.performTurn(on: today, calendar: calendar)
            switch result {
            case .success(let commit):
                snapshot = commit.snapshot
                sweepToken += 1
                notice = commit.outcome.hatchOpened
                    ? "The door is open. You dropped one level."
                    : "Today's pin is seated."
                if hapticsEnabled {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            case .failure(let reason):
                notice = reason == .alreadyAlignedToday
                    ? "Today's pin is already seated."
                    : "This plate has no open seat."
            }
        } catch {
            notice = "The turn did not write. Try the plate again."
        }
    }

    func applyReviewArguments() {
        guard onboarded, phase == .ready, !didReadReview else { return }
        didReadReview = true
        guard let screen = ReviewScreen.launched() else { return }
        switch screen {
        case .today:
            sheet = nil
        case .log:
            sheet = .journal
        case .goals:
            sheet = .hero
        case .settings:
            sheet = .settings
        }
    }

    func finishOnboarding(skipped: Bool) async {
        reminderMinutes = 9 * 60
        hapticsEnabled = true
        onboarded = true
        await persistPreferences()
        if skipped {
            notice = nil
        }
    }

    func markOnboardingAgain() {
        onboarded = false
        sheet = nil
        Task { await persistPreferences() }
    }

    func resetShaft() async {
        guard let database else { return }
        do {
            try await database.resetAllData()
            snapshot = try await database.loadSnapshot()
            phase = .ready
            notice = "The shaft is empty. Every saved mark is gone."
            sheet = nil
        } catch {
            phase = .failed("Reset did not finish. Retry from Settings.")
        }
    }

    func setReminder(minutes: Int) async {
        reminderMinutes = minutes
        await persistPreferences()
        await ReminderBell.schedule(minutesFromMidnight: minutes)
    }

    func setHaptics(_ enabled: Bool) async {
        hapticsEnabled = enabled
        await persistPreferences()
    }

    var streak: Int {
        TumblerEngine().streak(endingAt: DayKey.today(), marks: snapshot.marks, calendar: .current)
    }

    var longestStreak: Int {
        TumblerEngine().longestStreak(marks: snapshot.marks, calendar: .current)
    }

    var pinTotal: Int {
        snapshot.marks.filter { $0.kind == .tumbler }.count
    }

    var vaultsCracked: Int {
        snapshot.levels.filter(\.cracked).count
    }

    var weekCount: Int {
        let marks = snapshot.marks.compactMap(\.asTumbler)
        guard let window = WeekWindow.containing(DayKey.today(), calendar: .current) else { return 0 }
        return VaultWeek.tumblerCount(marks: marks, window: window)
    }

    var nextIsVault: Bool {
        Level.isVaultIndex(snapshot.delverDepth + 1) || (snapshot.level(at: snapshot.delverDepth)?.isVault == true)
    }

    var alreadyToday: Bool {
        let today = DayKey.today()
        return snapshot.marks.contains { $0.dayKey == today && $0.kind == .tumbler }
    }

    private func loadPreferences() async {
        guard let database else { return }
        if let flag = try? await database.metaValue("onboarding_done") {
            onboarded = flag == "1"
        }
        if let raw = try? await database.metaValue(MetaKey.reminderTime), let minutes = Int(raw) {
            reminderMinutes = minutes
        }
        if let raw = try? await database.metaValue("haptics_enabled") {
            hapticsEnabled = raw != "0"
        }
    }

    private func persistPreferences() async {
        guard let database else { return }
        try? await database.setMeta("onboarding_done", value: onboarded ? "1" : "0")
        try? await database.setMeta(MetaKey.reminderTime, value: String(reminderMinutes))
        try? await database.setMeta("haptics_enabled", value: hapticsEnabled ? "1" : "0")
    }

    private func seedSimulatorIfNeeded() async {
        #if targetEnvironment(simulator)
        guard let database else { return }
        do {
            if (try await database.metaValue(MetaKey.demoSeed)) == "1" { return }
            let calendar = Calendar.current
            let today = DayKey.today(calendar: calendar)
            // Eleven seated days end yesterday: three cleared depths, two pins on the live plate.
            for offset in stride(from: 11, through: 1, by: -1) {
                guard let day = today.adding(days: -offset, calendar: calendar) else { continue }
                let result = try await database.performTurn(on: day, calendar: calendar)
                if case .failure(let reason) = result, reason != .alreadyAlignedToday {
                    phase = .failed("The demo shaft stopped before today's plate. Retry seeds the same file.")
                    return
                }
            }
            try await database.setMeta(MetaKey.demoSeed, value: "1")
            try await database.setMeta("onboarding_done", value: "1")
            onboarded = true
        } catch {
            phase = .failed("The demo shaft did not seed. Retry opens the same file.")
        }
        #endif
    }
}

enum ReminderBell {
    static func schedule(minutesFromMidnight: Int) async {
        let center = UNUserNotificationCenter.current()
        let granted = try? await center.requestAuthorization(options: [.alert, .sound])
        guard granted == true else { return }
        center.removePendingNotificationRequests(withIdentifiers: ["hypogeum.daily"])
        var components = DateComponents()
        components.hour = minutesFromMidnight / 60
        components.minute = minutesFromMidnight % 60
        let content = UNMutableNotificationContent()
        content.title = "Align today's pin"
        content.body = "Today's plate is waiting."
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "hypogeum.daily", content: content, trigger: trigger)
        try? await center.add(request)
    }
}
