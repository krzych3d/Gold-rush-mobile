extends SceneTree
## Real language switching, persistence, all guide entries and live battle captions.
const L10n = preload("res://scripts/localization.gd")
const Catalog = preload("res://scripts/game_catalog.gd")
const Settings = preload("res://scripts/mobile_settings.gd")
var game

func _initialize() -> void:
	call_deferred("_run")

func require(condition: bool, reason: String) -> bool:
	if not condition:
		push_error(reason)
		quit(1)
	return condition

func _has_polish(text: String) -> bool:
	for character in "ąćęłńóśźżĄĆĘŁŃÓŚŹŻ":
		if text.contains(character):
			return true
	return false

func _run() -> void:
	root.size = Vector2i(720, 1280)
	game = load("res://main.tscn").instantiate()
	game.presentation = Settings.new("user://qa-languages.cfg")
	game.presentation.language = "pl"
	game.presentation.reduced_motion = true
	# This artwork/navigation fixture deliberately covers every unlocked faction.
	game.account = game.AccountProgress.new("user://qa-smoke_localization-account.cfg")
	game.account.total_xp = game.account.xp_for_level(20)
	root.add_child(game)
	await process_frame
	await process_frame
	if not require(game.main_menu_overlay.find_child("LanguageEN", true, false) != null, "Home lacks language switch"):
		return
	game.main_menu_overlay.find_child("LanguageEN", true, false).pressed.emit()
	await process_frame
	if not require(game.presentation.language == "en" and game.main_menu_overlay.find_child("StartGame", true, false).text == "START GAME", "Home switch did not update labels immediately"):
		return
	game._show_settings()
	var language: OptionButton = game.settings_overlay.find_child("LanguageMode", true, false)
	language.item_selected.emit(0)
	await process_frame
	await process_frame
	if not require(game.presentation.language == "pl" and game.settings_overlay.find_child("LanguageMode", true, false).selected == 0, "Settings switch failed to rebuild settings"):
		return
	var persisted = Settings.new("user://qa-languages.cfg")
	if not require(persisted.language == "pl", "Language does not survive restart"):
		return
	game._close_settings()
	game._open_race_selection()
	for race in 4:
		game.selection_layer.select_race(race)
		for code in ["en", "pl"]:
			game._change_language(code)
			await process_frame
			if not require(game.selected_race == race and game.selection_layer.focus_race == race, "Switching language changes the chosen race"):
				return
			var expected: String = L10n.t(Catalog.RACE_TITLES[race]).to_upper()
			if not require(game.selection_layer.hero_name.text == expected, "Faction nameplate is not localized"):
				return
	for code in ["en", "pl"]:
		game._change_language(code)
		for race in 4:
			var entries: Array[Dictionary] = Catalog.entries(game, race)
			if not require(entries.size() == 21, "Language changes guide coverage"):
				return
			for entry in entries:
				if code == "en":
					for field in ["title", "body", "tip", "limit", "category", "stats"]:
						if not require(not _has_polish(str(entry[field])), "Untranslated guide field: %s/%s" % [entry["id"], field]):
							return
		game._show_codex("spikes")
		var guide = game.codex_overlay
		guide.search.text = "Spikes" if code == "en" else "Kolce"
		guide._filter_entries()
		if not require(not guide.filtered_entries.is_empty(), "Search does not use translated text"):
			return
		game._close_codex()
	game._choose_faction(0)
	game._select_lane(2)
	game._buy_unit(0)
	var saved_gold: Array = game.gold.duplicate()
	var saved_orders: Array = game.orders[0].duplicate(true)
	for code in ["en", "pl", "en"]:
		game._change_language(code)
		await process_frame
		if not require(game.phase == "PREP" and game.gold == saved_gold and game.orders[0] == saved_orders and game.lane == 2, "Language switching resets the match"):
			return
		var surface = game.controls[3].get_node("LocalizedSurface")
		if not require(surface.caption.text == L10n.t("RUNNER") and surface.cost.text.contains("75"), "Unit art does not have localized native labels and live cost"):
			return
		if not require(game.guard_button.get_node("LocalizedSurface").caption.text == L10n.t("DEFENDER"), "Defender keeps baked English text"):
			return
		for dimensions in [Vector2i(540, 960), Vector2i(720, 1280), Vector2i(720, 1560), Vector2i(1080, 1920)]:
			root.size = dimensions
			game.size = Vector2(dimensions)
			await process_frame
			await process_frame
			if not require(game.battle_shell.dock.get_global_rect().end.x <= dimensions.x and game.hud.is_visible_in_tree(), "Localized battle actions leave phone viewport"):
				return
	game._begin_attack()
	if not require(game.phase == "ATTACK" and game.battle_shell.drawer_open, "Translation altered phase IDs or hid portrait commands"):
		return
	game.gold[1] = 0
	game._check_vaults()
	await process_frame
	await process_frame
	if not require(game.result_overlay.find_child("OutcomeHeadline", true, false).text == "VICTORY", "English result is not localized"):
		return
	var invalid = Settings.new("user://qa-invalid-language.cfg")
	var config := ConfigFile.new()
	config.set_value("interface", "language", "invalid")
	config.save("user://qa-invalid-language.cfg")
	invalid = Settings.new("user://qa-invalid-language.cfg")
	if not require(invalid.language == "en", "Invalid saved locale lacks a safe fallback"):
		return
	for path in ["user://qa-languages.cfg", "user://qa-invalid-language.cfg"]:
		DirAccess.remove_absolute(path)
	print("Localization PASSED: PL/EN, persistence, 21 entries × 4 factions, native card captions, unchanged economy and 4 phone sizes")
	game.queue_free()
	await process_frame
	quit(0)
