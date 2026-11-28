extends SceneTree
## Real cosmetic persistence, scene overrides, animation inventory and UI journeys.
const Game = preload("res://scripts/game.gd")
const Skins = preload("res://scripts/unit_skins.gd")
const Loadout = preload("res://scripts/cosmetic_loadout.gd")
const Profile = preload("res://scripts/account_progress.gd")
const Story = preload("res://scripts/story_campaign.gd")
const Preview = preload("res://scripts/menu_preview.gd")
var failures: Array[String] = []
var prefix := "user://qa-skins-" + Crypto.new().generate_random_bytes(5).hex_encode()
var game

func _initialize() -> void:
	call_deferred("run")

func require(value: bool, reason: String) -> void:
	if not value:
		failures.append(reason)
		push_error(reason)

func run() -> void:
	_inventory()
	_persistence()
	_simulation_isolation()
	await _player_journey()
	for path in [prefix, prefix + "-account", prefix + "-legacy", prefix + "-bad", prefix + "-ui", prefix + "-ui-account"]:
		for suffix in ["", ".bak", ".pending"]:
			if FileAccess.file_exists(path + suffix):
				DirAccess.remove_absolute(path + suffix)
	print("Campaign skins PASSED: 288 authored cells, locks and atomic saves, campaign overrides, all roles, falls/deposits, PL/EN, portrait/landscape and unchanged simulation" if failures.is_empty() else "Campaign skins FAILED: %d" % failures.size())
	quit(0 if failures.is_empty() else 1)

func _inventory() -> void:
	var ids := {}
	var paths := {}
	for skin in Skins.SKINS:
		require(not ids.has(skin["id"]), "Duplicate costume ID")
		ids[skin["id"]] = true
		for field in ["name", "lore", "type"]:
			require(skin[field].size() == 2 and not skin[field][0].is_empty() and not skin[field][1].is_empty(), "Missing PL/EN costume copy")
		for key in Skins.ROYAL.keys() + Skins.THREADS.keys():
			var path: String = Skins.path(str(skin["id"]), str(key))
			if not path.is_empty(): paths[path] = true
	require(paths.size() == 6, "Incomplete authored costume inventory")
	var cells := 0
	for path in paths:
		var texture: Texture2D = load(path)
		require(texture != null and texture.get_size() == Vector2(1024, 768), "Wrong costume sheet dimensions: " + path)
		if texture == null: continue
		var image: Image = texture.get_image()
		if image.is_compressed(): image.decompress()
		require(image.detect_alpha() != Image.ALPHA_NONE, "Costume has an opaque background")
		for row in 6:
			var signatures := {}
			for column in 8:
				var tile: Image = image.get_region(Rect2i(column * 128, row * 128, 128, 128))
				require(tile.get_used_rect().has_area(), "Missing costume pose")
				signatures[hash(tile.get_data())] = true
				cells += 1
			require(signatures.size() == 8, "Repeated costume frames")
	require(cells == 288 and Skins.tint("restless").a < 1.0 and Skins.spectral("restless"), "Missing spectral presentation or authored cells")

func _persistence() -> void:
	var profile = Profile.new(prefix + "-account")
	var loadout = Loadout.new(prefix)
	require(loadout.equipped(0, profile) == "classic" and loadout.equipped(1, profile) == "classic", "Legacy accounts do not start with original costumes")
	require(loadout.equip(0, "restless", profile) == "locked" and loadout.equip(1, "royal_oath", profile) == "locked" and loadout.equip(0, "missing", profile) == "locked", "Unknown, wrong-race or locked costumes can be equipped")
	require(loadout.equip(0, "royal_oath", profile) == "saved", "Starting royal costume cannot be equipped")
	loadout = Loadout.new(prefix)
	require(loadout.equipped(0, profile) == "royal_oath" and profile.total_xp == 0 and profile.campaign_completed.is_empty(), "Cosmetic save changes account progress or fails to persist")
	profile.claim_campaign("dwarf_bells", 3, 60)
	require(Skins.available("restless", 0, Profile.new(prefix + "-account")), "A real persisted mission victory does not unlock its skin")
	require(loadout.equip(0, "restless", profile) == "saved", "Unlocked ancestor cannot be equipped")
	var file := FileAccess.open(prefix, FileAccess.WRITE)
	file.store_string("broken primary")
	file.close()
	loadout = Loadout.new(prefix)
	require(not loadout.load_failed and loadout.equipped(0, profile) == "royal_oath", "Damaged primary does not recover the last valid backup")
	require(loadout.equip(0, "restless", profile) == "saved" and Loadout.new(prefix).equipped(0, profile) == "restless", "Recovered save cannot be written without corrupting the backup")
	var config := ConfigFile.new()
	config.set_value("wardrobe", "version", 1)
	config.set_value("wardrobe", "selected", {0: "unknown_old_skin", 1: "royal_oath", 2: "moonwake"})
	config.save(prefix + "-legacy")
	loadout = Loadout.new(prefix + "-legacy")
	require(loadout.equipped(0, profile) == "classic" and loadout.equipped(1, profile) == "classic" and loadout.equipped(2, profile) == "classic", "Invalid IDs/races or locked factions escape runtime validation")
	profile.total_xp = Profile.xp_for_level(10)
	require(loadout.equipped(2, profile) == "moonwake" and Skins.available("black_sun", 3, profile) and not Skins.available("forgotten", 3, profile), "Level and campaign requirements are not enforced together")
	var denied = Loadout.new("user://missing-skins-directory/wardrobe.cfg")
	require(denied.equip(0, "royal_oath", profile) == "save_failed" and denied.selected.is_empty(), "Failed wardrobe write is not rolled back")
	file = FileAccess.open(prefix + "-bad", FileAccess.WRITE)
	file.store_string("unreadable wardrobe")
	file.close()
	denied = Loadout.new(prefix + "-bad")
	require(denied.load_failed and denied.equip(0, "royal_oath", profile) == "save_failed" and FileAccess.get_file_as_string(prefix + "-bad") == "unreadable wardrobe", "Unreadable saves are silently overwritten")

