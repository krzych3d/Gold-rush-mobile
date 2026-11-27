# Faction defence art

The shipping defence texture is `assets/epic/story/defenses.webp`: a transparent,
painted fantasy atlas, 3 columns (spikes, snare, turret), 4 rows (dwarves, goblins,
elves, Voidborn), 384 px cells. The generated source was packaged to WebP with
alpha preserved. At 1152 × 1536 it has exactly the same pixel count as the old
2304 × 768 atlas, about 6.75 MiB of uncompressed RGBA pixels.

Purchase cards, reference-book illustrations, live demonstrations and the
battlefield all reuse cached regions of this texture. Activation uses anchored
height keyframes, deployment/recoil, the existing shot effects and brief impact
rings. These are transforms of one illustration per object, not 48 newly drawn
animation poses. Reduced motion holds the static illustration. Existing costs,
damage, cooldowns, stun and sabotage rules are unchanged.

The earlier vector atlas remains as source history and is not used by gameplay.
QA covers all 12 regions, cached card identity, actual damage/activation, guide,
tutorial and mobile layouts. Desktop Godot 4.2.2 rendering was inspected; physical
Android FPS still requires device testing.
