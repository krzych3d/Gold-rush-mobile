# Goblin Raider animation pack (prototype)

The Godot game loads optional 192px-tall horizontal PNG strips from `assets/epic/animations/`:

| File | Frames | State |
|---|---:|---|
| goblin_raider_idle.png | 8 | Idle |
| goblin_raider_walk.png | 12 | Walk |
| goblin_raider_attack.png | 12 | Attack |
| goblin_raider_hit.png | 8 | Hit |
| goblin_raider_carry.png | 12 | Returning with gold |
| goblin_raider_deposit.png | 12 | Deposit at vault |
| goblin_raider_death.png | 16 | Death |
| goblin_raider_run.png | 12 | Optional, not yet used |

Each strip is exactly `192 * frame_count` pixels wide and 192 pixels tall, with straight alpha. All frames must use the same foot baseline. Do not include headings, borders or background.

**Quality gate:** AI contact sheets are not finished sprite atlases. Review every frame for stray fragments, inconsistent limbs, flicker and background residue. Only merge clean strips. The game falls back to the previous atlas if any optional strip is absent.

**Performance:** import strips with texture compression suited for mobile, avoid separate per-frame nodes, and test at 20+ units. Frame timing is handled by `scripts/game.gd`.

The source AI contact sheet needs cleanup and is not stored in this repository. The optional import system has been committed independently of the PNG art.