func _simulation_isolation() -> void:
	var snapshots: Array = []
	for cosmetic in [false, true]:
		var battle = Game.new()
		battle.account = Profile.new(prefix + "-account")
		battle.wardrobe = Loadout.new(prefix)
		battle.wardrobe.selected = {0: "restless"} if cosmetic else {}
		battle.selected_race = 0
		battle.bot_race = 1
		battle.phase = "PREP"
		battle.gold = [2000, 2000]
		battle.rng.seed = 1701
		battle.prepare_strategy(0, "mixed")
		battle._bot_prepare()
		battle.phase = "ATTACK"
		battle.launch_wave()
		for _step in 500:
			# Exercise presentation resolution during the actual combat simulation.
			for unit in battle.units:
				var old: Dictionary = unit.duplicate(true)
				battle._actor_appearance(unit)
				require(unit == old, "Appearance resolver mutates live combat data")
			battle._simulate(0.05)
		var state: Array = [battle.gold, battle.units, battle.guards, battle.traps, battle.orders, battle.rng.state, battle.campaign_delivered]
		snapshots.append(var_to_bytes(state))
		battle.free()
	require(snapshots[0] == snapshots[1], "Cosmetics change combat, wallet, orders or random-number sequence")

func _settle() -> void:
	for _frame in 8: await process_frame

