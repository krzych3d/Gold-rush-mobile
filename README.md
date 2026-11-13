# Gold Rush Mobile — Vault Wars

Mobile-first Godot **4.2.2** fantasy lane strategy prototype with automatic portrait/landscape layouts.

## Battle thumbnails and gold-to-XP presentation (0.2.3)

Battle illustrations now use contained previews with explicit size limits rather
than cover/crop zoom. Character previews retain their upper silhouette; wide
trap pictures exclude their own baked label baseline. Buttons, captions, prices
and tap targets keep their existing behavior. Banner thumbnails stay separate
from their native captions.

The account badge has a level medallion, a beveled gold XP vessel, rune marks
and a brief level-up flare. After an eligible match, a bounded set of golden
motes flies from the reward into the XP bar. Displayed XP advances as motes
arrive and switches ranges correctly at a level boundary. The real award is
saved before this animation starts; flying gold does not spend vault currency
or grant a second reward.

Leaving the result before collection finishes hands the remaining visual to
the main menu. Already displayed XP does not rewind. The flight follows the
current bar after rotation, waits while the target is hidden or clipped, and
respects reduced motion. Idle badges do not run a continuous particle loop.
Effects use one canvas item with at most sixteen motes; battery profiles use
eight.

**Settings → Progress backup** provides a local XP recovery code. It restores
XP and associated race unlocks after reinstalling or on another phone. Older
codes cannot lower progress, invalid checksums are rejected, and failed writes
roll back. The code is a local copy/checksum, not an online account login. The
current test-build workflow generates an ephemeral debug signing key; an
installer may require removal of an older build, so retain a recovery code
before uninstalling. Existing account save files and schema remain unchanged.

`ci/smoke_reward_presentation.gd` covers compact cards across four factions and
phone sizes, timed delivery and level crossing, unchanged saved XP/vault gold,
handoff without replay, rotation, reduced motion, invalid/no-award results and
the settings recovery flow. It is required by both Godot and APK workflows.

## Account levels and faction unlocks (0.2.2)

The local account starts at level 1 and caps at **20**. Dwarves and Goblins are
available immediately, Elves unlock at **5**, and Voidborn at **10**. Locked
factions remain available for portrait/guide previews; both the confirm action
and game callbacks enforce the level requirement. Account level does not change
unit HP, speed, damage, gold capacity or other battle stats. Map selection stays
independent of faction unlocks.

A completed match grants **50 XP for a win** or **25 XP for a loss/draw**, plus
**20 XP per finished wave**, including the final battle wave, up to 20 waves.
Actual battle participation and one played wave are required. Fast completed
matches receive the same outcome and wave bonuses. Abandoning a match or spending the last gold before fighting grants
no XP. A unique match ID prevents repeated result checks from awarding again.

The cumulative level threshold is `100*n + 25*n*(n-1)`, where `n=level-1`:

| Account level | Total XP | Unlock |
|---:|---:|---|
| 1 | 0 | Dwarves and Goblins |
| 5 | 700 | Elves |
| 10 | 2700 | Voidborn |
| 20 | 10450 | Maximum level |

Home shows level, XP progress and the next race unlock. Match results show
earned XP, level-ups and newly available factions. The result can scroll on a
short landscape screen. Labels support Polish and English.

`user://account_progress.cfg` stores XP and recent rewarded match IDs separately
from presentation settings. Saves use a temporary file, atomic rename and the
previous valid backup. An unreadable primary can recover from backup; two invalid
copies are preserved and cannot be silently overwritten with level-one data.
This is a device-local profile, not a cloud login or cross-device account.
Closing and reopening retains progress; uninstalling/clearing app data removes it.

`ci/smoke_account_progress.gd` covers every level boundary, exact unlock levels,
real match rewards, duplicate claims, restart persistence, rollback on failed
save, backup recovery, protected unreadable saves and locked-race navigation.
The Godot and APK workflows both require this check before successful delivery.

## Portrait, landscape and five selectable maps (0.2.1)

Android uses sensor orientation and a 720-pixel logical short axis. Portrait keeps
the fixed complete map above the command menu; landscape hides commands in a
sliding arsenal. Rotating never resets the match. The camera neither crops
the vaults nor follows actors. Units, deaths and deposits share square artwork
and consistent foot anchoring, with 58–86 logical-pixel cells.

The original map is **Standard**. Four distinct optional backgrounds depict
dwarven vaults, goblin strongholds, elven moon gardens and the Void rift. Select
a preview before starting; the choice persists independently of the faction
and does not change lanes, economy or combat. Only the selected map is loaded.

The guide dropdowns, popup menus, navigation and selected index rows share the
painted gold/violet style. In landscape the guide becomes two independently
scrolling pages. [Animation brief 001](docs/animation-briefs/001-dwarf-vault-carrier.md)
specifies a new complete Dwarf Carrier pack; the new character frames are not
yet produced. [Brief index](docs/animation-briefs/index.json) tracks future
faction/action rotation and concept fingerprints.

