# Vault Wars — Smooth Battle Animation

## Visual animation upgrade (22 November 2026)

- Keep fixed-step 20 Hz combat, preserving health, damage, gold and race balance.
- Snapshot unit positions, interpolate *rendered positions* only; no extra combat updates.
- Preserve fractional elapsed render time. Mobile redraw targets: battery 24, balanced 30, high 45 FPS.
- Continuous walk bounce and gentle silhouette squash, idle breathing, attack wind-up, hit recoil and death fade, on top of authored sprite atlas frames.
- Reduced motion disables additional bob/tilt. Low-power mode skips dust and halves hit-spark segments.
- Gallery throttles redraw according to quality setting and avoids rewriting unchanged labels.
- Auto mode lowers quality if sustained device FPS falls below 75% of current redraw target.

## Verification
Godot CI covers animation assets, direction, interpolation, quality profiles, tutorial and combat balance. On real Android, test all three lanes, unit return with gold, stunned units, attacks, death fade, turning/rotating screen, and graphics quality switches. Target FPS is not a guaranteed achieved FPS.