func _player_journey() -> void:
	root.size = Vector2i(720, 1440)
	game = load("res://main.tscn").instantiate()
	game.account = Profile.new(prefix + "-ui-account")
	game.wardrobe = Loadout.new(prefix + "-ui")
	game.presentation.language = "pl"
	root.add_child(game)
	for child in game.get_children():
		if child is Timer: child.stop()
	await _settle()
	var gold_before: Array = game.gold.duplicate()
	game.main_menu_overlay.find_child("OpenWardrobe", true, false).pressed.emit()
	await _settle()
	require(is_instance_valid(game.wardrobe_overlay) and not game.main_menu_overlay.visible, "Costume action does not open an isolated wardrobe")
	var panel = game.wardrobe_overlay
	panel.find_child("Skin_restless", true, false).pressed.emit()
	require(panel.preview.skin == "restless" and panel.equip_button.disabled and panel.requirement.text.contains("Dzwony"), "Locked costume cannot be inspected or its reward is unexplained")
	panel.find_child("Skin_royal_oath", true, false).pressed.emit()
	panel.equip_button.pressed.emit()
	require(game.wardrobe.equipped(0, game.account) == "royal_oath" and Loadout.new(prefix + "-ui").equipped(0, game.account) == "royal_oath", "Equip action does not persist the selected costume")
	for dimensions in [Vector2i(540, 960), Vector2i(720, 1440), Vector2i(1280, 720)]:
		root.size = dimensions
		game.size = Vector2(dimensions)
		await _settle()
		require(panel.body.vertical == (dimensions.x < dimensions.y * 1.15), "Wardrobe does not adapt to orientation")
		for target in [panel.preview, panel.equip_button, panel.find_child("CloseWardrobe", true, false)]:
			require(target.get_global_rect().position.x >= -0.1 and target.get_global_rect().end.x <= dimensions.x + 0.1, "Wardrobe controls overflow the phone width")
		var roles: OptionButton = panel.find_child("SkinRole", true, false)
		for role in 4:
			roles.select(role)
			roles.item_selected.emit(role)
			require(panel.preview.atlas == game._skin_atlas(game._character_key_for_race(0, mini(role, 2), role == 3), "royal_oath"), "A costume role preview switches back to original art")
		for pose in 6:
			panel.preview.set_action(pose)
			var observed := {}
			for frame in 8:
				panel.preview.elapsed = float(frame) / (5.0 if pose == 0 else 10.0) + 0.001
				panel.preview._update_pose()
				observed[panel.preview.frame] = true
			require(observed.size() == 8, "Costume preview skips authored poses")
	panel._reverse()
	require(panel.preview.facing == -1.0, "Costume direction control does not mirror all roles")
	game._change_language("en")
	await _settle()
	require(panel.find_child("CloseWardrobe", true, false).text == "BACK" and panel.title.text == "Royal Oath", "Wardrobe language switch loses selection or leaves untranslated controls")
	panel._select_race(2)
	require(panel.equip_button.disabled and panel.requirement.text.contains("5"), "Locked elf wardrobe can bypass account progression")
	game._navigate_back()
	await _settle()
	require(game.wardrobe_overlay == null and game.main_menu_overlay.visible and game.gold == gold_before and game.phase == "SELECT", "Back/equipping changes battle state or fails to restore home")
	game._show_codex("runner")
	await _settle()
	var codex = game.codex_overlay
	var guide_art: TextureRect = codex.find_child("EntryIllustration", true, false)
	require(codex.live_preview.skin == "royal_oath" and guide_art.texture == game._unit_card_texture(0, 0) and guide_art.modulate == game._unit_card_tint(0, 0), "Guide uses different costumes from battle and purchase cards")
	game._close_codex()
	game._open_animation_gallery()
	await _settle()
	var studio = game.get_node("AnimationStudio")
	studio._select_faction_preview(0)
	require(studio._skin() == "royal_oath" and studio._action_count() == 7, "Animation Studio reuses incompatible special clips with the selected costume")
	studio._change_unit(3)
	require(studio._skin() == "royal_oath" and not Skins.path(studio._skin(), "arcane_mage").is_empty(), "Royal runekeeper is missing from Animation Studio")
	studio._close()
	await _settle()
	game._start_campaign(0)
	await _settle()
	game._close_campaign_overlay()
	require(game._card_skin(0) == "royal_oath" and game._actor_appearance({"side": 1, "kind": 0}) == {"key": "dwarf_defender", "skin": "restless"}, "Opening campaign lacks its living/undead distinction")
	game._spawn(1, 0, 0, 0.5)
	var enemy: Dictionary = game.units.back()
	game._record_fallen(enemy)
	require(game.fallen_actors.back()["appearance"]["skin"] == "restless", "Death animation loses the campaign outfit")
	game.units.clear()
	game._spawn(0, 1, 1, 0.001)
	game.units.back()["returning"] = true
	game.units.back()["carried"] = 12
	game.phase = "ATTACK"
	game._simulate(0.05)
	require(not game.deposit_actors.is_empty() and game.deposit_actors.back()["appearance"]["skin"] == "royal_oath", "Gold deposit switches back to the original costume")
	game.account_finished_waves = 3
	game.account_battle_seconds = 60
	game._finish_campaign(true)
	await _settle()
	require(Skins.available("restless", 0, Profile.new(prefix + "-ui-account")) and "NEW COSTUME:" in "\n".join(game.campaign_overlay.pages_text), "First victory does not unlock and announce the actual cosmetic reward")
	var xp: int = game.account.total_xp
	game._close_campaign_overlay()
	game.phase = "PREP"
	game._finish_campaign(true)
	await _settle()
	require(game.account.total_xp == xp and not "NEW COSTUME:" in "\n".join(game.campaign_overlay.pages_text), "Replay repeats cosmetic award or XP")
	game._close_campaign_overlay()
	game.campaign_index = 6
	game.bot_race = 3
	var echo := {"side": 1, "kind": 0, "lane": 1, "position": 0.5, "campaign_boss": true}
	require(game._actor_appearance(echo) == {"key": "dwarf_defender", "skin": "restless"} and game.side_race(1) == 3, "Oath Echo appearance changes its combat race or lacks Thorgar's shape")
	game._record_fallen(echo)
	require(game.fallen_actors.back()["appearance"]["key"] == "dwarf_defender", "Echo changes race when falling")
	game.campaign_index = 8
	game.selected_race = 1
	require(game._actor_appearance({"side": 0, "kind": 0})["skin"] == "threadkeepers" and game._actor_appearance({"side": 0, "kind": 0, "campaign_rebirth_wave": 1})["skin"] == "threadbare", "Goblin resurrection is not visible in the costume")
	game.campaign_state = game.CampaignRuntime.new(8, Story.MISSIONS[8], {})
	game.guards.clear()
	game.units.clear()
	game.phase = "PREP"
	game.purchase_guard(0, 1)
	game.guards.back()["campaign_rebirth_wave"] = game.wave
	game.guards.back()["health"] = 0.0
	game._guard_combat(0.05)
	require(game.guards.is_empty() and game.fallen_actors.back()["appearance"]["skin"] == "threadbare", "A revenant defender loses its worn costume on its final fall")
	game.campaign_index = -1
	game.selected_race = 0
	game.wardrobe.selected[0] = "restless"
	game._refresh()
	var card = game.controls[3].get_node("LocalizedSurface")
	require(card.illustration.texture == game._unit_card_texture(0, 0) and card.art_tint == Skins.tint("restless", "dwarf_defender"), "Battle card ignores selected costume or tint")
	game.tutorial_mode = true
	require(game._card_skin(0) == "classic" and game._actor_appearance({"side": 0, "kind": 0})["skin"] == "classic", "Wardrobe changes the teaching fixture")
	game.queue_free()
	await process_frame