## Illustrated lobby and game reference

**ROZPOCZNIJ GRĘ → choose one of four races and one of five maps → confirm → preparation.**
The Polish lobby has illustrated race portraits, an animated character showcase,
role previews, a rules screen and a searchable **Księga gry**. Its 21 entries cover
four races, the free wave, three hired raiders, guards, three defenses, bank
levels 0–5, raid training, all four abilities and core rules. Each entry has art,
a live preview, costs, stats, usage advice and limits. Unit stats are calculated
by the same function used to spawn actual battle units. Browsing the guide does
not spend gold, change the selected match race or advance a battle.

**Presentation settings:** Automatic, Battery (30 FPS cap), Balanced and High
(60 FPS caps). Battlefield repaint budgets are independently limited to 12/20/30
FPS; preview budgets use the same limits. Rules still run at the existing 20 Hz.
Automatic starts conservatively on CPUs with at most four logical cores and
reduces effects after three consecutive four-second samples below 25 FPS.
Settings are saved locally. Reduced motion pauses previews until explicitly
played and removes result-screen particles and motion effects. Music and the
battle FPS counter can also be toggled. Hidden lobby previews do not animate.

Android exports include **ARMv7 and ARM64**, using the existing GL Compatibility
renderer. This expands binary support; it is not a claim that every Android
phone has suitable graphics hardware or will achieve the frame cap.

The existing sprite artwork is reused, with genuine atlas frame playback.
Trap previews are explanatory diagrams. The lobby does not add new hand-drawn
animation anatomy or turn the prototype into a completed AAA game.

Validate with Godot 4.2.2:
`godot --headless --path . --script res://ci/smoke_lobby_codex.gd`
The normal Godot pipeline and APK export both run this integration check.

## Playable today
- Choose one of four factions: Dwarves, Goblins, Elves or Voidborn.
- Compete against the bot in three lanes. Deploy raiders, carriers and saboteurs; protect your vault with guards and traps.
- Steal and carry gold back to your vault; spend carefully because gold is also your remaining life.
- Units have health, damage reactions, melee attack and defeat visuals.
- The full battlefield fits on the screen by default without a moving camera.
- Seven character types use the real sprite atlases in `assets/epic/animations/`.

## NEW: Animation Studio
From the main menu, tap **Animacje** to open the existing developer animation viewer.

The studio lets you inspect each of the seven existing characters:
- Dwarf Defender, Dwarf Carrier, Elf Ranger, Arcane Mage,
  Goblin Raider, Goblin Saboteur and Shadow Wolf.
- Idle, Walk, Attack, Hit, Death, Deposit and Carry states.
- Frame counter and left/right direction controls.
- Optional 192 px Goblin Raider action strips take priority when installed.

Battle combat strikes now trigger actual atlas attack poses. Guard damage and death
use their appropriate animations, and characters have different lightweight
weapon/spell feedback plus gold carrying and deposit effects.

**Art quality note:** The studio tests the committed frame artwork; it does not
create new body poses. A convincing animated character needs consistent distinct
drawn frames, not merely moving or rotating a static image. Use the studio to
identify which rows still need better PNG artwork.

## Run locally
1. Install Godot 4.2.2.
2. Import `project.godot` in Godot.
3. Press F5. Preview the animated characters if desired.
4. Choose a race and lane, buy troops/traps, then press **START ATTACK**.

## Animation assets and workflow
- Shipping atlases: `assets/epic/animations/*_sheet.png` (1024 × 768, 8 columns × 6 actions).
- Optional clean Goblin Raider strips: see [Goblin animation pack](docs/Goblin-Raider-Animation-Pack.md).
- The sprite importer and GitHub workflow permit review of externally prepared PNG assets.
- **Paid Leonardo API generation is disabled.** Existing assets can be used offline.
- Image generation is **not** required to play the current build.

## CI and Android APK
- [Godot validation](.github/workflows/godot-ci.yml) runs the engine import, startup,
  seven-atlas animation studio, and melee-animation regression checks.
- [Android debug APK](.github/workflows/android-debug.yml) runs on commits to
  `main` affecting game code/assets, or on manual dispatch.
- Open the latest successful **Android debug APK** workflow, then download
  the `gold-rush-debug-apk` artifact. Debug signing is not production signing.

## Cinematic animation pack (10 generated sheets / 480 frames)

New generated high-detail RGBA animation sheets are distributed as a reviewed ZIP
(`vault-wars-epic-animations.zip`, about 11.6 MB), not as static mockups. All
ten 8×6 sheets use 1024×768 PNGs (128px cells).

