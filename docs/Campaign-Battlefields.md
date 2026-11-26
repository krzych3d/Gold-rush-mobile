# Original campaign battlefields

The first two dwarven chapters use original 1672×941 JPEG artwork in `assets/epic/world/campaign_vargheim.jpg` and `campaign_breathing_mountain.jpg` (approximately 1.08 MB combined). Artwork stays exclusive to story missions. Ordinary match map selection and save preferences are unchanged.

`scripts/campaign_maps.gd` defines three hand-aligned lane centerlines in image UV coordinates per scene, with smooth interpolation and shared reversed routes for the opposing faction. The simulation, rendering, guard/trap positions, damage and gold-delivery effects all consume `game._point`. Travel speed is normalized by route length; the second chapter's active hazard still multiplies it by 0.55 on the affected road. The animated purple marker follows the road, not the static geological background fissures. The fixed camera fits the full artwork in both orientations without stretching the image to the old map aspect ratio.

The existing smoke suites verify actual story chapter launch, image import, opposite-side route symmetry, separated paths, fit on rotation, lane picking and real outbound/return movement. Full on-device visual and performance QA is still required.
