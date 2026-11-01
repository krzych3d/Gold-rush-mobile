# Gold Rush Mobile — Vault Wars

Experimental Godot 4.2 mobile-first strategy prototype (portrait mode).

## Gameplay
- 1v1 against a basic bot, 3 lanes, 5 waves.
- 30-second preparation and 60-second attack phases.
- Free thieves each wave; buy extra runners, carriers and saboteurs.
- Buy spikes, snares and turrets.
- One treasury: spending gold reduces your remaining life.
- Thieves steal from enemy vault and must return to deposit loot.
- 8% interest (capped at 100) after waves 1–4; most gold after wave 5 wins.

## Run locally
1. Install Godot 4.2.2.
2. Import `project.godot` in Godot.
3. Run the project (F5). Choose lane, buy units/traps, press START ATTACK.
4. This is a mechanical prototype with placeholder shapes and English UI, not finished pixel art.

## CI
`.github/workflows/godot-ci.yml` validates project import and launches a short headless smoke test. It triggers on code changes and manually, not on a schedule. Check the Actions tab for actual run results.

## Android
An APK is **not yet built**. Godot Android export templates, Android SDK, export preset, and signing configuration are required. Never commit release signing keys to this repository. Debug APK generation is a future CI milestone.

## Known limitations
- Simplified trap targeting and movement, no physical pathfinding or multiplayer.
- Bot is random and needs balance tuning.
- Remaining loot is returned to its original owner at wave timeout.
- Source has not yet been confirmed passing a GitHub Actions run.
