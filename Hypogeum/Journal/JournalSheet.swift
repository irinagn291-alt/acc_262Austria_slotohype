import SwiftUI

/// Dated ledger of tumbler marks, trap marks, and backslide rows.
struct JournalSheet: View {
    let session: ShaftSession

    var body: some View {
        NavigationStack {
            Group {
                switch session.phase {
                case .failed(let message):
                    ShaftStatusPage(
                        title: "The journal did not load.",
                        line: message,
                        art: "hyp_JournalEmptyArt",
                        actionTitle: "Retry",
                        action: { Task { await session.reload(reconcile: false) } },
                        glassBackdrop: true
                    )
                case .loading:
                    ProgressView().tint(ChromeColor.accent).frame(maxWidth: .infinity, maxHeight: .infinity)
                case .ready:
                    if session.snapshot.marks.isEmpty {
                        ShaftStatusPage(
                            title: "The path is closed.",
                            line: "Finish three days to open the next node.",
                            art: "hyp_JournalEmptyArt",
                            actionTitle: "Align today's pin",
                            action: { session.sheet = nil },
                            glassBackdrop: true
                        )
                    } else {
                        populated
                    }
                }
            }
            .shaftSheetBackdrop()
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.inline)
            .shaftClose { session.sheet = nil }
        }
    }

    private var populated: some View {
        List {
            Section {
                DepthSparkline(marks: session.snapshot.marks, deepest: session.snapshot.deepestDepth)
                    .listRowBackground(ChromeColor.surface)
            }
            Section {
                ForEach(session.snapshot.marks.sorted { $0.dayKey > $1.dayKey }) { row in
                    let levelText = ChromeNumber.integer(row.levelIndex)
                    VStack(alignment: .leading, spacing: ChromeSpace.unit) {
                        Text(ChromeNumber.dayKey(row.dayKey.raw))
                            .font(ChromeType.body(ChromeType.bodySize).monospacedDigit())
                            .foregroundStyle(ChromeColor.ink)
                        Text(label(row))
                            .font(row.kind == .backslide ? ChromeType.rule(ChromeType.bodySize) : ChromeType.body(ChromeType.bodySize))
                            .foregroundStyle(ChromeColor.ink)
                        Text("Level \(levelText)")
                            .font(ChromeType.caption(ChromeType.captionSize).monospacedDigit())
                            .foregroundStyle(ChromeColor.muted)
                    }
                    .padding(.vertical, ChromeSpace.unit)
                    .listRowBackground(ChromeColor.surface)
                    .overlay(alignment: .bottom) {
                        Rectangle().fill(ChromeColor.muted).frame(height: ChromeSpace.hairline)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .contentMargins(.bottom, ChromeSpace.unit * 4, for: .scrollContent)
    }

    private func label(_ row: LedgerRow) -> String {
        switch row.kind {
        case .tumbler:
            let points = ChromeNumber.integer(row.xp)
            return "Pin seated, \(points) points."
        case .trap:
            return "The weekly prize stayed locked."
        case .backslide:
            return "Backslide. You moved up one level."
        }
    }
}

struct DepthSparkline: View {
    let marks: [LedgerRow]
    let deepest: Int

    var body: some View {
        let farthest = ChromeNumber.integer(deepest)
        return VStack(alignment: .leading, spacing: ChromeSpace.unit) {
            Text("FARTHEST")
                .font(ChromeType.rule(ChromeType.sectionSize))
                .tracking(0.6)
                .foregroundStyle(ChromeColor.muted)
            Text("Farthest \(farthest)")
                .font(ChromeType.body(ChromeType.figureSize).monospacedDigit())
                .foregroundStyle(ChromeColor.ink)
            HStack(alignment: .bottom, spacing: ChromeSpace.unit) {
                let rows = marks.filter { $0.kind == .tumbler }.suffix(12)
                ForEach(Array(rows.enumerated()), id: \.element.id) { _, row in
                    RoundedRectangle(cornerRadius: ChromeRadius.inner, style: .continuous)
                        .fill(ChromeColor.accent)
                        .frame(width: ChromeSpace.unit, height: ChromeSpace.unit * CGFloat(max(row.levelIndex + 1, 1)))
                }
            }
            .frame(maxWidth: .infinity, minHeight: ChromeSpace.unit * 6, alignment: .leading)
        }
        .padding(.vertical, ChromeSpace.unit)
    }
}
