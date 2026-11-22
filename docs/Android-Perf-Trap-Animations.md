# Android frame pacing and trap animation — November 2026

## Diagnosis from the Android screenshot
The reported overlay shows FPS 9, "SCRIPT 256.2 ms" and one unit.
The original SCRIPT number came from `Performance.TIME_PROCESS`, which measures
process-frame CPU time rather than GDScript alone. The overlay now reads CPU
and reports separate `_refresh()` (UI) and `_draw_arena()` draw-command costs
when Show FPS is enabled. These are *not GPU timing measurements*.

## Optimizations
- Localized card skins, atlas crop textures, captions and layouts are
  reconfigured only when race, language, phase or their actual prices/state change.
- Decorative lane StyleBoxes are rebuilt only when the selected lane changes.
- The mobile battle shell updates labels, low-gold colors and fitted button
  captions only when their contents change.
- Battery quality skips the redundant full-screen scenic backdrop and
  nonessential idle trap rings.
- No hidden game simulation rate increase: physics still runs at 20 Hz.
  These changes reduce avoidable CPU/UI work; actual FPS varies by device.

## Spikes and snares
- Spikes idle partly recessed, quickly rise over 0.09s, then retract.
- Snares visibly snap toward the unit and spring back, with violet impact.
- Impact bursts persist briefly even if a trap is removed after its final charge.
- Impacts are capped at eight on battery quality or fourteen otherwise and
  expire after 0.46 seconds; battery mode uses fewer particles.
- Faction-specific shop artwork, original sprite sheets, gold, prices, damages,
  Shadow Step evasion, snare stun, and the balance rules are unchanged.

## Verification
Godot 4.2.2 CI tests unchanged card StyleBox and texture identity across idle
refreshes; animation phase timing; spike damage; snare stun; residual
last-charge impact and effect expiration; existing gameplay and tutorial
regressions. On an actual Android phone, enable the FPS counter in Settings
and compare CPU/UI/DRAW and rendered FPS during an empty lane, after building
a trap and when the trap fires. Debug builds may differ from release builds.
