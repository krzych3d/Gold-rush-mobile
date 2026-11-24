# Faction defense sprite atlas

One transparent SVG atlas, imported as a texture by Godot at build time. Four rows (Dwarves, Goblins, Elves, Voidborn), twelve columns (spikes, snare, tower, four authored frames each), 192px cells. No runtime vector rendering, particle shaders, or extra services.

Each device has a grounded metal/stone platform, engraved trim, crystals and a faction palette. Spike blades change geometry, snare jaws rotate/close, and the tower charges, flashes and recoils. All textures are original vector drawings, not generated photorealistic PNGs. The atlas is reused by the native purchase cards with localized titles and prices. The last consumed trap charge leaves a fading mechanism as well as the existing impact effect.

One atlas quad per live trap. Shared texture crops cached per faction and type. Gameplay stats and costs are untouched. Reduced motion uses a static active frame. No new runtime dependencies.

QA: atlas dimensions, all 48 regions, card texture identity, attack state sequence and existing combat/UI/rotation/localization tests. Physical Android screenshots and FPS still need verification; headless tests cannot certify art quality or actual mobile framerate.
