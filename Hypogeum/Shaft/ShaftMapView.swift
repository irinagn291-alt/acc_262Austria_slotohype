import SwiftUI
import UIKit

/// Root shaft. Masonry column of levels under a fixed delver rail. The map never unmounts.
struct ShaftMapView: View {
    @Bindable var session: ShaftSession
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @ScaledMetric(relativeTo: .body) private var railWidth = ChromeSpace.rail

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ChromeColor.background.ignoresSafeArea()
            switch session.phase {
            case .loading:
                loading
            case .failed(let message):
                ShaftStatusPage(
                    title: "The shaft did not load.",
                    line: message,
                    art: "hyp_EmptyHome",
                    actionTitle: "Retry",
                    action: { Task { await session.boot() } }
                )
            case .ready:
                if session.snapshot.levels.isEmpty {
                    ShaftStatusPage(
                        title: "The shaft is empty.",
                        line: "Align today's pin to cut the first level.",
                        art: "hyp_EmptyHome",
                        actionTitle: "Retry",
                        action: { Task { await session.reload(reconcile: true) } }
                    )
                } else {
                    populated
                }
            }
        }
        .onAppear {
            session.applyReviewArguments()
        }
        .onChange(of: session.phase) { _, _ in
            session.applyReviewArguments()
        }
        .onChange(of: session.onboarded) { _, _ in
            session.applyReviewArguments()
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active, session.phase == .ready else { return }
            Task { await session.reload(reconcile: true) }
        }
        .sheet(item: $session.sheet) { sheet in
            sheetBody(sheet)
        }
    }

    private var populated: some View {
        HStack(alignment: .top, spacing: ChromeSpace.unit) {
            DelverRail(session: session)
                .frame(width: railWidth, alignment: .leading)
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: ChromeSpace.unit * 2) {
                        Text("DEPTHS")
                            .font(ChromeType.rule(ChromeType.sectionSize))
                            .tracking(0.6)
                            .foregroundStyle(ChromeColor.muted)
                        ForEach(ghostLevels) { level in
                            ghost(level)
                                .id(level.index)
                        }
                        if let current = session.snapshot.level(at: session.snapshot.delverDepth) {
                            hero(current)
                                .id(current.index)
                        }
                        ForEach(aheadLevels) { level in
                            waiting(level)
                                .id(level.index)
                        }
                        backslideBanner
                    }
                    .padding(.trailing, ChromeSpace.rail)
                    .padding(.bottom, ChromeSpace.unit * 6)
                }
                .scrollDismissesKeyboard(.interactively)
                .onAppear {
                    proxy.scrollTo(session.snapshot.delverDepth, anchor: .top)
                }
                .onChange(of: session.snapshot.delverDepth) { _, depth in
                    if reduceMotion {
                        proxy.scrollTo(depth, anchor: .top)
                    } else {
                        withAnimation(.easeOut(duration: ChromeMotion.fade)) {
                            proxy.scrollTo(depth, anchor: .top)
                        }
                    }
                }
            }
        }
        .padding(.leading, ChromeSpace.unit * 2)
        .padding(.top, ChromeSpace.unit * 2)
        .overlay(alignment: .topTrailing) {
            ShaftChromeRail(session: session)
                .padding(.trailing, ChromeSpace.unit)
        }
        .overlay(alignment: .bottom) {
            if let notice = session.notice {
                noticePlate(notice)
                    .padding(ChromeSpace.unit * 2)
            }
        }
    }

    private var ghostLevels: [Level] {
        session.snapshot.levels
            .filter { $0.index < session.snapshot.delverDepth }
            .sorted { $0.index < $1.index }
    }

    private var aheadLevels: [Level] {
        var levels = session.snapshot.levels.filter { $0.index > session.snapshot.delverDepth }
        let upcoming = session.snapshot.delverDepth + 1
        if !levels.contains(where: { $0.index == upcoming }) {
            levels.append(Level.fresh(index: upcoming))
        }
        return levels.sorted { $0.index < $1.index }
    }

    private func hero(_ level: Level) -> some View {
        VStack(alignment: .leading, spacing: ChromeSpace.unit) {
            HStack(alignment: .center, spacing: ChromeSpace.unit) {
                DelverMarker(active: true)
                LockplateView(
                    level: level,
                    enabled: !session.alreadyToday,
                    busy: session.isTurning,
                    sweepToken: session.sweepToken
                ) {
                    Task { await session.alignToday() }
                }
            }
            if session.expandedIndex == level.index {
                LevelInspector(level: level, marks: session.snapshot.marks)
            }
        }
    }

    private func ghost(_ level: Level) -> some View {
        let shown = ChromeNumber.integer(level.index)
        return VStack(alignment: .leading, spacing: ChromeSpace.unit) {
            Button {
                session.expandedIndex = session.expandedIndex == level.index ? nil : level.index
            } label: {
                VStack(alignment: .leading, spacing: ChromeSpace.unit) {
                    HStack(spacing: ChromeSpace.unit) {
                        DelverMarker(active: false)
                        Text("Level \(shown)")
                            .font(ChromeType.caption(ChromeType.captionSize).monospacedDigit())
                            .foregroundStyle(ChromeColor.ink)
                            .lineLimit(1)
                        Text(level.hatchOpen ? "Cleared." : "Locked again.")
                            .font(ChromeType.caption(ChromeType.captionSize))
                            .foregroundStyle(ChromeColor.muted)
                            .lineLimit(1)
                    }
                    Rectangle()
                        .fill(ChromeColor.muted)
                        .frame(height: ChromeSpace.hairline)
                }
                .padding(.horizontal, ChromeSpace.unit)
                .frame(maxWidth: .infinity, minHeight: ChromeSpace.hit, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(ChromePressStyle())
            .accessibilityLabel("Level \(shown), \(level.hatchOpen ? "cleared" : "locked again")")
            if session.expandedIndex == level.index {
                LevelInspector(level: level, marks: session.snapshot.marks)
            }
        }
    }

    private func waiting(_ level: Level) -> some View {
        let leftBehind = level.index <= session.snapshot.deepestDepth
            && session.snapshot.level(at: level.index) != nil
        let rule = leftBehind ? "PASSED" : (level.isVault ? "WEEK" : "NEXT")
        let line: String = {
            if leftBehind {
                return "This depth is already cut. It sits below the held place."
            }
            if level.isVault {
                return "Five pins this week open the weekly prize."
            }
            return "The next door stays locked until this plate seats three pins."
        }()
        let shown = ChromeNumber.integer(level.index)
        return VStack(alignment: .leading, spacing: ChromeSpace.unit) {
            Button {
                session.expandedIndex = session.expandedIndex == level.index ? nil : level.index
            } label: {
                VStack(alignment: .leading, spacing: ChromeSpace.unit) {
                    Text(rule)
                        .font(ChromeType.rule(ChromeType.sectionSize))
                        .tracking(0.6)
                        .foregroundStyle(ChromeColor.muted)
                    Text(line)
                        .font(ChromeType.body(ChromeType.bodySize))
                        .lineSpacing(ChromeType.bodyLeading)
                        .foregroundStyle(ChromeColor.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    if level.isVault {
                        VaultWeekMeter(count: session.weekCount, embedded: true)
                    }
                }
                .padding(ChromeSpace.unit * 2)
                .frame(
                    maxWidth: .infinity,
                    minHeight: level.isVault ? ChromeSpace.hero : ChromeSpace.ghost,
                    alignment: .leading
                )
                .background(ChromeColor.surface, in: RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous)
                        .strokeBorder(ChromeColor.muted, lineWidth: ChromeSpace.hairline)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(ChromePressStyle())
            .accessibilityLabel(
                leftBehind
                    ? "Passed depth \(shown)"
                    : (level.isVault ? "Weekly prize at the next level" : "Next level")
            )
            if session.expandedIndex == level.index {
                LevelInspector(level: level, marks: session.snapshot.marks)
            }
        }
    }

    private var backslideBanner: some View {
        Button {
            session.sheet = .backslide
        } label: {
            VStack(alignment: .leading, spacing: ChromeSpace.unit) {
                Text("BACKSLIDE")
                    .font(ChromeType.rule(ChromeType.sectionSize))
                    .tracking(0.6)
                    .foregroundStyle(ChromeColor.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("Three missed days in a row lift you one level and lock the door above.")
                    .font(ChromeType.body(ChromeType.bodySize))
                    .lineSpacing(ChromeType.bodyLeading)
                    .foregroundStyle(ChromeColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Open the record.")
                    .font(ChromeType.caption(ChromeType.captionSize))
                    .lineSpacing(ChromeType.captionLeading)
                    .foregroundStyle(ChromeColor.muted)
            }
            .padding(ChromeSpace.unit * 2)
            .frame(maxWidth: .infinity, minHeight: ChromeSpace.ghost, alignment: .leading)
            .background(ChromeColor.surface, in: RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous)
                    .strokeBorder(ChromeColor.muted, lineWidth: ChromeSpace.hairline)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(ChromePressStyle())
        .accessibilityLabel("Backslide depth")
        .accessibilityHint("Opens the backslide record.")
    }

    private func noticePlate(_ notice: String) -> some View {
        HStack(alignment: .center, spacing: ChromeSpace.unit) {
            if UIImage(named: "hyp_SuccessMark") != nil {
                Image("hyp_SuccessMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: ChromeSpace.hit, height: ChromeSpace.hit)
                    .clipped()
                    .accessibilityHidden(true)
            }
            Text(notice)
                .font(ChromeType.caption(ChromeType.captionSize))
                .lineSpacing(ChromeType.captionLeading)
                .foregroundStyle(ChromeColor.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(ChromeSpace.unit * 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ChromeColor.surface, in: RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous)
                .strokeBorder(ChromeColor.muted, lineWidth: ChromeSpace.hairline)
        }
    }

    private var loading: some View {
        VStack(alignment: .leading, spacing: ChromeSpace.unit * 2) {
            RoundedRectangle(cornerRadius: ChromeRadius.outer).fill(ChromeColor.surface).frame(height: ChromeSpace.rail)
            RoundedRectangle(cornerRadius: ChromeRadius.outer).fill(ChromeColor.surface).frame(height: ChromeSpace.hero)
            if session.showSpinner {
                ProgressView().tint(ChromeColor.accent)
            }
        }
        .padding(ChromeSpace.unit * 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    private func sheetBody(_ sheet: ShaftSession.Sheet) -> some View {
        switch sheet {
        case .journal:
            JournalSheet(session: session)
                .presentationDetents([.large])
        case .hero:
            HeroSheet(session: session)
                .presentationDetents([.large])
        case .settings:
            SettingsSheet(session: session)
                .presentationDetents([.medium, .large])
        case .backslide:
            BackslideDepthView(session: session)
                .presentationDetents([.large])
        }
    }
}

struct DelverRail: View {
    let session: ShaftSession
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: ChromeSpace.unit) {
            railLine("Now", session.snapshot.delverDepth)
            railLine("Points", session.snapshot.totalXP)
            railLine("Rank", session.snapshot.delver.heroLevel)
            railLine("Run", session.streak)
            Spacer(minLength: 0)
        }
        .padding(ChromeSpace.unit)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            ChromeGlassBackground(tint: ChromeColor.ink.opacity(0.08))
        }
        .overlay {
            RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous)
                .strokeBorder(ChromeColor.muted, lineWidth: ChromeSpace.hairline)
        }
        .clipShape(RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous))
    }

    private func railLine(_ title: String, _ value: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(ChromeType.rule(ChromeType.sectionSize))
                .tracking(0.6)
                .foregroundStyle(ChromeColor.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
            Text(ChromeNumber.integer(value))
                .font(ChromeType.body(ChromeType.figureSize).monospacedDigit())
                .foregroundStyle(ChromeColor.ink)
                .contentTransition(reduceMotion ? .identity : .numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.9)
        }
    }
}

struct VaultWeekMeter: View {
    let count: Int
    var embedded = false

    var body: some View {
        let shown = ChromeNumber.integer(count)
        let cap = ChromeNumber.integer(5)
        return VStack(alignment: .leading, spacing: ChromeSpace.unit) {
            if !embedded {
                Text("THIS WEEK")
                    .font(ChromeType.rule(ChromeType.sectionSize))
                    .tracking(0.6)
                    .foregroundStyle(ChromeColor.muted)
            }
            Text("\(shown) of \(cap) pins this week.")
                .font(ChromeType.body(ChromeType.bodySize).monospacedDigit())
                .foregroundStyle(ChromeColor.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
            HStack(spacing: ChromeSpace.unit) {
                ForEach(0..<5, id: \.self) { index in
                    RoundedRectangle(cornerRadius: ChromeRadius.inner, style: .continuous)
                        .fill(index < count ? ChromeColor.accent : ChromeColor.background)
                        .frame(height: ChromeSpace.unit)
                        .overlay {
                            RoundedRectangle(cornerRadius: ChromeRadius.inner, style: .continuous)
                                .strokeBorder(ChromeColor.muted, lineWidth: ChromeSpace.hairline)
                        }
                        .accessibilityLabel(index < count ? "Week pin seated" : "Week pin open")
                }
            }
        }
        .padding(embedded ? 0 : ChromeSpace.unit * 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            ChromeGlassBackground(tint: ChromeColor.ink.opacity(0.08))
        }
        .overlay {
            RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous)
                .strokeBorder(ChromeColor.muted, lineWidth: ChromeSpace.hairline)
        }
        .clipShape(RoundedRectangle(cornerRadius: ChromeRadius.outer, style: .continuous))
    }
}

struct LevelInspector: View {
    let level: Level
    let marks: [LedgerRow]

    var body: some View {
        let dates = marks.filter { $0.levelIndex == level.index }
        let pinsText = ChromeNumber.integer(level.pins)
        return VStack(alignment: .leading, spacing: ChromeSpace.unit) {
            Text("Pins \(pinsText)")
                .font(ChromeType.body(ChromeType.bodySize).monospacedDigit())
                .foregroundStyle(ChromeColor.ink)
            Text(level.isVault ? (level.cracked ? "Weekly prize open." : "Weekly prize locked.") : "Ordinary level.")
                .font(ChromeType.body(ChromeType.bodySize))
                .foregroundStyle(ChromeColor.muted)
            ForEach(dates) { row in
                Text(ChromeNumber.dayKey(row.dayKey.raw))
                    .font(ChromeType.caption(ChromeType.captionSize).monospacedDigit())
                    .foregroundStyle(ChromeColor.ink)
            }
        }
        .padding(ChromeSpace.unit * 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .chromePlate()
    }
}

struct ShaftChromeRail: View {
    @Bindable var session: ShaftSession

    var body: some View {
        VStack(spacing: ChromeSpace.unit) {
            railButton("text.book.closed", "Journal") { session.sheet = .journal }
            railButton("person", "Hero") { session.sheet = .hero }
            railButton("gearshape", "Settings") { session.sheet = .settings }
        }
        .padding(ChromeSpace.unit)
    }

    private func railButton(_ symbol: String, _ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(ChromeType.body(ChromeType.bodySize))
                .foregroundStyle(ChromeColor.ink)
                .frame(width: ChromeSpace.hit, height: ChromeSpace.hit)
                .background(ChromeColor.surface, in: RoundedRectangle(cornerRadius: ChromeRadius.inner, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: ChromeRadius.inner, style: .continuous)
                        .strokeBorder(ChromeColor.muted, lineWidth: ChromeSpace.hairline)
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(ChromePressStyle())
        .accessibilityLabel(label)
    }
}

struct ShaftStatusPage: View {
    let title: String
    let line: String
    let art: String
    let actionTitle: String
    let action: () -> Void
    var glassBackdrop = false

    var body: some View {
        VStack(alignment: .leading, spacing: ChromeSpace.unit * 2) {
            Image(art)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: ChromeSpace.unit * 20, maxHeight: ChromeSpace.unit * 20)
                .accessibilityHidden(true)
            Text(title)
                .font(ChromeType.display(ChromeType.displaySize))
                .tracking(-0.8)
                .foregroundStyle(ChromeColor.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
            Text(line)
                .font(ChromeType.body(ChromeType.bodySize))
                .foregroundStyle(ChromeColor.muted)
            Spacer(minLength: ChromeSpace.unit * 2)
            Button(actionTitle, action: action)
                .buttonStyle(ChromeButtonStyle())
        }
        .padding(ChromeSpace.unit * 3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background {
            if glassBackdrop {
                Color.clear
            } else {
                ChromeColor.background
            }
        }
    }
}
