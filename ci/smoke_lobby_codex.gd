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
	root.add_child(game)
	await process_frame
	if not _require(not quit_on_go_back, "Android Back still exits instead of navigating"):
		return
	await process_frame
	var start: Button = game.main_menu_overlay.find_child("StartGame", true, false)
	if not _require(start.text == "ROZPOCZNIJ GRĘ", "Missing Polish primary start action"):
		return
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
	var hidden_preview = game.main_menu_overlay.live_preview
	game.main_menu_overlay.find_child("OpenCodex", true, false).pressed.emit()
	await process_frame
	var codex = game.codex_overlay
	if not _require(codex != null and not game.main_menu_overlay.visible, "Guide must hide underlying animated lobby"):
		return
	var elapsed: float = hidden_preview.elapsed
	await process_frame
	await process_frame
	if not _require(hidden_preview.elapsed == elapsed, "Hidden lobby kept animating behind guide"):
		return
	for index in codex.filtered_entries.size():
		codex._select_entry(index)
		await process_frame
		if not _require(codex.live_preview.atlas != null, "Missing battle atlas in guide"):
			return
		if not _require(codex.find_child("EntryIllustration", true, false).texture != null, "Guide lacks image"):
			return
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
	if not _require(not game.main_menu_overlay.live_preview.playing, "Reduced motion must pause automatic previews"):
		return
	game.main_menu_overlay.find_child("StartGame", true, false).pressed.emit()
	await process_frame
	if not _require(game.selection_layer != null and game.phase == "SELECT", "Start must open selection before battle"):
		return
	for race in 4:
		game.selection_layer.select_race(race)
		for role in 4:
			game.selection_layer._pick_role(role)
			if not _require(game.selection_layer.live_preview.atlas != null and not game.selection_layer.live_preview.playing, "Missing race/role or reduced-motion preview"):
				return
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
	print("Lobby and codex PASSED: 21 entries, 4 races × 4 roles, shared stats, search, navigation, 3 portrait sizes, mobile profiles")
	game.queue_free()
	await process_frame
	quit(0)
