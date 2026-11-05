# Three-faction illustrated battle HUD — issue #11

This is **not** the original 27-asset `vault-wars-original-illustrated-hud.zip`
package used by issue #9. That older package has already shipped on `main`.

The additional illustrated UI uses exactly **30** root-level RGBA PNG files:
for each of the `dwarf`, `goblin`, and `elf` prefixes, 10 assets
`runner`, `carrier`, `saboteur`, `spikes`, `snare`,
`turret`, `defender`, `ability`, `bank`, `raid`.

**Correct ZIP name:** `vault-wars-three-faction-illustrated-ui.zip`

**SHA-256 of the reviewed ZIP:**
`29af191b7d6c4c0382a55a2787e38f028f77c5d9acbcaf7d60002a0d8dcfa9d7`

The ZIP also includes a single `manifest.json` at its root, with
`version=2`, `format=rgba_png`, `races=[dwarf, goblin, elf]`, and
a SHA-256 checksum and image dimensions for every PNG.

## Installation

1. Download the corrected ZIP from the ChatGPT reply.
2. Open [issue #11](https://github.com/krzych3d/Gold-rush-mobile/issues/11).
3. Attach **that ZIP** to a new comment. The old ZIP should not be reused.
4. [The owner-only import workflow](../.github/workflows/import-faction-menus.yml)
   checks the filename list, checksums, sizes and transparency.
5. If valid, the workflow commits all 30 assets to
   `assets/ui/direct/` and dispatches Godot validation and Android APK build.

The Goblin and Dwarf cards are crops of existing generated faction illustrations.
The Elf cards use matching ornate frames with poses taken from an existing
animated elf archer sheet. The Elf art is an adapted variant, not a claim
that three separate cinematic Elf paintings were generated.

The `ci/test_faction_importer.py` regression verifies the strict layout and
ensures attaching the old HUD ZIP produces an actionable error rather than a
cryptic count mismatch.
