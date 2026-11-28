extends SceneTree
## Player journeys and live data, including small screens and reduced-motion mode.
const Catalog = preload("res://scripts/game_catalog.gd")
var game

func _initialize() -> void:
	call_deferred("_run")

func _require(value: bool, reason: String) -> bool:
	if not value:
		push_error(reason)
		quit(1)
	return value

func _run() -> void:
	root.size = Vector2i(720, 1280)
	game = load("res://main.tscn").instantiate()
	game.presentation.language = "pl"
	# This artwork/navigation fixture deliberately covers every unlocked faction.
	game.account = game.AccountProgress.new("user://qa-smoke_lobby_codex-account.cfg")
	game.account.total_xp = game.account.xp_for_level(20)
	root.add_child(game)
	await process_frame
	if not _require(not quit_on_go_back, "Android Back still exits instead of navigating"):
		return
	await process_frame
	var start: Button = game.main_menu_overlay.find_child("StartGame", true, false)
	if not _require(start.text == "ROZPOCZNIJ GRĘ", "Missing Polish primary start action"):
		return
	# Check the six real destinations, including campaign and costume collection.
	var home = game.main_menu_overlay
	if not _require(home.footer.find_children("*", "Button", true, false).size() == 6, "Home must expose exactly six gameplay/navigation actions"):
		return
	for action in ["StartGame", "OpenCampaign", "OpenTutorial", "OpenCodex", "OpenSettings", "OpenWardrobe"]:
		var button := home.find_child(action, true, false) as Button
		if not _require(is_instance_valid(button) and not button.disabled, "Home action missing or disabled: " + action):
			return
	var campaign_button := home.find_child("OpenCampaign", true, false) as Button
	if not _require(campaign_button.text == "KAMPANIA", "Missing Polish campaign action"):
		return
	# Opening the campaign must not start a match or consume gold.
	game.account.campaign_completed.clear()
	var starting_gold: Array = game.gold.duplicate()
	campaign_button.pressed.emit()
	await process_frame
	if not _require(is_instance_valid(game.campaign_overlay) and not home.visible and game.phase == "SELECT" and game.gold == starting_gold, "Campaign must open a separate chronicle without changing battle state"):
		return
	var first := game.campaign_overlay.find_child("CampaignMission0", true, false) as Button
	var second := game.campaign_overlay.find_child("CampaignMission1", true, false) as Button
	if not _require(is_instance_valid(first) and not first.disabled and is_instance_valid(second) and second.disabled, "Campaign chapter prerequisite is not enforced in the menu"):
		return
	game._navigate_back()
	await process_frame
	if not _require(game.campaign_overlay == null and home.visible, "Back must close chronicle and restore home"):
		return
	if not _require(game.main_menu_overlay.find_child("HomeLivePreview", true, false) == null and game.main_menu_overlay.find_child("ScreenScroll", true, false) == null, "Home regressed into a scrolling character dashboard"):
		return
	var scenery: TextureRect = game.main_menu_overlay.find_child("MainMenuScenery", true, false)
	if not _require(scenery.texture != null and scenery.texture.resource_path.ends_with("epic_vault_menu.png"), "Cinematic artwork missing from actual home screen"):
		return
	if not _require(start.get_theme_stylebox("normal") is StyleBoxTexture, "Play action lost its illustrated metal skin"):
		return
	for dimensions in [Vector2i(540, 960), Vector2i(720, 1280), Vector2i(720, 1560), Vector2i(1080, 1920)]:
		root.size = dimensions
		game.size = Vector2(dimensions)
		await process_frame
		await process_frame
		var bounds: Rect2 = start.get_global_rect()
		if not _require(bounds.end.y <= dimensions.y and bounds.position.y > dimensions.y * 0.72 and bounds.end.x <= dimensions.x and bounds.size.y >= 80, "Home actions overflow or cover character faces at " + str(dimensions)):
			return
		var story_bounds: Rect2 = campaign_button.get_global_rect()
		if not _require(story_bounds.end.y <= dimensions.y and story_bounds.position.y > dimensions.y * 0.72 and story_bounds.end.x <= dimensions.x and story_bounds.size.y >= 80 and not story_bounds.intersects(bounds), "Campaign button overlaps or overflows at " + str(dimensions)):
			return
	root.size = Vector2i(720, 1280)
	game.size = Vector2(720, 1280)
	# All reference stats must agree with actual units, including boosts/abilities.
	for race in 4:
		var entries: Array[Dictionary] = Catalog.entries(game, race)
		if not _require(entries.size() == 21, "Incomplete 21-entry game reference"):
			return
		for entry in entries:
			if not _require(ResourceLoader.exists(entry["art"]), "Missing item/race illustration: " + str(entry["id"])):
				return
		game.selected_race = race
		for ability in [false, true]:
			for level in [0, 3]:
				game.ability_used = ability
				game.raid_boost = level
				for kind in [-1, 0, 1, 2]:
					var expected: Dictionary = game.raider_stats(kind, race, ability, level)
					game.units.clear()
					game._spawn(0, 1, kind, 0.0)
					var actual: Dictionary = game.units[0]
					if not _require(is_equal_approx(float(actual["health"]), float(expected["health"])) and is_equal_approx(float(actual["speed"]), float(expected["speed"])) and actual["capacity"] == expected["capacity"], "Reference calculator differs from battle"):
						return
	game.units.clear()
	game.selected_race = 0
	game.ability_used = false
	game.raid_boost = 0
	var before_gold: Array = game.gold.duplicate()
	game.main_menu_overlay.find_child("OpenCodex", true, false).pressed.emit()
	await process_frame
	var codex = game.codex_overlay
	if not _require(codex != null and not game.main_menu_overlay.visible, "Guide must hide underlying animated lobby"):
		return
	for index in codex.filtered_entries.size():
		codex._select_entry(index)
		await process_frame
		if not _require(codex.live_preview.atlas != null, "Missing battle atlas in guide"):
			return
		if not _require(codex.find_child("EntryIllustration", true, false).texture != null, "Guide lacks image"):
			return
	# Every defense preview must use the new battle atlas, not removed legacy
	# game properties. Exercise each race, actual animation, and reduced motion.
	var Preview = preload("res://scripts/menu_preview.gd")
	var defense_preview = Preview.new()
	game.add_child(defense_preview)
	defense_preview.size = Vector2(300, 220)
	for race in 4:
		for kind in 3:
			defense_preview.configure(game, {"race": race, "demo": ["spikes", "snare", "turret"][kind]})
			if not _require(defense_preview.defense_kind == kind and defense_preview.object_art == game._trap_card_texture(race, kind), "Guide defense preview does not match the battle atlas"):
				return
			defense_preview.playing = true
			game.presentation.reduced_motion = false
			defense_preview.elapsed = 0.01 if kind == 2 else 2.15
			if not _require(defense_preview._defense_frame() == 2, "Guide defense animation is missing its active frame"):
				return
			game.presentation.reduced_motion = true
			if not _require(defense_preview._defense_frame() == 0, "Guide ignores reduced motion"):
				return
	game.presentation.reduced_motion = false
	defense_preview.queue_free()
	# Search, category filtering and an empty result can all recover.
	codex.search.text = "Kolce"
	codex._filter_entries()
	if not _require(codex.filtered_entries.size() > 0 and codex.filtered_entries.size() < 21, "Guide search is not filtering"):
		return
	codex.search.text = "__no_match__"
	codex._filter_entries()
	if not _require(codex.filtered_entries.is_empty() and codex.live_preview == null, "Empty search retains stale preview"):
		return
	codex.search.text = ""
	codex.category_filter.selected = 2
	codex._filter_entries()
	if not _require(codex.filtered_entries.size() == 4, "Unit category should include free waves and all three hired roles"):
		return
	codex.race_filter.selected = 3
	codex.race_filter.item_selected.emit(3)
	if not _require(game.selected_race == 0 and game.gold == before_gold, "Browsing guide modified match race or gold"):
		return
	codex._select_entry(1)
	var preview = codex.live_preview
	preview.set_action(2)
	if not _require(preview.row == 2, "Attack selector is not using attack atlas row"):
		return
	preview.playing = false
	var paused_elapsed: float = preview.elapsed
	await process_frame
	await process_frame
	if not _require(preview.elapsed == paused_elapsed, "Paused preview kept advancing"):
		return
	# Footer and description remain reachable on shorter/smaller portrait phones.
	for dimensions in [Vector2i(540, 960), Vector2i(720, 1280), Vector2i(1080, 1920)]:
		root.size = dimensions
		game.size = Vector2(dimensions)
		await process_frame
		await process_frame
		if not _require(codex.footer.get_global_rect().end.y <= dimensions.y + 2.0 and codex.detail_scroll.size.y >= 150.0, "Guide overflows portrait viewport " + str(dimensions)):
			return
	game._navigate_back()
	if not _require(game.codex_overlay == null and game.main_menu_overlay.visible, "Back did not restore home"):
		return
	game._show_settings()
	if not _require(game.settings_overlay.find_child("QualityMode", true, false) != null, "Missing mobile quality controls"):
		return
	game.presentation.reduced_motion = true
	game._apply_presentation()
	game._close_settings()
	game.main_menu_overlay.find_child("StartGame", true, false).pressed.emit()
	await process_frame
	if not _require(game.selection_layer != null and game.phase == "SELECT", "Start must open selection before battle"):
		return
	for race in 4:
		game.selection_layer.select_race(race)
		if not _require(game.selection_layer.live_preview == null, "Race selection should defer animation controls to the guide"):
			return
		game.selection_layer._inspect_race()
		var reference = game.codex_overlay
		for role_id in ["runner", "carrier", "saboteur", "defender"]:
			reference.focus_entry = role_id
			reference._filter_entries()
			if not _require(reference.live_preview.atlas != null and not reference.live_preview.playing, "Guide is missing role or reduced-motion preview"):
				return
		game._close_codex()
	game._navigate_back()
	if not _require(game.selection_layer == null and game.main_menu_overlay != null, "Cannot return from race selection"):
		return
	game._open_race_selection()
	game.selection_layer.select_race(3)
	game.selection_layer.find_child("ConfirmFaction", true, false).pressed.emit()
	if not _require(game.phase == "PREP" and game.selected_race == 3, "Confirm failed to start chosen race"):
		return
	# Auto adjusts presentation only after sustained low FPS, never gameplay stats.
	var settings = game.MobileSettings.new()
	settings.quality = "auto"
	settings.effective_quality = "balanced"
	for _sample in 3:
		settings.observe_fps(4.1, 19.0)
	if not _require(settings.effective_quality == "battery" and Engine.max_fps == 30, "Automatic profile did not respond to sustained low FPS"):
		return
	settings.quality = "high"
	settings.resolve_profile()
	for _sample in 4:
		settings.observe_fps(4.1, 19.0)
	if not _require(settings.effective_quality == "high", "Auto overrides manually selected high quality"):
		return
	# Exercise persistence without replacing an actual player's preferences.
	var preferences = game.MobileSettings.new("user://qa-presentation.cfg")
	preferences.quality = "battery"
	preferences.reduced_motion = true
	preferences.music_enabled = false
	preferences.show_fps = true
	preferences.save()
	var reloaded = game.MobileSettings.new("user://qa-presentation.cfg")
	DirAccess.remove_absolute("user://qa-presentation.cfg")
	if not _require(reloaded.quality == "battery" and reloaded.reduced_motion and not reloaded.music_enabled and reloaded.show_fps, "Presentation preferences did not survive reload"):
		return
	# Spending the final gold on an ability must obey the zero-vault end rule.
	game.gold[0] = game.ABILITY_COST
	game._use_race_ability()
	if not _require(game.phase == "END", "Ability spending can leave zero vault in an active match"):
		return
	game.queue_free()
	await process_frame
	if not await _check_campaign_maps():
		return
	print("Lobby and codex PASSED: 21 entries, 4 races × 4 roles, shared stats, search, navigation, 4 portrait sizes, simplified cinematic home, mobile profiles")
	quit(0)


