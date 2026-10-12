<!-- gf-brief source=5c7b1b858186f197898e125b531965bf6acd80c10dfc8a9cdc5b3d091b833746 written=2026-10-12T19:14:23+03:00 -->
# Hypogeum
## What it is
Hypogeum is a once-a-day check-in for people who will do one action a day to go deeper, not a list that advances itself. Each day you align one pin on today's plate. Three pins in a row open the door and you drop one level; a missed day clears the plate, and three missed days in a row lift you one level and lock the door above. A weekly prize waits on every fifth level.

## Launch and onboarding
A cold launch shows a system launch screen with no words, then a dark field. A spinner can appear while the shaft is being read.

On a first install on a device the spinner is followed by three onboarding panes. **Skip** stays in the top trailing corner on every pane. A counter under the copy reads **Pane 1 of 3**, **Pane 2 of 3**, or **Pane 3 of 3**. Each pane has an illustration with no caption.

1. **The plate is the job.** Body: **You sit on today's plate. A level only moves when a pin seats.** The primary button is **Next**.
2. **Align today's pin.** Body: **Three pins in a row open the door. A missed day clears the plate.** The primary button is **Next**.
3. **Three misses lift you.** Body: **You move up one level and the door above locks again. A weekly prize still waits on every fifth level.** The primary button is **Descend**.

**Skip** and **Descend** both finish the descent and open the shaft. Both write the same defaults: **Daily reminder** at 9:00 and **Haptics** on. They do not show the notifications prompt.

A later cold launch may show the spinner, and can flash the first onboarding pane for a moment, then the shaft. Wait; the shaft appears once the save is read. You do not need to tap **Skip** again.

If the shaft cannot open, the home screen shows **The shaft did not load.** with a following line of **The shaft file could not open. Retry keeps the same folder.** or **The shaft could not be read. Retry loads the same file.** **Retry** tries again.

On Simulator a first launch can skip onboarding and open a already-filled shaft (see Starter content). If that fill fails, the home screen can show **The demo shaft stopped before today's plate. Retry seeds the same file.** or **The demo shaft did not seed. Retry opens the same file.** **Retry** tries again.

## Screens
There is no tab bar. The shaft stays on screen. A closed-book control, a person control, and a gear control sit in the top trailing corner. VoiceOver names them **Journal**, **Hero**, and **Settings**. Sheets close with an **X** named **Close**, and can also be dismissed by a downward swipe.

### The shaft
No navigation title. The field is dark.

A left rail lists **NOW**, **POINTS**, **RANK**, and **RUN** with numbers. **NOW** is the level you hold. **POINTS** is the running total. **RANK** starts at 1 and rises by 1 for every 100 points. **RUN** is the current streak of seated days (if today is not seated yet, it still counts a run that ended yesterday).

The column is headed **DEPTHS**.

Shallower levels you have already left appear as **Level 0**, **Level 1**, and so on, each with **Cleared.** or **Locked again.** The opening plate is **Level 0**. A short tick beside a left-behind row is named **Cleared depth** by VoiceOver; the tick beside today's plate is named **You are here**. Tapping a cleared row expands or collapses a detail that shows **Pins** and a count, then **Ordinary level.** or **Weekly prize open.** or **Weekly prize locked.**, then any dated marks for that level (eight-digit dates). Tapping again closes the detail.

Today's plate is the live control. It is labeled **TODAY**, title **Align today's pin.** When a seat is free it says **Tap the open pin. It seats on this plate.** and the next empty seat is labeled **Align**. Three seats sit in a row. VoiceOver names a filled seat **Pin seated**, the open seat **Open pin, align**, and a later empty seat **Pin open**. The whole plate is named **Align today's pin** and the hint is **Seats one pin on today's plate.** Tapping the plate seats today's pin. It does not open the level detail. After that tap a banner can read **Today's pin is seated.** When the third pin of a run seats, the banner reads **The door is open. You dropped one level.** and the rail and column move to the next level. If the write fails the banner reads **The turn did not write. Try the plate again.** If the plate has no free seat the banner reads **This plate has no open seat.** That banner stays on the shaft until a later event replaces it; it has no dismiss control.

When today's pin is already seated the plate is dimmed and refuses taps. The line changes to **Today's pin is already seated.** The same sentence can appear on the banner.

Deeper levels you have not reached yet are cards:

- **NEXT** — **The next door stays locked until this plate seats three pins.** VoiceOver: **Next level**.
- **WEEK** — **Five pins this week open the weekly prize.** plus **N of 5 pins this week.** and five week-pin slots. VoiceOver names a filled slot **Week pin seated** and an empty slot **Week pin open**, and the card **Weekly prize at the next level**. Every fifth level is a weekly prize (**Level 4**, **Level 9**, **Level 14**, and so on). The week meter sits on this upcoming card, not on **TODAY**. When you are already on a weekly-prize level, **TODAY** still reads like any other day.
- **PASSED** — **This depth is already cut. It sits below the held place.** VoiceOver: **Passed depth** plus the level number. This appears after a backslide, when a deeper level you already cut sits below the held place.

