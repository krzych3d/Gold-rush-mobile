# Testament of the Dead Gods — Legacy of Blood

Implemented slice: seven bilingual dwarven chapters, using the shipping three-lane
simulator and fixed camera. Two goblin opening chapters are now documented in Goblin-Prologue.md. The remaining
racial chapters, global finale, 40+12 mission target, legendary difficulty, new
race soundtracks, cosmetic reward system and full
character/cinematic animation are future work.

| Chapter | Actual objective and rule | Battlefield |
| --- | --- | --- |
| I · Bells for the Dead | Survive 3 waves; additional returning guards | Vargheim |
| II · The Breathing Mountain | Deliver 180 actual gold in ≤4 waves; rotating lane slows both armies by 45% | Dead god's ribs |
| III · The Price of One Coin | Deliver 240 in ≤4 waves; each 100 spent adds 8% HP to newly spawned enemies, capped at 80% | Mint of Names |
| IV · The Faceless Feast | Kill the 440 HP King in ≤4 waves; wounds persist and half-HP phase raises movement speed by 35% | Ancestors' Hall |
| V · Sons of the Curse | Save 3 of 4 refugee groups; 10-second departure delay, announced route and ritual traps | Vargheim |
| VI · The Bone Throne | Kill the King and deliver 180 in ≤5 waves; a rotating lane trembles from wave 2 | Ancestors' Hall |
| VII · The Last Oath | Kill the Echo and deliver 360 in ≤5 waves; one rotating lane inflicts 5 HP/s on units and guards of both sides | Dead god's heart |

The three bosses use existing unit animation sheets at a larger readable scale;
they are not three new bespoke boss models. Their location is announced in the
preparation HUD. A refugee never creates gold; only a unit's actual delivered loot
advances memory-gold objectives. Escort ritual traps deliberately have extra
charges; the briefing explains this exception. Survivors with gold still in transit
at the wave timeout do not count as delivered.

## Decisions and progression

The first refugee decision is immutable on replays: opening the gates gives the
chapter-VI boss +80 HP and grants the player three defenders; hiding the families
gives the boss −60 HP without extra defenders. The final choice has two different
written epilogues: release all souls, or resurrect Eira at their expense. These
choices are retained for future cross-race consequences. The loss of the dwarven
gift in one epilogue is narrative; ordinary duel interest is unchanged.

Completion, XP, best stars and canonical choices share an atomic account save and
rollback. Old version-1 saves load with empty new fields. Replays can improve the
best star rating but give no XP and cannot rewrite a previous choice. First clear
uses the existing win-and-finished-wave XP formula. Chapters open in order with
the existing race/level checks. A decision is required before that chapter is
saved and rewarded; Android Back cannot bypass it. Save failures remain visible
with retry actions.

Three stars come from completing the objective, retaining at least half of the
starting gold, and one optional goal. That goal is an early finish; chapter I
instead requires 1000 remaining gold, III a spending limit of 600, and V no lost
refugee group. The mission briefing explains the current goals.

## Presentation and isolation

The chronicle uses an illustrated magical book, chapter thumbnails and saved
stars. Story scenes use portraits of Thorgar, Borin and Eira, a scenic layer,
subtle parallax, a few motes, readable paragraph pages and speaker fades. Seen
chapter dialogue can be skipped. Reduced-motion and battery profiles disable
continuous scene animation. Text scrolls when necessary; advance/back actions
stay outside the scroll. Both orientations preserve uncropped character faces.

Four authored battlefield paintings serve seven story locations. Revisited
locations gain live hazard/escort/boss markings; their environmental rules affect
actual units. Routes on the two new paintings were aligned separately. Authored
route lengths preserve combat travel time. Campaign art is a temporary override,
never a change to a player's saved duel map. No shader or particle system was
added and the defence atlas keeps the old pixel budget.

## Validation on 2026-11-27

- Godot 4.2.2 import and the 13 `ci/smoke_*.gd` suites pass locally.
- `smoke_story_campaign.gd`: seven chapters, PL/EN text, legacy saves, rollback,
  replay XP/best stars, immutable decisions, real debt HP, persistent boss wounds,
  second phase, actual turret kill, escort arrival, symmetric collapse, story
  pagination, paused countdown, portrait/landscape rotation and HUD-map separation.
- `campaign_playthrough.gd`: 132 actual simulator battles, three seeds per
  chapter, six ordinary strategies plus two route-aware escort strategies.
  Every chapter/seed has at least two successful strategies. The escort cannot
  be won by waiting; both tested escort plans clear the announced route.
- `balance_tournament.gd --full`: 1892 ordinary matches, 24 draws, no timeouts,
  longest match 15 waves; balance acceptance checks pass.
- Existing tutorial: 15 lessons in PL/EN, 148 steps, 86 actual button signals,
  isolated rewards and seven screen sizes pass.
- Real desktop OpenGL rendering inspected at 720×1280 and 1280×720 for the
  chronicle, dialogue and mint battlefield. This is not an Android device test.
- Asset manifest and whitespace checks pass.

PR CI repeats validation once before merge. The redundant second full Godot CI
run on `main` is removed; the Android build retains its packaging smoke checks,
including the new campaign suite. One Android build is requested through merge.
An APK may only be called available after its build and direct release asset
are verified separately.
