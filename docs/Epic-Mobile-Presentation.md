# Epic mobile presentation

The home screen uses full-screen original artwork and three actions: play, game guide and settings. Play opens a four-race selection with new high-resolution portraits. Every navigation button shares the same painted gold, sapphire and amethyst artwork, while labels remain native and readable. Settings, tutorial chapters, the guide, animation gallery and result screens share the same fantasy panels.

## Battle controls (0.2.1)

- Android orientation is `SCREEN_SENSOR`. A square 720×720 minimum with `canvas_items` / `expand` keeps a stable logical short axis in both orientations.
- Portrait places the complete fixed map above the scrolling command panel. Landscape uses the full battle layout with a sliding arsenal and permanent actions. Rotation changes layout without rebuilding the match.
- The camera fits both vaults using the minimum width/height ratio. Automatic tracking, swiping to pan and fill/crop zoom are removed. A swipe cannot also select a lane.
- Gold stays in the top HUD. Landscape attack closes the arsenal; portrait keeps the command area available. Interrupted drawer tweens are cancelled on rotation.
- Live units, death and deposit actors share square cells, one foot baseline and a 58–86 logical-pixel size range. Their health bars, payload indicator and effects scale with them.
- Android interactive controls use the unobscured display area; device cutout and sensor behavior still require phone testing.

## Maps and guide

The original battlefield remains Standard for new players. The selection screen adds previews for dwarves, goblins, elves and Void, usable with every faction. The chosen map is saved in the existing presentation preferences. Only the selected map is loaded; all use the same world bounds and three straight lanes. Source prompts, checksums and provenance are in `art_sources/faction-battlefields.json`; no generation API is called by the game or build.

Guide filters, preview selectors, popup menus and navigation use the same gold/violet artwork as Play. The index and description form two columns in landscape and stack in portrait. Race and map selection also use two columns in landscape. Native labels, independent scrolling, search and four-faction reference data are retained.

## Verification

Godot 4.2.2 import, animation, original HUD, gameplay HUD, cinematic, lobby, localization, battle-presentation and battlefield-choice checks. Rotation checks cover seven sizes, a match in progress, an interrupted drawer animation, lane touch coordinates and unchanged gold/phase/faction. Map QA covers four factions × five maps, original default, preview, persisted choice and invalid preference fallback. The new animation brief is a specification, not a completed character asset.

The test fixture stops the simulation timer only while comparing exact unit dictionaries across a resize; normal gameplay retains its 20 Hz clock. Rendered screen review and physical Android testing are separate from headless checks.

Godot reference: [display orientation and safe areas](https://docs.godotengine.org/en/4.2/classes/class_displayserver.html), [multiple resolutions](https://docs.godotengine.org/en/4.2/tutorials/rendering/multiple_resolutions.html).

## Shared bilingual interface (0.2.0)

- Home language controls and a settings selector provide Polish and English offline.
- Locale is stored in `presentation.cfg`; unrecognized values fall back to English.
- The shared catalog holds 333 paired translations; formatting templates are
  translated before their numeric arguments are inserted. Internal phase and
  item IDs are independent of display text.
- Original generated faction art now has native localized captions and live
  prices. Display regions exclude labels baked into the source PNGs in the
  shop and reference guide. Original art files remain available for provenance.
- Cinzel Bold is distributed with its SIL Open Font License. Panels, buttons,
  faction plates, settings, the guide, gallery, confirmation and results share
  the gold trim. Gold remains in the persistent HUD above the sliding arsenal.
- QA: `smoke_localization.gd` tests round trips in both switches, persistence,
  selected faction, all guide fields and search, unchanged gold/orders/lane,
  internal attack IDs, the result screen and 540×960 through 1080×1920 layouts.