Tapping **NEXT**, **WEEK**, or **PASSED** expands the same level detail as a cleared row.

At the bottom of the column a **BACKSLIDE** card always reads **Three missed days in a row lift you one level and lock the door above.** and **Open the record.** Tapping it opens **Backslide**. VoiceOver names the card **Backslide depth** with the hint **Opens the backslide record.**

If the shaft has no levels, the screen shows **The shaft is empty.** / **Align today's pin to cut the first level.** / **Retry**.

Coming back to the app while it is already installed refreshes the shaft. A missed day can clear today's pins, or apply a backslide, without a tap.

### Journal
Opened from the book control. Title **Journal**. **Close** dismisses it.

Before any mark: **The path is closed.** / **Finish three days to open the next node.** **Align today's pin** closes the sheet and returns to the shaft. One seated pin is enough to leave this empty state; you do not have to finish three days first.

When the list has rows, a **FARTHEST** block shows **Farthest** and the deepest level reached, with a short depth spark of recent seated pins. Below that, each row shows an eight-digit date (year, month, day with no separators — 12 October 2026 reads **20261012**), then one of:

- **Pin seated, 10 points.** (or **20** when that pin also opened a weekly prize)
- **The weekly prize stayed locked.**
- **Backslide. You moved up one level.**

and **Level** plus the level number. Newer dates sit above older ones. The list grows as you seat pins, miss a weekly prize, or backslide. There is no edit, delete, or share on a row.

If the journal cannot load: **The journal did not load.** plus the same shaft-read error line. **Retry** reloads. While it is still reading, a spinner with no words.

### Standing
Opened from the person control (**Hero**). Title **Standing**. **Close** dismisses it.

Before any seated pin: **No pins yet.** / **Align today's pin on the shaft to start the record.** **Close** returns to the shaft.

With at least one seated pin: **HELD** and the held level, then **You hold N. The farthest reach is M.** Then rows **Pins**, **Streak**, and **Longest streak** with counts. **Held** can be shallower than the farthest reach after a backslide. **Rank** and **POINTS** on the shaft rail are not repeated here.

If the record cannot load: **The hero record did not load.** plus the shaft-read error line. **Retry** reloads. While it is still reading, a spinner with no words.

### Settings
Opened from the gear control. Title **Settings**. **Close** dismisses it. The sheet can sit at a medium or full height.

When ready:

- **Daily reminder** — hour and minute in the device time format. Changing it saves the time and asks for notifications (see Permissions). Opening this screen also applies the saved time, which can present that same system prompt.
- **Haptics** — on or off. When on, a tap that seats a pin plays a short haptic.
- **Contact** — opens the support page.
- **Show the descent again** — closes Settings and returns to the three onboarding panes. **Skip** or **Descend** writes **Daily reminder** back to 9:00 and turns **Haptics** on. The shaft is still there after **Skip** or **Descend**. **Skip** also clears the confirmation banner; **Descend** leaves it.
- **Reset shaft** — opens a confirmation titled **Reset the Hypogeum shaft?** Message: **This deletes every saved mark. Level, points, and place return to the opening plate.** Buttons: **Reset shaft** and **Cancel**. Confirming closes Settings, returns you to the opening plate, and shows **The shaft is empty. Every saved mark is gone.** The next cold launch shows onboarding again.

There is no control that turns **Daily reminder** off. If notifications stay off, the time still saves but no banner fires.

If Settings cannot read the shaft: **Settings could not read the shaft.** plus the error line. **Retry** retries. While still loading: **Settings are still loading.** / **The reminder time appears when the shaft file answers.** **Retry** retries. A failed reset can replace the shaft with **Reset did not finish. Retry from Settings.**

### Backslide
Opened from the **BACKSLIDE** card. Title **Backslide**. **Close** dismisses it.

Before any backslide: **No backslide yet.** / **Three missed days in a row lift you one level and lock the door above.** **Close** returns to the shaft.

After one or more backslides: heading **Backslide**, then **A missed day clears the pins. Three missed days in a row move you up one level and lock the door above. Points stay.** Each event shows the eight-digit date and **Held level N. Farthest remains M.** **M** is the farthest reach now, repeated on every row.

## Features
- Align today's pin — one pin per calendar day on the plate you hold.
- Three pin seats on today's plate; the open seat reads **Align**.
- Three pins in a row open the door and you drop one level (**The door is open. You dropped one level.**).
- A missed day clears the pins on the plate you hold.
- Backslide — three missed days in a row lift you one level and lock the door above; points stay. A longer gap lifts one level per three missed days.
- Weekly prize on every fifth level (**Level 4**, **Level 9**, **Level 14**, …); five pins in the device's calendar week open it. The pin that opens it is worth 20 points; a usual pin is worth 10. You can still drop through a weekly-prize level with three pins even if the prize stays locked. A week that ends without five pins can add **The weekly prize stayed locked.** to the journal.
- **NOW**, **POINTS**, **RANK**, and **RUN** on the shaft rail.
- **Journal** of dated pins, locked weekly prizes, and backslides, with **Farthest**.
- **Standing** — held level, farthest reach, **Pins**, **Streak**, **Longest streak**.
- **Daily reminder** at a chosen time. The notification title is **Align today's pin** and the body is **Today's plate is waiting.**
- **Haptics** on a seated pin.
- **Contact**.
- **Show the descent again**.
- **Reset shaft**.

