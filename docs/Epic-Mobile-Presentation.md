# Epic mobile presentation

The home screen uses full-screen original artwork and three actions: play, game guide and settings. Play opens a four-race selection with new high-resolution portraits. Every navigation button shares the same painted gold, sapphire and amethyst artwork, while labels remain native and readable. Settings, tutorial chapters, the guide, animation gallery and result screens share the same fantasy panels.

## Battle controls

- The top HUD always shows your gold and enemy gold. Purchases update it immediately.
- **CAŁA MAPA / ZBLIŻENIE** switches between both-vault overview and a full-screen close view. Camera and drawer transitions respect reduced-motion settings.
- **BAZA / AKCJA / WRÓG** moves to your vault, follows your selected lane's troops, or moves to the opposing vault. Swiping the close view pans horizontally; swiping does not also select a lane.
- **ARSENAŁ / SCHOWAJ** slides the shop above the arena. Purchases, lane selection, defenses and upgrades keep their existing rules. The drawer scrolls on shorter screens.
- **ROZPOCZNIJ ATAK** stays in the bottom dock. Starting an attack closes the arsenal; the next preparation phase opens it again. Android Back closes an open arsenal first.
- Larger unit silhouettes, team-colored ground rings and proportional health bars remain visible in both camera views. These changes reuse the existing animation atlases.

## Verification

Godot 4.2.2 import and the animation, original HUD, gameplay HUD, cinematic, lobby and battle-presentation integration checks. The latter covers 540×960, 720×1280, 720×1560 and 1080×1920, currency changes, camera panning, both views, drawer interruption and the attack transition. Actual screens were rendered with Godot's OpenGL compatibility renderer for visual review. Phone performance still depends on the device; adaptive presentation profiles remain available.

Source checksums are recorded in `art_sources/cinematic-lobby.json`; `ci/asset_manifest.py --check` verifies the shipping art. No external image-generation API is called by the game or build.

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
