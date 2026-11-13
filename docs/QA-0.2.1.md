# Vault Wars 0.2.1 — verification

Date: 2026-11-13. Base: `bfa9204e1d62637476fe0113b2eb9979f30aedaa`.

## Included

- Android sensor rotation, a stable 720-pixel logical short axis, portrait map above commands and landscape battle with a sliding arsenal.
- A fixed complete map: no action tracking, panning or fill/crop zoom. Both vaults remain in view. Layout changes preserve match data, cancel stale drawer tweens and keep Android Back working in portrait.
- Shared square artwork scale and foot anchoring for live units, death and deposit actors. Health bars, carried-gold markers and attack/deposit feedback follow that scale.
- Painted gold/violet guide filters, dropdown popups, playback/navigation controls and matching selected-row frames. The guide and race/map selection reflow into columns in landscape. Android safe-area conversion is used for battle controls and menu margins.
- Standard remains the default. Four separately generated backgrounds add dwarves, goblins, elves and Void; every faction can use every map. Preview and persisted selection share the actual battlefield texture. All maps retain the same bounds, three lanes, costs and combat rules. Only the chosen map is loaded.
- Brief 001 for `dwarf_carrier`: full key poses, state timings, eight directions, eight PNG sheets, 672 frames, memory budget, integration steps and visual/gameplay/device acceptance tests. Its status is **brief_only**. No new unit animation frames or revised attack-impact simulation are shipped by this change.

## Automated checks

Godot **4.2.2.stable.official.15073afe3** imported the project without script errors. Eight integration checks pass:

| Check | Result |
|---|---|
| `smoke_animation_gallery.gd` | Pass — 11 roles, special sheets, direction and melee pose trigger |
| `smoke_epic_hud.gd` | Pass — actual purchase controls, four-faction art and turret feedback |
| `smoke_original_hud.gd` | Pass — source illustrated controls |
| `smoke_cinematic_ui.gd` | Pass — navigation, five vault tiers and outcomes |
| `smoke_lobby_codex.gd` | Pass — 21 entries, shared stats, search, previews and presentation profiles |
| `smoke_battle_presentation.gd` | Pass — seven sizes, fixed map, HUD, unit scale, lane taps, rotation during a match/drawer tween, Android Back |
| `smoke_localization.gd` | Pass — Polish/English, persistence and unchanged economy |
| `smoke_battlefield_choices.gd` | Pass — four factions × five maps, original default, preview, persistence, invalid-value fallback and responsive book |

`ci/asset_manifest.py --check`: 154 art files verified. All four new PNG Git blob SHAs match the uploaded source bytes. `git diff --check`: pass. The brief's 84 poses per direction × 8 directions = 672-frame arithmetic and index path were checked.

## Rendered review

Actual Godot 4.2.2 OpenGL compatibility rendering on Mesa llvmpipe produced sixteen screens: portrait/landscape home, portrait/landscape guide, race/map selection and its landscape reflow, five landscape battle maps, portrait battle, 540×960 physical output, 1560×720 wide battle and settings. Review caught and corrected an over-stretched list highlight, race portrait focus, map-choice visibility in landscape and selected-index visibility after reflow.

The renders verify layout and artwork composition, not mobile GPU performance. The 540×960 output retains the same logical 720-pixel short-axis layout. New map sources, prompts and checksums are recorded in `art_sources/faction-battlefields.json`.

## Remaining device checks

No physical Android device was available. Confirm both landscape rotations, cutouts, restoration after backgrounding, touch gestures during rotation and 30-actor frame times on the target handset. The new character pack still requires production and per-frame visual review before integration. Desktop frame caps and a successful APK export do not establish animation completeness or device FPS.
