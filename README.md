# Hypogeum

Hypogeum is for people who will do one daily chore to go deeper, not for a checkbox that advances itself. The home screen is the shaft. Today's lockplate is the only verb: one tap seats a pin. Three consecutive pins open the hatch and the delver drops one level.

## Architecture

The shaft is a pure fold. `TumblerEngine` rebuilds pins, hatches, vault weeks, and backslides from dated ledger rows, so the rules stay arithmetic over `[TumblerMark]` instead of gesture state. That suits a product whose only decision is whether today continues yesterday. SQLite stores the ledger on device. SwiftUI reads a snapshot and sends a turn. The map never unmounts; Journal, Hero, and Settings arrive as sheets over it.

## Backslide depth

Backslide is the reason to keep the streak. One missed day clears the current pins. Three consecutive missed days ascend the delver one level and relock the hatch above, and the journal keeps a dated row for the loss. XP and tumbler marks stay, so delver level remains 1 plus total XP divided by 100. The column still shows the deepest depth reached beside the depth currently held, and those two numbers may disagree. Returning is worth the tap because the player loses position, not what they earned.

The simulator seed seats eleven days that end yesterday, so the live plate already holds two pins. The first tap opens the first hatch that is still in front of the delver.

## How this differs

Hypogeum shares a daily habit shape with a horizontal waymap, then inverts it. Progress here is a vertical descent. There is no fork to pick. The only loss of ground is backslide, and the weekly vault pays double XP for five marks in the calendar week.

## Design

Black field, one pale accent, Verdana, hairline surfaces, 14pt and 6pt radii, tinted glass on the primary control. The shaft is a masonry column: a tall lockplate, a split backslide record, then shorter cleared depths. Motion is a 180ms crossfade. Numbers use `NumberFormatter` and tabular digits.

## Art

Style: liquid chrome metallic render, documentary. Shared base, then the asset line. Cutouts add a hard transparent ground with a solid subject in the center. No text in the art.

Base: Liquid chrome metallic render in a documentary register: heavy polished alloy forms photographed as found objects rather than styled hero product shots, hard studio key from the upper left with a long soft fill, sharp specular ribbons pooling and stretching across the surface like poured mercury coming to rest. Surfaces are machined, not decorative: milling witness marks, chamfered edges, a faint brushed grain under the polish, micro pitting and shallow wear on the working faces. Macro focal length, shallow but honest depth of field, real lens falloff at the frame edge, slight sensor grain, no gloss overlay and no lens flare. Physically based reflections that read as an unseen room, not a gradient. Tonal render only, values carried by specular and shadow, palette applied separately. No text, no logotype, no emoji, no UI chrome.

| Image set | Prompt |
| --- | --- |
| `hyp_AppIcon` | Full bleed square, no transparency, no text. A single machined lockplate face viewed straight on and slightly off center, three circular pin seats in a vertical run with the lowest seat filled by a seated pin, liquid chrome specular sweeping diagonally across the plate, hairline chamfer catching the key light, deep matte ground behind it. Bold silhouette that survives at 40pt, one subject, no border, no lettering. |
| `hyp_Splash` | Full bleed vertical composition, no transparency. Looking straight down a machined shaft: concentric alloy ring hatches receding into darkness, each ring catching a thinner liquid chrome highlight than the one above it, the lowest ring almost lost in the dark. Documentary macro photography, real falloff, heavy air, nothing centered on a glyph, no text. |
| `hyp_Onboarding1` | Base prompt, a person or object that is this product in one glance. Hard cutout. |
| `hyp_Onboarding2` | Base prompt, the primary action of this product, mid-gesture. Hard cutout. |
| `hyp_Onboarding3` | Base prompt, a later moment when the product has accumulated meaning. Hard cutout. |
| `hyp_EmptyHome` | Base prompt, a solid closed bowl, crate or folded cloth waiting to be used, fully opaque. Hard cutout. |
| `hyp_EmptyList` | Base prompt, an empty list, shelf or page. Hard cutout. |
| `hyp_CardBackdrop` | Full bleed horizontal plate, no transparency. Brushed metal field raked by a single low key light, one long liquid chrome highlight running off frame, milling grain and faint wear visible, deliberately quiet and almost empty so type can sit on it without fighting. No subject, no text, no vignette ring. |
| `hyp_ControlFace` | Base prompt, the face of a single physical control such as a dial, key or slider handle. Hard cutout. |
| `hyp_TwistHero` | Base prompt, an emblem representing backslide depth. Hard cutout. |
| `hyp_SuccessMark` | Base prompt, a confirmation mark. Hard cutout. |
| `hyp_HeaderDecor` | Base prompt, a wide decorative band. Hard cutout. |
| `hyp_LockplateEmblem` | A single machined lockplate slab, three pin seats bored in a vertical run, two seats filled and one open, polished chrome faces with chamfered edges and visible tool marks. One solid object, no plate behind it, no glass, no wireframe, no shadow, no text. Hard cutout. |
| `hyp_HatchSeal` | A heavy circular alloy hatch, radial locking dogs retracted, one liquid chrome highlight arcing across the face, deep machined kerf around the rim. Solid metal body, not hollow, not a ring with an empty middle, no frame, no text. Hard cutout. |
| `hyp_DelverMark` | A compact cast alloy marker shaped like a descending wedge with a single bored eyelet, polished top face, rough cast underside, one liquid chrome specular running the length of the wedge. One solid object, no base plate, no glass, no text. Hard cutout. |
| `hyp_VaultSigil` | A thick vault door boss, five machined bolt heads set around a solid polished center disc, heavy chamfers, liquid chrome highlight pooling on the disc. Solid throughout, no hollow center, no surrounding frame, no text. Hard cutout. |
| `hyp_TrapSigil` | A sprung alloy catch, one jaw closed on an empty pin seat, dull worn metal with only a weak broken highlight, visible scoring and fatigue on the jaw. One solid object, no ground, no glass, no text. Hard cutout. |
| `hyp_JournalEmptyArt` | A blank machined tally slab with three empty bored marks and no stamps struck into it, quiet matte finish with one restrained chrome edge highlight. Solid slab, not hollow, no frame, no paper, no text. Hard cutout. |

## Build

From this directory:

```
xcodegen generate
xcodebuild build-for-testing -scheme Hypogeum -destination 'generic/platform=iOS Simulator' -jobs 2 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Hypogeum -destination 'generic/platform=iOS' -jobs 2 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
```

Portrait only. No accounts, no network. Contact lives in Settings at `https://hypogeum-shaft.pro/contact-us`.
