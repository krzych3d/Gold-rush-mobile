# Visual consistency and animation audit — 0.4.1

## Findings and changes

The game had complete base animation sheets, but its visual systems were not
fully consistent. Purchase portraits and guide illustrations could differ from
the deployed unit. Vault upgrades used simple vector buildings. Remaining combat
time was sampled at 20 Hz to choose animation frames; fast hit sequences skipped
poses. Outbound and returning raiders could also use different run sheets, and a
carrier's attack incorrectly used its rolling special.

The changes retain the battle simulator and improve its presentation:

- Purchase cards, defenders and the reference guide use cached crops of the same
  actual faction/role atlases as deployed units. Complete silhouettes are kept.
- The standard map is repaired into one continuous painting: pasted rectangular
  road/grass seams and the baked upper-right minimap are removed. The original
  1920×846 canvas, three lane corridors and game coordinates are retained.
- Five new painted vault buildings share one atlas, with a sixth training
  monument. Original lower-row spires extend above a nominal grid line; packaging
  extracts at the actual clear band and fits the complete silhouettes into cells.
- Four new faction ability emblems are shared by purchase cards and the guide.
- A single painted gold/iron panel replaces the simpler shared frame in cards,
  chronicle, guide, tutorial, settings, reports and other shared surfaces. Native
  labels and prices remain separate, with measured text height and a 16px bottom
  clearance. The footer reserve grows to fit its real decorated minimum size.
- Visual attack/hit clocks start at the actual event and advance between combat
  ticks. Eight hit poses play over 0.40 seconds; gameplay hit/stun timers are not
  extended. Attacks use their own real durations, without random phase offsets.
- Blocking raiders idle between strikes; they do not run in place. Run selection
  is shared by the battlefield, guide and gallery. Return direction mirrors the
  same run clip; the carrier's gold-carry clip remains intentional.
- Deposit and death phases sample interpolated visual time; towers and traps use
  continuous anchored recoil/recovery rather than four snapped scale values.
- Drawing targets are 30 FPS in battery/balanced and 60 FPS in high quality,
  divisible into the respective 30/60 engine limits. This removes the uneven
  24-on-30 and 45-on-60 redraw pattern. These are targets, not measured Android FPS.
- Covered campaign/report overlays stop unnecessary background redraw requests.

## Frame inventory and verification

`ci/smoke_visual_consistency.gd` reads every cell in 11 base and 7 supplemental
1024×768 sheets: 864 nonempty cells, eight distinct pixel buffers per clip, with
alpha. It checks all eight poses are sampled during uninterrupted hit/attack
sequences at 30 and 60 FPS, and verifies the actual card/guide/battle textures,
five different vault regions, full building bounds, faction ability symbols,
painted frame and safe card labels after rotation. Pixel-buffer uniqueness checks
asset completeness; it does not certify artistic motion quality.

Local Godot 4.2.2 verification includes 14 smoke suites. The 132 campaign outcomes
and all 1892 ordinary-tournament match records are exactly identical to 0.4.0,
including gold, results and wave counts. Ordinary balance rules are unchanged.
The tournament has 24 draws, zero timeouts and a longest match of 15 waves.
Actual desktop OpenGL rendering was inspected in portrait and landscape, including
all four factions. Asset inventory and whitespace checks pass.

Character art remains the existing authored eight-frame animation style. This
change does not claim new 16/24-frame character sheets, skeletal animation,
eight-direction art or lip-synced campaign portraits. One illustration per defence
object is animated by continuous transforms and effects; it is not a new set of
48 hand-painted mechanism poses. Physical Android gameplay and sustained FPS still
need device verification; desktop rendering and headless tests cannot prove them.

## Runtime cost

No frame blending, runtime image generation, particle-heavy shader or extra actor
node is added. Each combatant still draws one selected sprite frame. Atlas crops
are cached, the new panel is 256×256, all six vault/training objects share one
1536×1024 texture, and the four ability symbols share one 1024×1024 texture.
Battery mode retains its lower engine limit and omits the expensive scenic layer
and ambient effects.
