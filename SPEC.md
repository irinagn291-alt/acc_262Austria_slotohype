# Hypogeum — Build Specification

> Portfolio app 132, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Align one pin a day to descend the shaft.

| Field | Value |
| --- | --- |
| Product name | Hypogeum |
| Bundle identifier | `com.hypogeum.shaft` |
| Domain | https://hypogeum-shaft.pro |
| Contact URL | https://hypogeum-shaft.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Dark |
| Asset prefix | `hyp_` |
| User-Agent | `Hypogeum/1.0 (iOS; +https://hypogeum-shaft.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Hypogeum -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A delver aligns today's pin on the lockplate so the hatch to the next depth opens after three consecutive pins.

### 2.1 User flow

1. Launch opens the shaft showing the delver at the current depth and today's lockplate with pins from the seed already aligned.
2. Tap the lockplate to align today's pin — one pin slides into place, a TumblerMark writes, and XP increments.
3. After three consecutive pins the hatch opens and the delver descends one level; the next lockplate resets to zero pins.
4. A missed day clears all pins; three consecutive misses also backslide the delver one level and relock the hatch above.
5. On every fifth level a vault glows — five TumblerMarks that calendar week crack the vault for double XP.
6. Swipe to the journal sheet to read dated TumblerMarks, TrapMarks, backslide events, and the deepest level reached.
7. Open the hero sheet to see total pins, current depth, XP, delver level, and longest streak.

### 2.2 Essential behaviour

- Shaft map — vertical stack of depth levels; each lockplate shows zero to three aligned pins; the delver marker sits at the current depth.
- Tumbler lock — three consecutive daily pins open the hatch; a miss clears all pins to zero.
- Backslide penalty — three consecutive misses ascend the delver one level and relock the hatch above.
- Vault boss — every fifth level; five TumblerMarks in one calendar week crack the vault for double XP.
- XP and leveling — each pin adds XP; level equals one plus totalXP divided by one hundred.
- Journal sheet — dated turn log with streak annotations, backslide events, and a depth sparkline.
- Daily reminder — local notification at a user-set time.

---

## 3. Uniqueness assignment for Hypogeum

| Axis | Assigned value |
| --- | --- |
| Architecture | **Tumbler-gate descent (Level holds pins 0..3; Turn aligns one Pin and writes a TumblerMark; three consecutive Pins open the Hatch and descend the Delver; a missed day clears all Pins; three consecutive misses backslide one Level; every fifth Level is a Vault requiring five weekly Turns for double XP; the Shaft is a stack of Levels; depth is the Delver index)** |
| UI approach | **SwiftUI Metal shaders · material** |
| Naming convention | **Speleology / depth-gate lexicon** |
| File organization | **By shaft role (Level, Hatch, Pin, Lockplate, TumblerMark, TrapMark, Vault, Delver) · 4d2e12fd22** |
| Dependency strategy | **SPM remote x1** |
| Design direction | **nvidia · masonry · branded** |
| Typography | **Verdana** |
| Navigation pattern | **Shaft-locked chrome (the shaft map never leaves; Journal, Hero and Settings arrive as sheets) · 4d2e12fd22** |
| AI art style | **Liquid chrome metallic render · documentary** |
| Functional twist | **Backslide depth (three consecutive misses ascend the delver one level and relock the hatch)** |
| Persistence | **SQLite raw** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — habit_rpg

**Core** — A delver aligns today's pin on the lockplate so the hatch to the next depth opens after three consecutive pins.

**Audience** — People who will do a daily chore for a deeper shaft, not a checkbox that advances itself.

**User flow**

1. Launch opens the shaft showing the delver at the current depth and today's lockplate with pins from the seed already aligned.
2. Tap the lockplate to align today's pin — one pin slides into place, a TumblerMark writes, and XP increments.
3. After three consecutive pins the hatch opens and the delver descends one level; the next lockplate resets to zero pins.
4. A missed day clears all pins; three consecutive misses also backslide the delver one level and relock the hatch above.
5. On every fifth level a vault glows — five TumblerMarks that calendar week crack the vault for double XP.
6. Swipe to the journal sheet to read dated TumblerMarks, TrapMarks, backslide events, and the deepest level reached.
7. Open the hero sheet to see total pins, current depth, XP, delver level, and longest streak.

**Essential features**

- Shaft map — vertical stack of depth levels; each lockplate shows zero to three aligned pins; the delver marker sits at the current depth.
- Tumbler lock — three consecutive daily pins open the hatch; a miss clears all pins to zero.
- Backslide penalty — three consecutive misses ascend the delver one level and relock the hatch above.
- Vault boss — every fifth level; five TumblerMarks in one calendar week crack the vault for double XP.
- XP and leveling — each pin adds XP; level equals one plus totalXP divided by one hundred.
- Journal sheet — dated turn log with streak annotations, backslide events, and a depth sparkline.
- Daily reminder — local notification at a user-set time.

**Twist** — Backslide depth. Home is the shaft. Tapping today aligns one Pin on the Lockplate and writes a TumblerMark; XP increments. Three consecutive Pins open the Hatch and the Delver descends; the next Lockplate resets. A missed day clears all Pins. Three consecutive missed days also ascend the Delver one level — a backslide — and relock the Hatch above. Cleared Levels below the current depth stay visible on the shaft as ghost levels. Every fifth Level is a Vault; five TumblerMarks in that calendar week crack the Vault and award double XP; fewer by week-end writes a TrapMark and the Vault stays locked but the shaft continues down. Seed already aligns two Pins so the opening tap can open the first Hatch. The job on home is align-the-pin, not pick-a-fork and not close-a-ring.

**Why this is not a repeat** — Hypogeum shares the habit_rpg family with Guidestoop but inverts the spatial metaphor and the home verb entirely. Guidestoop is a horizontal forking waymap: the walker picks one of two roads and seals the other; the map fans outward and the player shapes breadth. Hypogeum is a vertical shaft descent: the delver aligns tumbler pins and drops through a hatch; the map grows downward and the player shapes depth. There is no fork and no seal — progress is linear, and the only decision is whether to align today's pin. The backslide penalty (three consecutive misses ascend the delver one level and relock the hatch above) has no equivalent in Guidestoop, where a missed streak merely resets the stake count without losing map ground. The vault boss is calendar-week gated with double XP, unlike Guidestoop's five-of-seven bonus that keeps accumulated XP. The naming lexicon is speleological (pin, lockplate, hatch, shaft, vault) versus waymark (cairn, camp, road, seal, fork). UIKit manual frame layout replaces SwiftUI Canvas. Charcoal precision replaces moorland waymap. The core verb on home is align-the-pin, not pick-a-fork.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: World map. Nodes unlock. Weekly boss.
- Invariant: One completion/day. Streak continues iff yesterday. Unlock next node at streak ≥ 3. XP += value; level = 1 + totalXP/100. Boss: 5 completions → bonus XP.
- Never: Cosmetic skins only. No social server.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

### 3.1 Architecture contract

The Shaft is an ordered stack of Level values, each holding pins 0...3, a hatchOpen flag, and an isVault flag on every fifth index. The single persisted verb is a Turn: it aligns one Pin on today's Lockplate, writes a TumblerMark stamped with the YYYYMMDD dayKey, and adds XP so that level equals 1 plus totalXP divided by 100. TumblerEngine is a pure value type that folds the dayKey ordered mark history into shaft state, so every rule is arithmetic over [TumblerMark] rather than view state: a Turn continues the run only if the previous mark's dayKey is yesterday by Calendar.current.startOfDay, three consecutive Pins open the Hatch and advance the Delver one index deeper, and the next Lockplate resets to zero Pins. A missed day clears all Pins on the current Lockplate, and three consecutive missed days fire BackslideRule, which ascends the Delver one Level and relocks the Hatch above it. Every fifth Level is a Vault: five TumblerMarks inside the same calendar week crack it for double XP, while fewer by week end writes a TrapMark and leaves the Vault locked, though the Shaft still continues downward. Cleared Levels stay in the stack as ghost Levels so the whole descent, including relocked ground, reads as one continuous column.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

Home is the Shaft itself, a vertical masonry column of Level tiles under a fixed Delver rail, not a list of records. Level tiles are uneven by role: the current Lockplate is the hero tile at roughly 2.2 times the height of a ghost tile, Vault tiles run double width, and cleared Levels collapse to hairline ruled strips so the column never leaves an empty hole. The Lockplate draws its three Pin seats through a SwiftUI Shader (layerEffect over a Chrome.metal fragment function) that sweeps a liquid metal highlight across the plate once when a Pin seats, 180ms cross fade, no travel, and the shader is swapped for a flat fill when accessibilityReduceMotion is on. Material is the second surface language: the Delver rail, the sheet backgrounds, and the Vault week meter sit on ultraThinMaterial tinted glass over the shaft, hairline stroked, one radius kit at 14 outer and 6 inner. The depth number, XP, and streak tick with monospaced digits and never fly. One accent hit lives on the live verb, the tappable Lockplate; relock, backslide, and TrapMark are carried by weight, rule thickness, and a VoiceOver label, never by colour alone. Tap targets are the whole tile: Button label wraps the tile chrome with contentShape(Rectangle()) and a 44pt floor, and one haptic fires on a committed Turn only.

### 3.3 Naming contract

Convention: Speleology / depth-gate lexicon.

Examples to follow: ['TumblerEngine.turn(on:) returning a SeatedPin or a BlockedTurn reason', 'LockplateView with PinSeat, HatchGateView, and DelverMarker', 'TumblerMark and TrapMark as the two dated ledger rows', 'VaultWeek.crack(marks:) and BackslideRule.apply(missedDays:)']

### 3.4 Dependency contract

Exactly one remote SPM package: apple/swift-collections pinned to exact version 1.1.4, importing only DequeModule so the Shaft is a Deque<Level> with O(1) work at both ends as the Delver descends or backslides. Nothing else is remote: SQLite is the system libsqlite3 reached through a module map, Metal and SwiftUI are first party, and there is no analytics, networking, ad, or push SDK in the binary. The package is referenced by Store and Shaft targets only, so the UI layer never imports it. No CocoaPods, no vendored binaries, no XCFramework.

### 3.5 Navigation contract

There is no TabView anywhere in the binary, so the three tab factory stamp cannot occur. The Shaft map is the root view and never unmounts: it is the only full screen surface after onboarding, and it keeps its scroll anchor at the Delver depth for the life of the process. Three icon only chrome buttons live in a vertical rail pinned to the trailing safe area of the Shaft, each 44pt with a VoiceOver label, and each presents a sheet over the still visible shaft: Journal at .large, Hero at .medium then .large, Settings at .medium. Sheets are siblings, never stacked on each other, and dismiss returns the Delver to the same depth with no reload. Tapping a ghost Level expands that tile inline on the shaft rather than pushing a route. ProcessInfo.processInfo.arguments is read once in onAppear on the Shaft after onboarding completion is confirmed: -ReviewScreen today leaves the bare shaft, log presents the Journal sheet, goals presents the Hero sheet, and settings presents the Settings sheet, four different frames.

### 3.6 Screen composition contract

Depth-stack descent screens

1. Onboarding, three full page panes on generated art, one headline and one line each, Descend as a bottom full width CTA, shown once and skipped on Simulator after seed. 2. Shaft, the root and home, masonry column of Level tiles with the current Lockplate as hero, the Delver rail on the leading edge showing depth, XP, delver level and streak, the Vault week meter when the next Level is a Vault, and the trailing chrome rail. 3. Journal sheet, dated ledger of TumblerMarks and TrapMarks with backslide events called out in bold rule, a depth sparkline header, and a full page empty state reading The path is closed. Finish three days to open the next node. 4. Hero sheet, total pins, current depth, XP, delver level, longest streak, deepest level reached, all tabular, plus the vaults cracked count. 5. Settings sheet, daily reminder time picker with local notification authorization, haptics toggle, contact URL at hypogeum-shaft.pro, and a destructive Reset shaft confirm that names the shaft and the loss of every TumblerMark. 6. Level inspector, an inline expansion on the Shaft tile, not a route, showing that Level's pins, dates, and vault status.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By shaft role (Level, Hatch, Pin, Lockplate, TumblerMark, TrapMark, Vault, Delver) · 4d2e12fd22**

```
Hypogeum/
  Hypogeum/
  HypogeumApp.swift
  Shaft/ ShaftView.swift, ShaftColumn.swift, ShaftScrollAnchor.swift, ShaftEmptyState.swift
  Level/ Level.swift, LevelTile.swift, GhostLevelStrip.swift, LevelInspector.swift
  Lockplate/ Lockplate.swift, LockplateView.swift, PinSeat.swift
  Pin/ Pin.swift, PinCount.swift
  Hatch/ Hatch.swift, HatchGateView.swift
  TumblerMark/ TumblerMark.swift, TumblerMarkRow.swift
  TrapMark/ TrapMark.swift, TrapMarkRow.swift
  Vault/ Vault.swift, VaultTile.swift, VaultWeek.swift
  Delver/ Delver.swift, DelverRail.swift, DelverMarker.swift, DelverXP.swift
  Descent/ TumblerEngine.swift, BackslideRule.swift, DayKey.swift, WeekWindow.swift
  Sheets/ JournalSheet.swift, HeroSheet.swift, SettingsSheet.swift
  Store/ ShaftDatabase.swift, Schema.swift, Statement.swift, Migration.swift, SQLite3.modulemap
  Kit/ Tokens.swift, TypeScale.swift, Space.swift, Radius.swift, ChromeButtonStyle.swift, MasonryColumn.swift, Motion.swift
  Shaders/ Chrome.metal, PlateSweep.metal
  Notify/ Reminder.swift
  Review/ ReviewScreen.swift, DemoSeed.swift
  Onboarding/ OnboardingFlow.swift
  Resources/ Assets.xcassets, Info.plist
