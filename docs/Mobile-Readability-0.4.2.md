# Larger purchases and a readable story — 0.4.2

The 0.4.1 portrait arsenal gave units and traps roughly 50px of illustration
height, leaving considerable empty space in full-width support banners. The
campaign also introduced its characters and discoveries too abruptly.

## Purchases and touch layout

Unit and trap cards now start at 182 logical pixels, with at least 100px of
illustration height. The first authored unit pose has a cached, padded alpha
crop; every weapon and limb remains inside its original animation cell. This
only changes cards and guide illustrations. Battlefield animation cells, actor
sizes, combat logic, prices and timing are unchanged.

Defender and racial ability share one row; vault and training share the next.
Their illustrations start at 80px high. A long translated ability name wraps in
full, growing its row if necessary. Labels and prices remain inside the painted
frame. Unavailable purchases dim their artwork while keeping the native text
readable. Wrapped caption layout follows its resolved minimum height, fixing
an OpenGL cold-start case where a label retained a narrow-column height and
its text could appear outside the button. Availability updates on wallet/defender/lane changes even when the
cached price and faction stay the same.

The portrait campaign HUD reserves its actual wrapped height and removes the
unused gap above the map. At 720×1440, matching the supplied screenshot's aspect,
the whole dwarf arsenal fits above the permanent attack button. Smaller logical
views and the landscape drawer scroll; attack and menu actions remain reachable.
The fixed camera still shows the whole battlefield in either orientation.

## Story context

All seven dwarf chapters have expanded PL/EN scenes, a location/time subtitle, a recap
and a final tactical briefing. The first recap identifies Thorgar, his brother
Borin and his deceased daughter Eira, and explains the name-coin custom. Later
scenes connect actual discoveries, the brothers' complicity and the next mission.

The story distinguishes the Faceless King's gathered oaths from the dead ruler's
will bound to the throne. Eira consistently asks to be freed, while the unknown
voice offers resurrection. The Vargheim catastrophe stays uncertain in the dwarf
perspective; the fifth crest no longer implies Thorgar is the descendant reserved
for the Voidborn story. The update also adds the first two goblin chapters and an explicit text narrator;
[their scope and mechanics](Goblin-Prologue.md) are documented separately. The
remaining racial chapters and global finale are future work.

Reading uses a dark framed panel, speaker/role captions, full paragraphs, page
numbers, Previous/Next and a scroll region for longer pages. Anonymous voices do
not borrow a companion's portrait. The siege recap restates the saved refugee
choice. The two decision scenes present their choice buttons on the final page,
after the relevant context; going back hides them again. Reading and rotation
continue to pause battle time. Existing first-clear XP, stars, canonical choices,
replay protection, save retries and seen-dialogue skipping are retained.

## Verification

Godot 4.2.2 import and the 14 smoke suites are required. Expanded visual checks
cover all four factions and both languages, including long ability names, complete
first-pose silhouettes, larger art, bounded captions/prices and availability cache
updates. Story checks read every intro, mid-scene and result in PL/EN, exercise
Previous, choice visibility, three screen sizes and the saved siege recap without
changing gold or the preparation countdown. The 132 dwarf battle records
match 0.4.1 exactly; the expanded campaign check covers 177 battles. Existing guided lessons exercise the
real purchase signals and scrolling after the support-row change.

Actual desktop OpenGL screenshots cover both orientations, the dwarf campaign
arsenal, story pages and all four factions. Desktop/headless checks do not prove
sustained Android FPS or physical-device playability. PR validation performs the
full ordinary balance tournament and 132 campaign simulator battles before merge;
only the merge requests an Android build. APK availability is verified separately.