**Automatic GitHub import:**
1. Download the ZIP from the ChatGPT conversation.
2. Open [the sprite import issue](https://github.com/krzych3d/Gold-rush-mobile/issues/2).
3. Drag the unmodified ZIP into a **new issue comment** and submit.
4. The restricted [Import 10 epic animation sheets](.github/workflows/import-epic-animations.yml)
   workflow will validate the ZIP (all ten files, hashes, alpha and 48 frames),
   replace the seven original base sheets, commit three additional special sheets,
   and trigger Godot/Android CI on main.

The workflow can also be run manually with a GitHub user-attachment HTTPS URL.
Only the repository owner can trigger the automatic issue-comment import.
Do **not** rename files in the ZIP or alter the SHA-256 manifest.

The seven base atlases cover idle/walk/attack/hit/death/loot.
Three supplemental atlases add six animations per character:
- Goblin Raider: sprint, leap, dual-dagger combo, dodge, taunt, stealth.
- Shadow Wolf: sprint, pounce, frenzy, shadow dash, howl, spawn.
- Arcane Mage: run, teleport, shield, beam, rune, victory.

The in-game Animation Studio automatically adds these states when the assets
are installed. During battles, premium sprint/combo/beam frames take priority
for the corresponding characters. This is **actual frame-by-frame artwork**,
not stretching a static sprite. Further frame-level anatomy and foot-contact
QA should be done on an Android phone after import.

## Voidborn animation coverage and directional fixes

The animation library includes **11 playable sprite roles** across four factions
(seven source characters + four Voidborn variants). Every runner, carrier,
saboteur and defender uses a frame-by-frame atlas for idle, walk, attack,
hit, death and gold activity; the body faces the actual travel direction
including the trip back to the home vault.

**Voidborn:** Sentinel (defender), Stalker (raider), Collector (carrier),
Weaver (saboteur). The Voidborn variants are spectral visual remasters of
existing animated anatomy, not false claims of brand-new hand-drawn rigs.
Their new PNGs are optional until imported; temporary fallback atlases
keep previous builds working.

**More special moves:** Dwarf Defender, Dwarf Carrier, Elf Ranger and
Goblin Saboteur now have six optional bonus sequences each, completing
special-action coverage for all seven original source characters.

**Import the extra eight animation atlases:**
1. Download `vault-wars-voidborn-all-characters.zip` from the ChatGPT conversation.
2. Open [Voidborn animation import issue #4](https://github.com/krzych3d/Gold-rush-mobile/issues/4).
3. Attach the unmodified ZIP to a **new comment** and submit it.
4. [The owner-only import workflow](.github/workflows/import-voidborn-complete.yml)
   verifies eight files and all 384 frames, commits them to `main` and **explicitly
   starts both the Godot test and Android APK workflows**, even though bot-authored
   commits alone do not trigger GitHub push workflows.

The import uses no paid generation API. To inspect your characters, use
the Animation Studio **VOIDBORN** selector and previous/next character buttons.

## Next visual milestones
1. Replace flat/duplicate frames in any sprite atlas with distinct, aligned poses.
2. Finish a consistent Goblin Raider action set (Idle, Walk, Run, Attack,
   Hit, Carry, Deposit, Death), then repeat for each playable character.
3. Compare characters in the Animation Studio at mobile resolution and during
   actual 20+ unit battles; monitor FPS and atlas readability.
4. Improve combat timing, sound and polish while preserving full-screen map mode.

## Known limits
- Experimental balancing and AI, simplified pathfinding and trap targeting.
- Sprite-motion quality depends on the existing artwork; animation studio can
  reveal any pose repetition, anatomy inconsistency or flicker.
- No multiplayer or production-ready signed Android release.

### Full-screen battle and epic menus

See [Epic mobile presentation](docs/Epic-Mobile-Presentation.md) for the persistent gold HUD, sliding arsenal, close/overview camera controls, new faction artwork and validation coverage.

### Polish and English

Use **PL / EN** on the home screen or **Settings → Language**. The choice is
saved on the phone and applied immediately to menus, the 21-entry guide,
ability names, animated previews, shop cards, battle messages and results.
The initial language follows the phone (Polish for `pl`, English otherwise).
Changing language preserves the selected faction, purchases and match state.

All screens share gold beveled frames, original painted button surfaces and
Cinzel Bold headings with Polish glyphs. Paragraph text stays in the readable
body font. Faction art is cropped in the UI to remove embedded English text;
labels and prices are rendered by Godot in the chosen language. Viewport-aware
portrait cropping keeps the characters' faces visible.

Validation includes all existing smoke checks and `ci/smoke_localization.gd`,
covering both languages, saved preferences, 21 guide entries for all four
factions, localized search, native card captions and four phone sizes.
The Android build runs these checks before publishing version **0.2.0**.