## Behaviours that can look like bugs
- Today's plate stays dim and ignores taps after one pin that day. The copy **Today's pin is already seated.** is the stop. Wait until the next calendar day.
- A missed day wipes the pins on the plate you hold, even if one or two were already seated. Seat again on a new day. The journal of past days stays.
- Three missed days in a row move you to a shallower level. Six missed days move you two levels, and so on. **NOW** and **HELD** can fall while **Farthest** does not. That is the backslide, not a reset. **Rank** still follows points, so it can disagree with **NOW**.
- After a backslide a deeper level can sit under **PASSED** and read **Locked again.** You cut it once already; it is below the held place until you drop to it again.
- **The path is closed.** / **Finish three days to open the next node.** appears in **Journal** before the first mark. Seat one pin on the shaft, then open **Journal** again. The button **Align today's pin** only closes the sheet.
- **No pins yet.** in **Standing** until the first seated pin. **Close** and seat a pin on the shaft.
- **No backslide yet.** until three missed days in a row have happened. **Close** returns to the shaft.
- **Align** is also ignored while a pin is still being written.
- Tapping **TODAY** seats a pin; it does not expand **Pins** / **Ordinary level.** the way a **Level**, **NEXT**, **WEEK**, or **PASSED** row does.
- When you hold a weekly-prize level, **TODAY** has no **WEEK** label and no week-pin slots. The meter lives on the next weekly-prize card only.
- The confirmation banner after a pin has no close control. It stays until a later pin, a reset, or **Skip** on onboarding replaces or clears it.
- Journal and backslide dates look like **20261012**, not a spelled-out date. That is the on-screen date.
- Every backslide row can show the same **Farthest remains** number. That number is the farthest reach now.
- The first plate is **Level 0**.
- **Show the descent again** is meant to return you to the three panes. **Skip** or **Descend** brings you back to the same shaft and sets **Daily reminder** to 9:00 and **Haptics** on.
- **Reset shaft** is meant to wipe the shaft. Confirming returns you to the opening plate. The next cold launch shows onboarding again.
- Opening **Settings** or changing **Daily reminder** can present the system notifications prompt. If notifications stay off, the reminder time still saves but no banner fires. There is no in-app off switch and no "denied" screen.
- A returning launch can flash onboarding or a spinner before the shaft. Wait; do not treat that as a new install unless you chose **Reset shaft**.
- **The shaft is empty.** with **Retry** is an error or empty load, not the normal first plate. **Retry** reloads. After a successful reset you should see today's plate again, plus the banner **The shaft is empty. Every saved mark is gone.**

## Starter content and resume
On a device, none. A new install starts on the opening plate with no pins seated, **NOW** 0, **POINTS** 0, **RANK** 1, and **RUN** 0.

On Simulator the shaft is already filled: eleven seated days ending yesterday, three cleared depths, two pins already on today's plate, and onboarding already finished. The next tap can open the door.

Unfinished work resumes. Pins already seated on today's plate, the journal, points, rank, held and farthest levels, reminder time, and haptics come back on the next launch. Pins on the current plate do not survive a missed day. After **Reset shaft**, the next cold launch starts from onboarding and an empty opening plate.

## Permissions
Notifications. Asked when **Settings** applies or the person changes **Daily reminder**. There is no custom usage-description string. The system prompt is the ask. If allowed, a repeating local reminder uses the title **Align today's pin** and the body **Today's plate is waiting.**

The app does not ask for camera, photos, microphone, or location. A camera usage string exists in the build — **This app does not use the camera.** — and is never shown, because the camera is never requested.

## Absent
Login or accounts: absent.  
In-app purchase: absent.  
Ads: absent.  
Analytics: absent.  
User-generated content (nothing is posted or shared): absent.  
Account deletion flow: absent.  
App Tracking Transparency prompt: absent.

## Data and support
Marks, levels, points, reminder time, and haptics stay on this device. **Contact** in **Settings** is the support control; it opens the support page.

## Scanning and health
None. The app does not scan barcodes or QR codes. It does not show health, medical, or product-health information.

## Platform
English only (no other localizations). "Today," missed days, and the weekly prize follow the device calendar, including the device's first weekday. Whole numbers on the rail and in **Standing** use the device's decimal grouping; journal dates do not.

Portrait only, on iPhone and iPad. Full screen; dark appearance only. Minimum iOS 17.0.

## Category
Lifestyle
