extends SceneTree
const Game = preload("res://scripts/game.gd")
const Gallery = preload("res://scripts/animation_gallery.gd")
const Pose = preload("res://scripts/unit_animation.gd")
const Settings = preload("res://scripts/mobile_settings.gd")
const Epic = preload("res://scripts/epic_theme.gd")
var failures: Array[String] = []

func require(ok: bool, reason: String) -> void:
	if not ok:
		failures.append(reason)
		push_error(reason)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	_audit_frames()
	_test_clocks()
	_test_combat_event()
	await _test_actual_ui()
	if failures.is_empty():
		print("Visual consistency PASSED: 864 nonempty frames, eight distinct cells per clip, full event playback at 30/60 FPS, actual faction art across battle/cards/codex, five painted vault tiers, shared panels and bounded images")
	quit(0 if failures.is_empty() else 1)

func _audit_frames() -> void:
	var paths: Array = Gallery.SHEET_PATHS.duplicate()
	paths.append_array(Gallery.SPECIAL_PATHS.values())
	var total := 0
	for path in paths:
		var texture: Texture2D = load(str(path))
		require(texture != null and texture.get_size() == Vector2(1024, 768), "Missing authored animation sheet: " + str(path))
		if texture == null: continue
		var image: Image = texture.get_image()
		if image.is_compressed(): image.decompress()
		require(image.detect_alpha() != Image.ALPHA_NONE, "Opaque background on character atlas: " + str(path))
		for row in 6:
			var signatures: Dictionary = {}
			for column in 8:
				var tile: Image = image.get_region(Rect2i(column * 128, row * 128, 128, 128))
				require(tile.get_used_rect().has_area(), "Empty animation frame: %s/%d/%d" % [path, row, column])
				signatures[hash(tile.get_data())] = true
				total += 1
			require(signatures.size() == 8, "Duplicated animation cells: %s row %d" % [path, row])
	require(total == 864, "Incomplete base/special animation inventory")

func _test_clocks() -> void:
	# A real strike must produce a complete, un-offset visual reaction even when
	# its combat timer is shorter than the eight-frame visual sequence.
	for fps in [30, 60]:
		for event in ["hit", "attack"]:
			for guard in [false, true]:
				var actor := {"action_time": 0.0}
				Pose.trigger(actor, event, 0.2 if event == "hit" else 0.38 if guard else 0.45)
				var seconds: float = Pose.duration(actor, event, guard)
				var observed: Dictionary = {}
				var simulated := 0.0
				var previous := -1
				for render_step in int(ceilf(seconds * fps)):
					var time: float = float(render_step) / fps
					while simulated + 0.05 <= time + 0.000001:
						Pose.advance(actor, 0.05)
						simulated += 0.05
					var sample: int = Pose.frame(actor, 3 if event == "hit" else 2, guard, time - simulated, 5.0)
					require(sample >= previous, "One-shot animation rewound or looped")
					observed[sample] = true
					previous = sample
				require(observed.size() == 8 and observed.has(0) and observed.has(7), "Visual event skips frames at %d FPS: %s/%s" % [fps, event, guard])
	var actor := {}
	Pose.trigger(actor, "hit", 0.2)
	Pose.advance(actor, 0.1)
	require(actor["hit_time"] == 0.2 and actor["hit_pose_age"] == 0.1, "Visual clock changes combat timers")
	require(Pose.row({"blocked": true}, false, true, 0) == 0, "Blocked raider runs in place between attacks")
	require(Pose.special_row("dwarf_carrier", 2, false, false) == -1, "A carrier's attack displays a dodge animation")
	var previous: float = Pose.recoil(0.28, 0.28)
	for i in range(1, 101):
		var value: float = Pose.recoil(0.28 * (1.0 - float(i) / 100.0), 0.28)
		require(absf(value - previous) < 0.03, "Tower recoil snaps between discrete poses")
		previous = value
	var settings = Settings.new("user://qa-visual-settings.cfg")
	for mode in ["battery", "balanced", "high"]:
		settings.quality = mode
		settings.resolve_profile()
		require(settings.battlefield_fps() == (60.0 if mode == "high" else 30.0) and fmod(float(Engine.max_fps), settings.battlefield_fps()) == 0.0, "Draw cadence produces uneven frame intervals")

func _test_combat_event() -> void:
	var game = Game.new()
	game.phase = "PREP"
	game.gold = [2000, 2000]
	game.purchase_guard(0, 1)
	game.phase = "ATTACK"
	game._spawn(1, 1, 0, 0.81)
	var target: Dictionary = game.units[0]
	var before: float = float(target["health"])
	game._simulate(0.05)
	require(is_equal_approx(before - float(target["health"]), 26.0), "Visual event trigger changes actual strike damage")
	require(is_equal_approx(float(target["hit_time"]), 0.19), "Visual event trigger extends the actual combat reaction timer")
	require(target.get("hit_pose_age", -1.0) == 0.0 and Pose.frame(target, 3, false, 0.0) == 0, "Actual 20Hz strike skips the first authored reaction pose")
	game.guards[0]["cooldown"] = 10.0
	game._simulate(0.05)
	require(is_equal_approx(float(target["hit_pose_age"]), 0.05), "Combat does not advance the visual event clock")
	game.free()

