# Thieves of Fate — playable opening and text narrator

Version 0.4.2 includes nine playable chapters: seven dwarven chapters and the
first two goblin chapters. The goblin opening is available on a fresh level-1
account, separately from the dwarven story. Its second chapter requires the first
one. The remaining five goblin chapters, elves, Voidborn and the global finale
are future work; their missions are not presented as playable.

## Narrative and reading

A text narrator identifies prose passages and keeps each racial perspective
separate. The goblin story revisits Vargheim's catastrophe through Rikk and Nix:
what they hear beneath the altar explains the theft without confirming the
ultimate fate of the city. Future-coin payment, the unknown employer, the missing
star and the first signs of Rikk's erasure remain clues, not a reveal of the
final antagonist. The second chapter makes the cost of stolen death concrete
before pointing towards the Market of Lost Names.

The Context action is available before, between and after missions. It shows the
chapter's starting situation and cast relationships, then returns to the exact
page without advancing the scene. It does not reveal an unread ending. The siege
recap still reflects the saved refugee choice. The narrator/anonymous speakers
use scenery without borrowing a hero's face. There is no recorded narration or
lip sync in this revision. Previous/Next, seen-dialogue skipping, pause while
reading and paginated decisions are retained in PL/EN and both orientations.

## Actual mission rules

| Chapter | Goal | Battle rule |
| --- | --- | --- |
| I · The Stranger's Contract | Return the Memory Stone within four waves | A hired runner, carrier or saboteur reaches the enemy vault via the middle lane with Nix's lockpick. Free waves only steal ordinary gold. The item has one carrier; pickup alone gives no victory. A fallen carrier or wave timeout returns it to its chamber. Only actual arrival at the player's vault completes the objective. |
| II · The City Without Funerals | Hold the refuge vault for three waves | Goblin raiders and defenders of both armies rise once per wave. Their maximum HP becomes 60% of its previous value. Raiders also retain 80% speed and 70% capacity. A two-second rise is inactive/untargetable; carried gold stays with its carrier. A second fall removes the body from combat and refunds undelivered loot normally. A persistent defender may rise and weaken again next wave. |

The heist marks the correct road and shows the item's chamber/transit/delivered
state in the HUD. A painted item marker follows its actual carrier. The curse
shows returning bodies and a shared return counter. Both rules are campaign-only;
ordinary duels and the tutorial keep their existing combat/economy behavior.

Completion uses the existing atomic account save, first-clear XP and best stars.
The goblin prologue introduces no new canonical decision; both dwarven decisions
and their save/replay behavior remain intact. There is no XP for replaying it.

## Art and mobile budget

New portraits: `assets/epic/story/rikk.jpg` and `nix.jpg` at 540×720. New battlefield:
`funeral_city.jpg` at 1672×941, with authored UV streets and the existing road-length
travel-time correction. The heist deliberately revisits `throne.jpg`. The actual
objective uses `memory_stone.png`, a 256px transparent icon. Source prompts,
packaging and hashes are in `art_sources/goblin-story-2026-11-28.json`.

The new rules add dictionary fields and bounded visual marks, not shaders,
particle nodes, per-frame texture reads or unbounded resurrection queues. Existing
reduced-motion and battery profiles apply. No new hero or boss animation sheet is
claimed; Rikk and Nix portraits use the existing story transition system.

## Validation

Godot 4.2.2: 14 smoke suites, including every PL/EN story page/context round trip,
two fresh-account faction starts, actual menu/purchase/heist/save/XP progression,
artifact death/timeout/recovery, symmetric limited revival, guard-hit revival and
duel isolation. The campaign tournament now runs 177 battles across three seeds:
at least two winning strategies per chapter/seed, and idle free waves cannot
complete the heist. All 132 previous dwarf match records remain identical.

The full ordinary tournament passes after the new guarded combat hooks: all
1892 match records remain identical, with 24 draws, zero timeouts and a longest
match of 15 waves.
Desktop OpenGL inspection covers portraits, narrator/context, both battlefields,
item markers and both orientations. Sustained FPS and physical Android gameplay
still need device verification. PR CI validates the final revision before merge;
a single post-merge APK is checked separately before sharing its direct link.
