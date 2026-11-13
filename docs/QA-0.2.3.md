# Vault Wars 0.2.3 — reward presentation QA

Date: 2026-11-14. Base: `5fecd818669bdf7004ca21f8f926087cdcb98383`.

## Included

- Battle pictures use `STRETCH_KEEP_ASPECT_CENTERED` with bounded 190×126 logical-pixel preview boxes. The picture is shown in full within the intentional source crop that removes baked English labels. Portrait and wide trap crops use separate label baselines. Banner pictures are bounded and their captions/prices retain independent space. Buttons, costs and purchases are unchanged.
- Account badge adds a gold/violet level medallion and a 24-pixel carved gold progress vessel with rune marks, a short moving highlight during collection and a level flare. Three small code-native SVG assets extend the existing fantasy style; no runtime generation or external API is added.
- Golden motes travel into the bar over 1.9 seconds after the entry delay. Counting begins with arrivals. Displayed cumulative XP is converted into the correct per-level range, including crossing a threshold and revealing the associated race notice. Saved XP and battle gold are never changed by the visual effect.
- A profile reward now includes the before/after totals needed for presentation. The save schema remains version 1. The award is still committed once before the result appears.
- The unfinished part of a result animation can transfer to the main menu during scene replacement. The transfer starts at already displayed XP. Completed effects do not repeat. A language rebuild preserves the remaining visual instead of rewinding it.
- Flights use one drawing item and at most sixteen motes; the app uses twelve normally and eight in battery mode. They follow the current bar position during rotation and wait for a visible, unclipped target. Reduced motion immediately shows final values. The idle badge does not continuously animate particles.
- Settings can export/copy and restore a local XP backup code. Import is monotonic, checksum-validated, capped at level 20, saved through the existing atomic path and rolled back on failure. Recent awarded-match IDs remain intact. Backup codes reconstruct account XP and race unlocks, without cloud authentication.

## Validation

Godot **4.2.2.stable.official.15073afe3** imports the project. Ten integration suites pass without script errors: reward presentation, account progression, animation/combat, epic HUD, original HUD, cinematic navigation, lobby/codex, battle rotation, Polish/English and map selection.

The new presentation check exercises four factions at 540×960, 720×1440, 720×1560 and 1280×720; source containment, bounds and caption separation; a real saved 680→750 XP reward; counting across level five; delayed race visibility; no writes to saved XP or vault gold during animation; handoff from an unfinished result and rotation in the menu; completion without another claim; reduced motion; failed/duplicate/ineligible results; checksum rejection; no downgrade from an older backup; and persisted restoration through the actual Settings button.

Actual Godot OpenGL renders were reviewed for the level-two home badge, compact Goblin battle menu in portrait/landscape, reward before arrivals, visible golden motes while crossing level five, and final XP. Art inventory: 157 verified files. `git diff --check` passes.

## Install and device limits

The pre-existing Android test workflow generates a new debug signing key per run. Older keys cannot be recovered from a signed APK. A reinstall can remove local app data, so the recovery-code interface is included with this release. Existing stored progress is not reset or migrated automatically. Physical Android installation, clipboard behavior and frame times still require handset verification.