func _test_actual_ui() -> void:
	root.size = Vector2i(720, 1280)
	var game = load("res://main.tscn").instantiate()
	game.account = game.AccountProgress.new("user://qa-visual-account.cfg")
	game.account.total_xp = game.account.xp_for_level(20)
	game.presentation.language = "pl"
	root.add_child(game)
	game._choose_faction(2) # Cold start before the first container/font layout.
	for child in game.get_children():
		if child is Timer: child.stop()
	for _frame in 5: await process_frame
	for card in [game.guard_button, game.ability_button, game.invest_button, game.raid_button]:
		var surface = card.get_node("LocalizedSurface")
		require(Rect2(Vector2.ZERO, card.size).encloses(surface.caption.get_rect()) and surface.caption.get_line_count() == surface.caption.get_visible_line_count(), "Wrapped caption is invisible or keeps its initial narrow-column height on cold start")
	for race in 4:
		game._choose_faction(race)
		for kind in 3:
			var art: AtlasTexture = game.controls[kind + 3].get_node("LocalizedSurface").illustration.texture as AtlasTexture
			var expected: Texture2D = game._character_atlas(game._character_key_for_race(race, kind))
			require(art != null and art.atlas == expected and art == game._unit_card_texture(race, kind), "Purchase portrait does not match deployed character")
			var image: Image = expected.get_image()
			if image.is_compressed(): image.decompress()
			var opaque: Rect2i = image.get_region(Rect2i(0, 0, 128, 128)).get_used_rect()
			require(Rect2i(art.region).encloses(opaque) and Rect2i(0, 0, 128, 128).encloses(Rect2i(art.region)), "Purchase crop cuts a weapon, limb or neighbouring animation cell")
			var entry: Dictionary = game.Catalog.find(game, race, ["runner", "carrier", "saboteur"][kind])
			require(game.Catalog.illustration(game, entry) == art, "Reference guide displays a different unit")
		var defender: Texture2D = game.guard_button.get_node("LocalizedSurface").illustration.texture
		require(defender == game._unit_card_texture(race, 0, true), "Defender banner does not match guard art")
		require(game.raid_button.get_node("LocalizedSurface").illustration.texture == game.TRAINING_ART, "Training card retains mismatched baked artwork")
		require(game.ability_button.get_node("LocalizedSurface").illustration.texture == game._ability_card_texture(race), "Ability symbol does not match the faction")
		require(game.invest_button.get_node("LocalizedSurface").illustration.texture == game.VAULT_TIER_ART[0], "Vault card does not use actual building art")
	var regions: Dictionary = {}
	var building_image: Image = game.VAULT_TIER_ART[0].atlas.get_image()
	if building_image.is_compressed(): building_image.decompress()
	for slot in 6:
		var bounds: Rect2i = building_image.get_region(Rect2i((slot % 3) * 512, (slot / 3) * 512, 512, 512)).get_used_rect()
		require(bounds.has_area() and bounds.position.x >= 20 and bounds.position.y >= 18 and bounds.end.x <= 492 and bounds.end.y <= 482, "Painted vault silhouette touches a neighbouring cell or loses its spire")
	for art in game.VAULT_TIER_ART:
		require(art is AtlasTexture and art.atlas.resource_path.ends_with("vault_tiers.webp"), "A vault still uses the old vector placeholder")
		regions[art.region] = true
	require(regions.size() == 5, "Vault levels duplicate the same architecture")
	require(Epic.panel(0).texture.resource_path.ends_with("epic_panel.webp"), "Shared panel style retains a mismatched frame")
	for dimensions in [Vector2i(540, 960), Vector2i(720, 1280), Vector2i(1280, 720)]:
		root.size = dimensions
		game.size = Vector2(dimensions)
		for language in ["pl", "en"]:
			game._change_language(language)
			for race in 4:
				game._choose_faction(race)
				for _frame in 5: await process_frame
				for card in game.controls.slice(3, 9):
					var surface = card.get_node("LocalizedSurface")
					require(surface.illustration.get_rect().end.y <= surface.caption.position.y - 3 and surface.illustration.size.y >= 100 and surface.illustration.size.y <= 160 and surface.cost.get_rect().end.y <= card.size.y - 14, "Large art is tiny or covers native card labels")
				for card in game.controls.slice(3, 9) + [game.guard_button, game.ability_button, game.invest_button, game.raid_button]:
					var surface = card.get_node("LocalizedSurface")
					var safe := Rect2(Vector2(8, 8), card.size - Vector2(16, 16))
					require(safe.encloses(surface.illustration.get_rect()) and safe.encloses(surface.caption.get_rect()) and safe.encloses(surface.cost.get_rect()), "Large art, long translated title or price escapes its frame: %s/%d/%s" % [language, race, surface.caption.text])
					# Shape before querying visible lines: headless getters can otherwise
					# compare the previous width's cached count with the new line count.
					require(surface.caption.get_line_count() == surface.caption.get_visible_line_count(), "Translated purchase caption loses a visible line: %s/%d/%s at %s, %d/%d lines, %s" % [language, race, surface.caption.text, dimensions, surface.caption.get_visible_line_count(), surface.caption.get_line_count(), surface.caption.get_rect()])
	game._choose_faction(0)
	game.gold[0] = 2500
	game._refresh()
	var ability_surface = game.ability_button.get_node("LocalizedSurface")
	require(game.ability_button.disabled and ability_surface.illustration.modulate != Color.WHITE and ability_surface.caption.modulate == Color.WHITE, "Unavailable purchase is indistinct or makes its caption unreadable")
	game.guard_button.pressed.emit()
	require(not game.ability_button.disabled and ability_surface.illustration.modulate == Color.WHITE, "First defender enables Iron Wall but its cached icon stays dark")
	game.gold[0] = 1
	game._refresh()
	var trap_surface = game.controls[6].get_node("LocalizedSurface")
	require(game.controls[6].disabled and trap_surface.illustration.modulate != Color.WHITE, "Wallet changes do not refresh cached card availability")
	game.gold[0] = 2500
	game._refresh()
	require(not game.controls[6].disabled and trap_surface.illustration.modulate == Color.WHITE, "A replenished wallet leaves a usable purchase dark")
	game.queue_free()
	await process_frame
