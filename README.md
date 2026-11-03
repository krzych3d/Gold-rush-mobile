# Gold Rush Mobile — Vault Wars

Mobile-first Godot **4.2.2** fantasy lane strategy prototype (portrait).

## Playable today
- Choose one of four factions: Dwarves, Goblins, Elves or Voidborn.
- Compete against the bot in three lanes. Deploy raiders, carriers and saboteurs; protect your vault with guards and traps.
- Steal and carry gold back to your vault; spend carefully because gold is also your remaining life.
- Units have health, damage reactions, melee attack and defeat visuals.
- The full battlefield fits on the screen by default without a moving camera.
- Seven character types use the real sprite atlases in `assets/epic/animations/`.

## NEW: Animation Studio
Before choosing your race, tap **VIEW 7 ANIMATED HEROES**.

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