HypogeumTests/ TumblerEngineTests.swift, BackslideRuleTests.swift, VaultWeekTests.swift, DayKeyTests.swift, ShaftDatabaseTests.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Map
A first-class screen for **Map**. Must render empty, populated and error states.

### 5.3 Journal
A first-class screen for **Journal**. Must render empty, populated and error states.

### 5.4 Hero
A first-class screen for **Hero**. Must render empty, populated and error states.

### 5.5 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.6 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.7 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **Quest** — named per this app's convention.
- **Avatar** — named per this app's convention.
- **WeeklyBoss** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **nvidia · masonry · branded**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#000000` | Screen background |
| `surface` | `#1E1E1E` | Cards, rows, sheets |
| `ink` | `#FFFFFF` | Primary text and icons |
| `accent` | `#F9D4FF` | Primary action, key figure, progress fill |
| `muted` | `#A5A5A5` | Secondary text, dividers, disabled |

Define these as named colours in `Assets.xcassets` and reach them through one
typed accessor. Never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **Verdana**

Verdana is the whole type system, loaded with Font.custom("Verdana", size:relativeTo:) so Dynamic Type still scales, and custom sizes use ScaledMetric. Verdana is wide, loose fitted, and large on the body, so the scale is pulled down and tightened rather than run at nominal: display Verdana Bold 34 over 40 with tracking minus 0.8 and a hard 2 line cap, section rule labels Verdana Bold 13 with tracking plus 0.6 and uppercase reserved for the hairline rules only, body Verdana 16 over 24 because Verdana's x height reads about one step larger than SF, caption Verdana 12 over 16. Every number, the depth index, pin count, XP, streak, and the dayKey in the Journal, uses monospacedDigit() so the ledger columns lock and values tick in place, and all of it runs through NumberFormatter. There is no second family and no display face: Verdana Bold is the display voice, hairline rules carry hierarchy instead of size jumps. Headlines are checked at AX5 with minimumScaleFactor(0.9) and lineLimit set by the tile, never clipped.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **14pt** for cards, sheets and primary surfaces; **6pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **hairline+fill** — a 1pt hairline border plus a flat fill tint, reused everywhere a surface sits above another.

