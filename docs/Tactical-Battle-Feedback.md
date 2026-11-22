# Vault Wars — tactical combat feedback (22 November 2026)

This update keeps the 20 Hz combat simulation, prices, raider stats and race balancing unchanged.

## On-screen cues
- When a carrier returns gold to its own vault, the amount is awarded immediately and a short, capped group of golden motes travels toward the correct existing gold counter (player or opponent). The animation never grants gold twice.
- When raiders steal from a vault, the associated counter briefly flashes red or amber to make losses legible. The actual stolen amount is deducted in the existing simulation.
- Three attack lanes gain small screen-space warning badges only after living, outbound enemy raiders have progressed beyond 62% of their journey toward the player's vault. Returning carriers, distant units and allies are excluded. The badge number is the live count.
- Both gold numbers use a more urgent text color at 250 gold or less. This remains available with reduced motion switched on.

## Mobile and accessibility
- Animated flight/flash effects are disabled in reduced-motion mode.
- A single click-through overlay owns all coin motes; it never steals input from the lane selector, arsenal, or tutorial.
- Gold-flight records are capped at six in battery mode or twelve in other modes; each flight has three or five simple motes. Expired records are removed and the overlay stays idle when empty.
- Sources and destinations use live Control coordinates, so effects follow portrait/landscape rotation.
- No additional paid APIs, networks, or generated graphics are used.

## Validation
The battle-presentation smoke test now covers both screen orientations, temporary and expired gold effects, reduced motion, wallet integrity and threat counts (including an opponent carrying gold home).
