# Campaign costumes and player wardrobe

The Book of Costumes opens from the main menu or race selection. Its preview
shows every role, six base actions, both facings and manual playback. Locked
costumes can be inspected, with their actual unlock requirement, but cannot be
equipped. PL/EN, portrait/landscape and Android safe areas are supported. Back
returns to the same lobby without starting or resetting a battle.

## Collection

| Costume | Faction | Requirement | Artwork |
| --- | --- | --- | --- |
| Legacy | All four | Faction unlocked | Original outfits |
| Royal Oath | Dwarves | Available from the start | Three new sheets: knight, porter and dwarven runekeeper |
| Restless Ancestors | Dwarves | Bells for the Dead | New spectral knight sheet; ethereal tint/transparency on the royal escort |
| Mintbound | Dwarves | The Price of a Coin | Royal outfits with a warmer gold palette |
| Thread Thieves | Goblins | A Stranger’s Contract | Two new sheets: raider and saboteur, teal cloaks and gold-thread embroidery |
| Those Death Passed By | Goblins | City Without Funerals | Desaturated revenant palette on the thief outfits |
| White Grove Vigil | Elves | Account level 5 | Cool colour variant of existing models |
| Black Sun | Voidborn | Account level 10 | Muted colour variant of existing models |
| Trace of the Forgotten | Voidborn | Level 10 and The Last Oath | Spectral colour/transparency variant of existing models |

The eight alternative IDs are cosmetic. They do not change health, speed, carry
capacity, costs, AI, abilities or the random-number stream. Each faction retains
its separate selection. `wardrobe.cfg` uses a versioned temporary write, rename,
backup and rollback; account XP and campaign saves are not rewritten by equipping.
Missing/unknown/wrong-race/locked IDs fall back to Legacy. Unreadable files are
preserved. Unlocks are derived from saved account level and mission completion,
so existing players immediately receive rewards for earlier clears.

First successful mission completion announces the corresponding costume even at
the XP cap. Replays do not repeat the unlock announcement or XP. Failed account
saves do not grant the reward. Race unlocks still apply to cosmetic rewards.

## Story appearances

Campaign appearance is temporary and never overwrites the player’s selection.
Living guards and ancestral enemies share their royal insignia, making the cost
of the old oath visible. The Oath’s Echo uses the spectral dwarf shape while
retaining its existing Voidborn combat rules. A revenant goblin’s costume fades
after resurrection, including its defender, final fall and deposit animation.

| Chapter | Player appearance | Enemy appearance |
| --- | --- | --- |
| Dwarf I / IV | Royal Oath | Restless Ancestors |
| Dwarf II | Royal Oath | Trace of the Forgotten |
| Dwarf III | Royal Oath | Mintbound |
| Dwarf V | Mintbound | Royal Oath |
| Dwarf VI | Royal Oath | Restless Ancestors |
| Dwarf VII | Royal Oath | Spectral Voidborn; the boss is a spectral dwarf |
| Goblin I | Thread Thieves | Royal Oath |
| Goblin II | Thread Thieves, faded after returning from death | Same rule |

## Animation and device budget

Six new 1024×768 RGBA atlases add 288 authored cells, arranged as eight poses for
each of idle, walk, attack, hit, fall and deposit. They retain the existing motion
choreography and combat-triggered animation clock. They are costume animations,
not new 16/24-frame choreography, eight-direction movement or skeletal animation.
Nonempty/distinct-buffer checks audit completeness; rendered inspection checks
appearance. Mirroring handles both travel directions.

Battle, purchase cards, guide, live previews and Animation Studio share the same
skin resolver, texture and tint. A custom costume uses its full six-row sheet;
incompatible original supplemental clips and strips cannot switch its clothes.
Fall/deposit records retain the appearance, including story model overrides.
Team rings and health bars remain separate, with full contrast.

Textures load once and are shared. Required battle costumes warm before the
opening dialogue closes. Six additional uncompressed RGBA sheets have a maximum
pixel budget of 18 MiB when all are retained; no per-character nodes, materials,
particles or per-frame image conversions are added. Spectral trails add at most
one faint quad per figure and are disabled in battery/reduced-motion modes.
Existing 30/60 FPS targets and interpolation remain in effect; actual performance
on low-end Android hardware still needs a physical-device measurement.

Source identities and installed hashes are in
`art_sources/campaign-skins-2026-11-28.json`. `ci/pack_campaign_skins.gd` reproduces
cell-by-cell resampling from the original generated files. The shipping art
inventory contains 180 files.

## Validation

`ci/smoke_skins.gd` audits the six sheets and exercises real costume controls,
locks, saves, backup recovery, write failure, account isolation, old saves,
mission rewards/replays, all roles/actions, codex, Animation Studio, direction,
PL/EN, phone layouts, campaign boss appearance and final revenant guard fall.
It compares identical real battles with and without a selected costume, including
units, traps, orders, wallet and RNG state.

Godot 4.2.2 local verification passes all 15 smoke suites. All 177 campaign battle
records match 0.4.2 exactly. All 1892 ordinary-tournament match records also match 0.4.2 exactly (24 draws, zero timeouts).
Native OpenGL renders were inspected in portrait and landscape. This revision
adds no further campaign chapters beyond the existing seven dwarf and two
goblin missions, and does not claim physical Android gameplay certification.