Primary control: **tinted glass** — primary chrome sits on a tinted translucent surface (`Material` plus the accent colour at low opacity), never plain flat colour.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI Metal shaders · material**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI Metal shaders · material** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **agency** (High-end agency: huge type, air, one accent, hairline depth.)

Reference system: **nvidia** — steal rhythm and restraint, not their colours or logos.

Mood: **GPU computing. Green-black energy, technical power aesthetic.**.

Home rhythm (`masonry`, comfortable): Uneven tiles, no empty hole, one hero tile larger than the rest.

High-end agency: huge type, air, one accent, hairline depth. Layout `masonry`, density comfortable. Kit 14/6, hairline+fill, tinted glass. Palette recipe `branded`. Almost no travel. Cross-fade 180ms ease-out. Numbers tick, they do not fly. Reduce Motion: instant swap. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: Tabular figures, no display face, hairline rules. Reference type feel: agency.

Motion (`quiet`): Almost no travel. Cross-fade 180ms ease-out. Numbers tick, they do not fly. Reduce Motion: instant swap.

Voice (`editorial`): Complete sentences, no slang, no hype. Captions are real lines.

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **SQLite raw**

Raw SQLite through the system libsqlite3 C API, no wrapper and no ORM: one ShaftDatabase actor owns a single sqlite3 handle opened in Application Support with journal_mode WAL and foreign_keys ON, and every query is a cached prepared sqlite3_stmt bound with sqlite3_bind_int and sqlite3_bind_text. Schema: level(idx INTEGER PRIMARY KEY, pins INTEGER NOT NULL CHECK(pins BETWEEN 0 AND 3), hatch_open INTEGER NOT NULL, is_vault INTEGER NOT NULL, cracked INTEGER NOT NULL); mark(day_key INTEGER PRIMARY KEY, level_idx INTEGER NOT NULL REFERENCES level(idx), kind TEXT NOT NULL, xp INTEGER NOT NULL); meta(key TEXT PRIMARY KEY, value TEXT NOT NULL). day_key is the Int YYYYMMDD from Calendar.current.startOfDay and is the primary key on mark, which is what enforces one completion per day at the storage layer. A Turn is one transaction: insert the mark, update the Level's pins, and on the third consecutive Pin flip hatch_open and bump the delver depth in meta, all committed or all rolled back. meta also holds total_xp, delver_depth, deepest_depth, reminder_time, schema_version, and hyp.demo.v1 so the Simulator seed runs once and never on device. Migration.swift steps user_version forward; there is no CloudKit and nothing leaves the device.