func _check_campaign_maps() -> bool:
	# Start each actual chapter through the home/chronicle buttons. Verify
	# imported art, fit, touch picking, and travel in the shipping simulator.
	for mission in 2:
		root.size = Vector2i(720, 1280)
		game = load("res://main.tscn").instantiate()
		game.presentation.language = "pl"
		game.account = game.AccountProgress.new("user://qa-campaign-map-navigation.cfg")
		game.account.campaign_completed.clear()
		if mission == 1:
			game.account.campaign_completed.append("dwarf_bells")
		root.add_child(game)
		await process_frame
		game.main_menu_overlay.find_child("OpenCampaign", true, false).pressed.emit()
		await process_frame
		var chapter := game.campaign_overlay.find_child("CampaignMission%d" % mission, true, false) as Button
		if not _require(is_instance_valid(chapter) and not chapter.disabled, "Campaign map chapter cannot be launched"):
			return false
		chapter.pressed.emit()
		await process_frame
		if not _require(game.campaign_map_art and game.epic_battlefield_texture.resource_path == game.CampaignMaps.ASSETS[mission] and game.phase == "PREP", "Campaign start did not select its original artwork"):
			return false
		game._close_campaign_overlay()
		for dimensions in [Vector2i(720, 1280), Vector2i(1280, 720)]:
			root.size = dimensions
			game.size = Vector2(dimensions)
			await process_frame
			await process_frame
			game._fit_map()
			var world_size: Vector2 = game._battlefield_world_size()
			var visible_size: Vector2 = world_size * game.camera_zoom
			if not _require(visible_size.x <= game.arena.size.x + 1 and visible_size.y <= game.arena.size.y + 1, "Original campaign battlefield clipped at " + str(dimensions)):
				return false
			for road in 3:
				var p: Vector2 = game._point(road, 0.5, 0)
				var screen: Vector2 = game._sprite_transform(p).origin
				if not _require(game._nearest_lane(screen) == road, "Tap selects the wrong campaign road"):
					return false
		game.phase = "ATTACK"
		game.units.clear()
		game.guards.clear()
		game.traps = [[], []]
		game._spawn(0, 1, 0, 0.2)
		var unit: Dictionary = game.units[0]
		var before: float = float(unit["position"])
		game._simulate(0.05)
		var outbound: float = float(unit["position"])
		if not _require(outbound > before, "Campaign raider failed to advance"):
			return false
		unit["returning"] = true
		game._simulate(0.05)
		if not _require(float(unit["position"]) < outbound, "Campaign raider failed to reverse on its route"):
			return false
		game.queue_free()
		await process_frame
	print("Original campaign maps PASSED: actual chapter launch, textures, landscape/portrait fit, lane selection, outbound and return travel")
	return true
