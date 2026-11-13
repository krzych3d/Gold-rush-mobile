# Vault Wars 0.2.2 — account progression QA

Date: 2026-11-13. Base: `be39c83d2d7465152b69708ee15cf6bd2b617f21`.

## Behavior

- Device-local account levels 1–20, with Elves at 5 and Voidborn at 10. Dwarves and Goblins start unlocked. Level 5 costs 700 cumulative XP; level 10 costs 2700; level 20 caps at 10450.
- Completed match reward: 50 XP for a win, 25 for a loss/draw, plus 20 per finished wave (maximum 20 rewarded waves). The finishing attack wave counts. At least ten seconds of battle participation are required. Preparation-only losses and abandoned games grant no XP.
- Match-local counters and a random 128-bit match ID feed one final award. Stored recent IDs prevent duplicate claims. Reopening the result does not grant XP again. Level 20 never wraps or resets.
- Home badge shows level/XP and the next unlock. The result shows XP, level-up and unlocked faction names. Locked portraits remain inspectable, but the selected playable faction stays valid and confirmation is disabled. Direct/legacy faction callbacks enforce the same requirement.
- The reference guide can show a locked race without selecting it for gameplay. Language rebuilding preserves the locked preview. Map choices remain independent; unlocked faction stats are unchanged.
- Account data is separate from presentation preferences. Temporary write plus rename avoids a partial primary file; the previous valid save is backed up. Failed saves roll back the in-memory award and its match ID. Invalid primary data falls back to backup; two invalid copies are protected from overwrite and produce a visible account message.
- Attack startup now returns if bot spending has already ended the match, instead of replacing END with ATTACK.

## Checks

Godot **4.2.2.stable.official.15073afe3** imports the new scripts. Nine integration scripts pass without script errors: account progression, animation gallery/combat, epic HUD, original illustrated HUD, cinematic navigation, lobby/codex, rotation/presentation, Polish/English and battlefield choices.

The new account check tests every level boundary through 20, defaults, 700/2700/10450 thresholds, exact win/loss/wave rewards, no XP for empty/short games, duplicate prevention before/after reload, backup recovery, protection of unreadable saves, simulated write-failure rollback, reward caps, actual locked confirmations and legacy callbacks, guide previews, language rebuilding, real simulation participation and exactly one level-five unlock from a finished match. Existing artwork/navigation fixtures explicitly use an isolated level-20 profile when they need all factions; normal gameplay has no test unlock flag.

Both CI workflows gate builds on `Account progression PASSED`. The art inventory is unchanged at 154 files. `git diff --check` passes.

Actual Godot OpenGL renders were reviewed for level-one home in portrait/landscape, locked Elf/Void selection, level-five unlock results in portrait/landscape, reachable landscape result actions, playable Elves at five, and maximum-level home. Review caught a zero-width lock caption; its width and wrapping are now fixed. New account panels retain the existing gold/violet styling.

Physical Android performance and data transfer between installations are not established by these desktop checks. Account progress is stored on the phone, without cloud synchronization; uninstalling or clearing application data removes it.