This app talks to **SQLite through the C API**. The following are mandatory.

- Open with `sqlite3_open_v2` and the flags you actually need. Check the return
  code of every single `sqlite3_*` call and map failures to a typed Swift error.
- Every prepared statement is finalised. Use `defer { sqlite3_finalize(stmt) }`
  immediately after a successful `sqlite3_prepare_v2`. A leaked statement holds
  a read transaction open and eventually blocks all writes.
- Bind text with the `SQLITE_TRANSIENT` destructor, otherwise the string can be
  deallocated before the statement runs:
  `sqlite3_bind_text(stmt, i, value, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))`.
- Enable `PRAGMA journal_mode = WAL;` and `PRAGMA foreign_keys = ON;` at open.
- Wrap every multi-row write in `BEGIN` / `COMMIT`, with `ROLLBACK` on error.
  Row-at-a-time autocommit is roughly two orders of magnitude slower.
- Serialise all database access through one actor or one serial queue. Do not
  share a connection across threads.
- Version the schema with `PRAGMA user_version` and apply migrations in order at
  startup.
- Create indices for every column you filter or sort by, in particular the day
  column and the barcode column.
- Store dates as integer epoch seconds, never as localised strings.
- The UI layer never sees a statement or a row cursor; the storage layer returns
  fully materialised value types.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Hypogeum/1.0 (iOS; +https://hypogeum-shaft.pro)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.lifestyle`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Dark
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.lifestyle
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Backslide depth (three consecutive misses ascend the delver one level and relock the hatch)

Backslide depth is the only way the Shaft can lose ground, and it is the reason a missed day costs more than a reset counter. One missed day clears the current Lockplate to zero Pins, which is the ordinary streak break. Three consecutive missed days go further: BackslideRule ascends the Delver one Level, relocks the Hatch above it, and writes a dated backslide row into the Journal so the loss is legible next to the marks that earned the descent. The Level the Delver retreats into keeps its ghost styling on the shaft, so the column shows both the deepest depth reached and the depth currently held, and those two numbers are allowed to disagree. Backslide never deletes TumblerMarks or XP: delver level stays at 1 plus totalXP divided by 100, so the player keeps what they earned and loses only position, which is what makes returning worth the tap. The seed aligns two Pins on the opening Lockplate so the very first Turn opens the first Hatch and the mechanic is understood before it can punish.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Liquid chrome metallic render · documentary**


Base prompt, reused and extended for every asset:

```
Liquid chrome metallic render in a documentary register: heavy polished alloy forms photographed as found objects rather than styled hero product shots, hard studio key from the upper left with a long soft fill, sharp specular ribbons pooling and stretching across the surface like poured mercury coming to rest. Surfaces are machined, not decorative: milling witness marks, chamfered edges, a faint brushed grain under the polish, micro pitting and shallow wear on the working faces. Macro focal length, shallow but honest depth of field, real lens falloff at the frame edge, slight sensor grain, no gloss overlay and no lens flare. Physically based reflections that read as an unseen room, not a gradient. Tonal render only, values carried by specular and shadow, palette applied separately. No text, no logotype, no emoji, no UI chrome.
```

All 18 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `hyp_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `hyp_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `hyp_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `hyp_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `hyp_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `hyp_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `hyp_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `hyp_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `hyp_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `hyp_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `hyp_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Backslide depth (three consecutive misses ascend the delver one level and relock the hatch)' feature screen. |
| 11 | `hyp_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `hyp_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |
| 13 | `hyp_LockplateEmblem` | 1024x1024 | **required cutout** | Cutout on fully transparent ground, real PNG alpha, transparent corners, solid opaque subject filling the center. A single machined lockplate slab, three pin seats bored in a vertical run, two seats filled and one open, polished chrome faces with chamfered edges and visible tool marks. One solid object, no plate behind it, no glass, no wireframe, no shadow, no text. |
| 14 | `hyp_HatchSeal` | 1024x1024 | **required cutout** | Cutout on fully transparent ground, real PNG alpha, transparent corners, solid opaque subject in the center. A heavy circular alloy hatch, radial locking dogs retracted, one liquid chrome highlight arcing across the face, deep machined kerf around the rim. Solid metal body, not hollow, not a ring with an empty middle, no frame, no text. |
| 15 | `hyp_DelverMark` | 1024x1024 | **required cutout** | Cutout on fully transparent ground, real PNG alpha, transparent corners, solid opaque subject in the center. A compact cast alloy marker shaped like a descending wedge with a single bored eyelet, polished top face, rough cast underside, one liquid chrome specular running the length of the wedge. One solid object, no base plate, no glass, no text. |
| 16 | `hyp_VaultSigil` | 1024x1024 | **required cutout** | Cutout on fully transparent ground, real PNG alpha, transparent corners, solid opaque subject in the center. A thick vault door boss, five machined bolt heads set around a solid polished center disc, heavy chamfers, liquid chrome highlight pooling on the disc. Solid throughout, no hollow center, no surrounding frame, no text. |
| 17 | `hyp_TrapSigil` | 1024x1024 | **required cutout** | Cutout on fully transparent ground, real PNG alpha, transparent corners, solid opaque subject in the center. A sprung alloy catch, one jaw closed on an empty pin seat, dull worn metal with only a weak broken highlight compared to the other pieces, visible scoring and fatigue on the jaw. One solid object, no ground, no glass, no text. |
| 18 | `hyp_JournalEmptyArt` | 1024x1024 | **required cutout** | Cutout on fully transparent ground, real PNG alpha, transparent corners, solid opaque subject in the center. A blank machined tally slab with three empty bored marks and no stamps struck into it, quiet matte finish with one restrained chrome edge highlight. Solid slab, not hollow, no frame, no paper, no text. |

### Prompt per asset

**`hyp_AppIcon`** — 1024x1024

```
Full bleed square, no transparency, no text. A single machined lockplate face viewed straight on and slightly off center, three circular pin seats in a vertical run with the lowest seat filled by a seated pin, liquid chrome specular sweeping diagonally across the plate, hairline chamfer catching the key light, deep matte ground behind it. Bold silhouette that survives at 40pt, one subject, no border, no lettering.
```

**`hyp_Splash`** — 1290x2796

```
Full bleed vertical composition, no transparency. Looking straight down a machined shaft: concentric alloy ring hatches receding into darkness, each ring catching a thinner liquid chrome highlight than the one above it, the lowest ring almost lost in the dark. Documentary macro photography, real falloff, heavy air, nothing centered on a glyph, no text.
```

**`hyp_Onboarding1`** — 1024x1536

```
Liquid chrome metallic render in a documentary register: heavy polished alloy forms photographed as found objects rather than styled hero product shots, hard studio key from the upper left with a long soft fill, sharp specular ribbons pooling and stretching across the surface like poured mercury coming to rest. Surfaces are machined, not decorative: milling witness marks, chamfered edges, a faint brushed grain under the polish, micro pitting and shallow wear on the working faces. Macro focal length, shallow but honest depth of field, real lens falloff at the frame edge, slight sensor grain, no gloss overlay and no lens flare. Physically based reflections that read as an unseen room, not a gradient. Tonal render only, values carried by specular and shadow, palette applied separately. No text, no logotype, no emoji, no UI chrome., a person or object that is this product in one glance

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hyp_Onboarding2`** — 1024x1536

```
Liquid chrome metallic render in a documentary register: heavy polished alloy forms photographed as found objects rather than styled hero product shots, hard studio key from the upper left with a long soft fill, sharp specular ribbons pooling and stretching across the surface like poured mercury coming to rest. Surfaces are machined, not decorative: milling witness marks, chamfered edges, a faint brushed grain under the polish, micro pitting and shallow wear on the working faces. Macro focal length, shallow but honest depth of field, real lens falloff at the frame edge, slight sensor grain, no gloss overlay and no lens flare. Physically based reflections that read as an unseen room, not a gradient. Tonal render only, values carried by specular and shadow, palette applied separately. No text, no logotype, no emoji, no UI chrome., the primary action of this product, mid-gesture

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hyp_Onboarding3`** — 1024x1536

```
Liquid chrome metallic render in a documentary register: heavy polished alloy forms photographed as found objects rather than styled hero product shots, hard studio key from the upper left with a long soft fill, sharp specular ribbons pooling and stretching across the surface like poured mercury coming to rest. Surfaces are machined, not decorative: milling witness marks, chamfered edges, a faint brushed grain under the polish, micro pitting and shallow wear on the working faces. Macro focal length, shallow but honest depth of field, real lens falloff at the frame edge, slight sensor grain, no gloss overlay and no lens flare. Physically based reflections that read as an unseen room, not a gradient. Tonal render only, values carried by specular and shadow, palette applied separately. No text, no logotype, no emoji, no UI chrome., a later moment when the product has accumulated meaning

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hyp_EmptyHome`** — 1024x1024

```
Liquid chrome metallic render in a documentary register: heavy polished alloy forms photographed as found objects rather than styled hero product shots, hard studio key from the upper left with a long soft fill, sharp specular ribbons pooling and stretching across the surface like poured mercury coming to rest. Surfaces are machined, not decorative: milling witness marks, chamfered edges, a faint brushed grain under the polish, micro pitting and shallow wear on the working faces. Macro focal length, shallow but honest depth of field, real lens falloff at the frame edge, slight sensor grain, no gloss overlay and no lens flare. Physically based reflections that read as an unseen room, not a gradient. Tonal render only, values carried by specular and shadow, palette applied separately. No text, no logotype, no emoji, no UI chrome., a solid closed bowl, crate or folded cloth waiting to be used — ceramic, wood or fabric, fully opaque, not glass

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hyp_EmptyList`** — 1024x1024

```
Liquid chrome metallic render in a documentary register: heavy polished alloy forms photographed as found objects rather than styled hero product shots, hard studio key from the upper left with a long soft fill, sharp specular ribbons pooling and stretching across the surface like poured mercury coming to rest. Surfaces are machined, not decorative: milling witness marks, chamfered edges, a faint brushed grain under the polish, micro pitting and shallow wear on the working faces. Macro focal length, shallow but honest depth of field, real lens falloff at the frame edge, slight sensor grain, no gloss overlay and no lens flare. Physically based reflections that read as an unseen room, not a gradient. Tonal render only, values carried by specular and shadow, palette applied separately. No text, no logotype, no emoji, no UI chrome., an empty list, shelf or page

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hyp_CardBackdrop`** — 1200x800

```
Full bleed horizontal plate, no transparency. Brushed metal field raked by a single low key light, one long liquid chrome highlight running off frame, milling grain and faint wear visible, deliberately quiet and almost empty so type can sit on it without fighting. No subject, no text, no vignette ring.
```

**`hyp_ControlFace`** — 512x512

```
Liquid chrome metallic render in a documentary register: heavy polished alloy forms photographed as found objects rather than styled hero product shots, hard studio key from the upper left with a long soft fill, sharp specular ribbons pooling and stretching across the surface like poured mercury coming to rest. Surfaces are machined, not decorative: milling witness marks, chamfered edges, a faint brushed grain under the polish, micro pitting and shallow wear on the working faces. Macro focal length, shallow but honest depth of field, real lens falloff at the frame edge, slight sensor grain, no gloss overlay and no lens flare. Physically based reflections that read as an unseen room, not a gradient. Tonal render only, values carried by specular and shadow, palette applied separately. No text, no logotype, no emoji, no UI chrome., the face of a single physical control such as a dial, key or slider handle

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hyp_TwistHero`** — 1024x1024

```
Liquid chrome metallic render in a documentary register: heavy polished alloy forms photographed as found objects rather than styled hero product shots, hard studio key from the upper left with a long soft fill, sharp specular ribbons pooling and stretching across the surface like poured mercury coming to rest. Surfaces are machined, not decorative: milling witness marks, chamfered edges, a faint brushed grain under the polish, micro pitting and shallow wear on the working faces. Macro focal length, shallow but honest depth of field, real lens falloff at the frame edge, slight sensor grain, no gloss overlay and no lens flare. Physically based reflections that read as an unseen room, not a gradient. Tonal render only, values carried by specular and shadow, palette applied separately. No text, no logotype, no emoji, no UI chrome., an emblem representing this app's signature feature

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hyp_SuccessMark`** — 512x512

```
Liquid chrome metallic render in a documentary register: heavy polished alloy forms photographed as found objects rather than styled hero product shots, hard studio key from the upper left with a long soft fill, sharp specular ribbons pooling and stretching across the surface like poured mercury coming to rest. Surfaces are machined, not decorative: milling witness marks, chamfered edges, a faint brushed grain under the polish, micro pitting and shallow wear on the working faces. Macro focal length, shallow but honest depth of field, real lens falloff at the frame edge, slight sensor grain, no gloss overlay and no lens flare. Physically based reflections that read as an unseen room, not a gradient. Tonal render only, values carried by specular and shadow, palette applied separately. No text, no logotype, no emoji, no UI chrome., a confirmation mark or celebratory emblem

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hyp_HeaderDecor`** — 1200x600

```
Liquid chrome metallic render in a documentary register: heavy polished alloy forms photographed as found objects rather than styled hero product shots, hard studio key from the upper left with a long soft fill, sharp specular ribbons pooling and stretching across the surface like poured mercury coming to rest. Surfaces are machined, not decorative: milling witness marks, chamfered edges, a faint brushed grain under the polish, micro pitting and shallow wear on the working faces. Macro focal length, shallow but honest depth of field, real lens falloff at the frame edge, slight sensor grain, no gloss overlay and no lens flare. Physically based reflections that read as an unseen room, not a gradient. Tonal render only, values carried by specular and shadow, palette applied separately. No text, no logotype, no emoji, no UI chrome., a wide decorative band or ornament

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hyp_LockplateEmblem`** — 1024x1024

```
Cutout on fully transparent ground, real PNG alpha, transparent corners, solid opaque subject filling the center. A single machined lockplate slab, three pin seats bored in a vertical run, two seats filled and one open, polished chrome faces with chamfered edges and visible tool marks. One solid object, no plate behind it, no glass, no wireframe, no shadow, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hyp_HatchSeal`** — 1024x1024

```
Cutout on fully transparent ground, real PNG alpha, transparent corners, solid opaque subject in the center. A heavy circular alloy hatch, radial locking dogs retracted, one liquid chrome highlight arcing across the face, deep machined kerf around the rim. Solid metal body, not hollow, not a ring with an empty middle, no frame, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hyp_DelverMark`** — 1024x1024

```
Cutout on fully transparent ground, real PNG alpha, transparent corners, solid opaque subject in the center. A compact cast alloy marker shaped like a descending wedge with a single bored eyelet, polished top face, rough cast underside, one liquid chrome specular running the length of the wedge. One solid object, no base plate, no glass, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hyp_VaultSigil`** — 1024x1024

```
Cutout on fully transparent ground, real PNG alpha, transparent corners, solid opaque subject in the center. A thick vault door boss, five machined bolt heads set around a solid polished center disc, heavy chamfers, liquid chrome highlight pooling on the disc. Solid throughout, no hollow center, no surrounding frame, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hyp_TrapSigil`** — 1024x1024

```
Cutout on fully transparent ground, real PNG alpha, transparent corners, solid opaque subject in the center. A sprung alloy catch, one jaw closed on an empty pin seat, dull worn metal with only a weak broken highlight compared to the other pieces, visible scoring and fatigue on the jaw. One solid object, no ground, no glass, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hyp_JournalEmptyArt`** — 1024x1024

```
Cutout on fully transparent ground, real PNG alpha, transparent corners, solid opaque subject in the center. A blank machined tally slab with three empty bored marks and no stamps struck into it, quiet matte finish with one restrained chrome edge highlight. Solid slab, not hollow, no frame, no paper, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`hyp.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `HypogeumTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. Parse `ProcessInfo.processInfo.arguments` once after onboarding. 
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Hypogeum -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **Tumbler-gate descent (Level holds pins 0..3; Turn aligns one Pin and writes a TumblerMark; three consecutive Pins open the Hatch and descend the Delver; a missed day clears all Pins; three consecutive misses backslide one Level; every fifth Level is a Vault requiring five weekly Turns for double XP; the Shaft is a stack of Levels; depth is the Delver index)** with no leakage across layers.
- [ ] UI approach matches **SwiftUI Metal shaders · material**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Shaft-locked chrome (the shaft map never leaves; Journal, Hero and Settings arrive as sheets) · 4d2e12fd22**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **Verdana** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Hypogeum
xcodegen generate
xcodebuild -scheme Hypogeum -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
xcrun simctl list devices available
xcodebuild -scheme Hypogeum -destination 'platform=iOS Simulator,id=<UDID>' test
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY or DEVELOPMENT_TEAM in project.yml — CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
