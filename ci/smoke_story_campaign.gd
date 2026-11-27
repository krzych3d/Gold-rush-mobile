extends SceneTree
const Game = preload("res://scripts/game.gd")
const Story = preload("res://scripts/story_campaign.gd")
const Runtime = preload("res://scripts/campaign_runtime.gd")
const Profile = preload("res://scripts/account_progress.gd")
var failures: Array[String] = []
var save_path := "user://qa-story-" + Crypto.new().generate_random_bytes(6).hex_encode() + ".cfg"

func require(value: bool, reason: String) -> void:
	if not value:
		failures.append(reason)
		push_error(reason)

func fixture(chapter: int):
	var game = Game.new()
	game.account = Profile.new(save_path)
	game.campaign_index = chapter
	game.campaign_state = Runtime.new(chapter, Story.MISSIONS[chapter])
	game.selected_race = 0
	game.bot_race = int(Story.MISSIONS[chapter]["enemy"])
	game.phase = "PREP"
	game.gold = [1800, 950]
	game.account_match_id = "qa-story-test"
	return game

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	_test_persistence()
	_test_rules()
	_test_choices()
	await _test_ui()
	await _test_reading_flow()
	for suffix in ["", ".bak", ".pending"]:
		DirAccess.remove_absolute(save_path + suffix)
	if failures.is_empty():
		print("Story campaign PASSED: seven chapters, save migration/rollback, immutable decisions, best stars, debt, persistent phased bosses, escort, collapse, all PL/EN story pages, speaker/context captions, previous navigation, gated choices, saved siege recap, pause and rotation")
	quit(0 if failures.is_empty() else 1)

func _test_persistence() -> void:
	var config := ConfigFile.new()
	config.set_value("account", "version", 1)
	config.set_value("account", "total_xp", 0)
	config.set_value("account", "claimed_matches", PackedStringArray())
	config.save(save_path)
	var account = Profile.new(save_path)
	require(not account.load_failed and account.campaign_stars.is_empty() and account.campaign_choices.is_empty(), "Old saves do not migrate")
	var ids: Dictionary = {}
	for i in Story.MISSIONS.size():
		var data: Dictionary = Story.MISSIONS[i]
		require(not ids.has(data["id"]), "Duplicate campaign ID")
		ids[data["id"]] = true
		require(Story.unlocked(account, i) == (i == 0), "A prerequisite can be bypassed on a new account")
		for field in ["title", "objective", "setting", "recap", "briefing", "intro", "mid", "outro"]:
			require(data[field].size() == 2 and not str(data[field][0]).is_empty() and not str(data[field][1]).is_empty(), "Missing PL/EN campaign text")
	account.claim_campaign("dwarf_bells", 3, 60.0, 1)
	var xp: int = account.total_xp
	var replay: Dictionary = account.claim_campaign("dwarf_bells", 3, 60.0, 3)
	require(replay["gained"] == 0 and account.total_xp == xp and account.campaign_stars["dwarf_bells"] == 3, "Replay does not preserve XP/best stars")
	account.claim_campaign("dwarf_sons", 3, 60.0, 2, "dwarf_refugees", "open")
	account.claim_campaign("dwarf_sons", 3, 60.0, 1, "dwarf_refugees", "hidden")
	account = Profile.new(save_path)
	require(account.campaign_stars["dwarf_bells"] == 3 and account.campaign_stars["dwarf_sons"] == 2 and account.campaign_choices["dwarf_refugees"] == "open", "Stars or canonical decisions are lost or overwritten")
	var blocked = Profile.new("user://missing-campaign-directory/progress.cfg")
	var denied: Dictionary = blocked.claim_campaign("dwarf_oath", 4, 90.0, 3, "dwarf_oath", "release")
	require(denied["status"] == "save_failed" and blocked.campaign_stars.is_empty() and blocked.campaign_choices.is_empty() and blocked.campaign_completed.is_empty() and blocked.total_xp == 0, "Failed save does not roll back all campaign fields atomically")
	var open = Runtime.new(5, Story.MISSIONS[5], {"dwarf_refugees": "open"})
	var hidden = Runtime.new(5, Story.MISSIONS[5], {"dwarf_refugees": "hidden"})
	require(open.boss_max == 580 and hidden.boss_max == 440, "Refugee choice has no real siege consequence")

func _test_rules() -> void:
	var game = fixture(2)
	require(game.purchase_training(0) and game.campaign_state.spent == 120, "Training spending omitted from debt")
	game.purchase_unit(1, 0, 0)
	require(game.campaign_state.spent == 120, "Enemy spending increases player debt")
	game._spawn(1, 0, 0, 0)
	require(is_equal_approx(float(game.units[0]["max_health"]), float(game.raider_stats(0, 0, false, 0)["health"]) * 1.08), "Debt does not scale actual spawned enemy health")
	game.campaign_state.record_spending(100000)
	require(is_equal_approx(game.campaign_state.enemy_multiplier(), 1.8), "Debt difficulty is uncapped")
	var spent: int = game.campaign_state.spent
	game.gold[0] = 10
	game.purchase_trap(0, 0, 2)
	require(game.campaign_state.spent == spent, "Rejected purchases increase debt")
	game.free()
	game = fixture(3)
	game.purchase_trap(0, 0, 2)
	game.phase = "ATTACK"
	game.launch_wave()
	var boss: Dictionary = {}
	for unit in game.units:
		if unit.get("campaign_boss", false): boss = unit
	boss["health"] = 200.0
	game._simulate(0.05)
	require(game.campaign_state.boss_enraged and is_equal_approx(float(boss["speed"]), 0.027), "Boss second phase does not change actual movement")
	game._end_wave()
	require(game.campaign_state.boss_health == 200, "Boss wounds reset between waves")
	game.phase = "ATTACK"
	game.launch_wave()
	for unit in game.units:
		if unit.get("campaign_boss", false):
			require(unit["health"] == 200, "Relaunched boss heals")
			unit["health"] = 1.0
			unit["lane"] = 0
			unit["position"] = 0.5
	game._simulate(0.05)
	require(game.campaign_state.boss_defeated, "Real turret kill does not complete boss objective")
	game.free()
	game = fixture(4)
	game.phase = "ATTACK"
	game._spawn(0, 0, 1, 0.0001)
	game.units[0]["returning"] = true
	game.units[0]["campaign_refugee"] = true
	var before: int = game.gold[0]
	game._simulate(0.05)
	require(game.campaign_state.rescued == 1 and game.campaign_delivered == 0 and game.gold[0] == before, "Escort arrival is lost or creates fake memory gold")
	game.campaign_state.rescued = 0
	require(game.campaign_state.impossible(2), "Unwinnable escort cannot fail before wasting all waves")
	game.free()
	game = fixture(6)
	game.wave = 2
	game.phase = "ATTACK"
	for side in 2: game._spawn(side, 0, -1, 0.2)
	var hp_a: float = game.units[0]["health"]
	var hp_b: float = game.units[1]["health"]
	game._simulate(0.05)
	require(is_equal_approx(hp_a - float(game.units[0]["health"]), 0.25) and is_equal_approx(hp_b - float(game.units[1]["health"]), 0.25), "Collapse is decorative or asymmetric")
	game.campaign_index = -1
	hp_a = game.units[0]["health"]
	game._simulate(0.05)
	require(is_equal_approx(hp_a, float(game.units[0]["health"])), "Campaign damage leaks into ordinary matches")
	game.free()

func _test_choices() -> void:
	var path: String = save_path + "-decision"
	var game = fixture(4)
	game.account = Profile.new(path)
	game.account_finished_waves = 3
	game.account_battle_seconds = 65.0
	game._finish_campaign(true)
	require(game.campaign_choice_pending and not game.account.campaign_completed.has("dwarf_sons") and game.account.total_xp == 0, "Decision chapter saves victory before the choice")
	game._navigate_back()
	require(is_instance_valid(game.campaign_overlay) and game.campaign_choice_pending, "Android Back bypasses a mandatory story choice")
	game._choose_campaign_ending("invalid")
	require(game.campaign_choice_pending, "Invalid choice mutates canonical history")
	game._choose_campaign_ending("open")
	require(not game.campaign_choice_pending and game.account.campaign_completed.has("dwarf_sons") and game.account.campaign_choices.get("dwarf_refugees", "") == "open" and game.account.total_xp > 0, "Choice does not atomically complete and reward its chapter")
	var xp: int = game.account.total_xp
	game.free()
	var restored = Profile.new(path)
	require(restored.campaign_choices.get("dwarf_refugees", "") == "open" and restored.total_xp == xp, "Decision and victory do not survive a restart")
	for suffix in ["", ".bak", ".pending"]:
		DirAccess.remove_absolute(path + suffix)

func _test_ui() -> void:
	for language in ["pl", "en"]:
		var game = load("res://main.tscn").instantiate()
		game.account = Profile.new(save_path)
		game.presentation.language = language
		root.size = Vector2i(720, 1280)
		root.add_child(game)
		await process_frame
		game._open_campaign()
		await process_frame
		require(game.campaign_overlay.find_children("CampaignMission*", "Button", true, false).size() == 7, "Chronicle lacks seven real chapter actions")
		game._start_campaign(0)
		await process_frame
		var panel = game.campaign_overlay
		var time_before: float = game.remaining
		game._tick()
		require(game.remaining == time_before, "Dialogues consume battle time")
		for dimensions in [Vector2i(540, 960), Vector2i(720, 1280), Vector2i(1280, 720), Vector2i(1560, 720), Vector2i(720, 1280)]:
			root.size = dimensions
			game.size = Vector2(dimensions)
			for _frame in 4: await process_frame
			var next: Button = panel.find_child("StoryAdvance", true, false)
			var scroll: ScrollContainer = panel.find_child("DialogueScroll", true, false)
			require(next.get_global_rect().end.y <= dimensions.y + 1 and next.size.y >= 48 and scroll.size.y >= 70, "Dialogue text or advance action clips after rotation " + str(dimensions))
			require(panel.portrait_scene.size.y >= 100 and panel.portrait_scene.portrait.size.x / panel.portrait_scene.portrait.size.y < 0.76, "Portrait face is cropped by a wide viewport")
		var last: int = panel.pages_text.size() - 1
		for _step in last:
			panel.advance.pressed.emit()
		require(panel.page == last and is_instance_valid(game.campaign_overlay), "Pagination skips or closes the last readable page")
		panel.advance.pressed.emit()
		require(game.campaign_overlay == null and game.phase == "PREP", "Last dialogue page cannot enter battle")
		game._refresh()
		await process_frame
		require(game.battle_shell.campaign_objective.visible and not game.battle_shell.campaign_objective.text.is_empty(), "Campaign objective missing from dedicated battle HUD")
		var saved_gold: Array = game.gold.duplicate()
		for dimensions in [Vector2i(540, 960), Vector2i(1280, 720)]:
			root.size = dimensions
			game.size = Vector2(dimensions)
			for _frame in 4: await process_frame
			require(game.battle_shell.header.get_global_rect().end.y <= game.battlefield_frame.get_global_rect().position.y + 1, "Campaign HUD overlaps the map")
			require(game.gold == saved_gold, "Orientation changes campaign resources")
		game.queue_free()
		await process_frame

func _test_reading_flow() -> void:
	# Read every actual chapter in both languages. Choices must wait for their
	# context, and paging/rotation may never advance time or alter battle state.
	for language in ["pl", "en"]:
		root.size = Vector2i(720, 1280)
		var game = load("res://main.tscn").instantiate()
		game.account = Profile.new(save_path)
		game.presentation.language = language
		game.presentation.reduced_motion = true
		root.add_child(game)
		for child in game.get_children():
			if child is Timer: child.stop()
		game._choose_faction(0)
		for chapter in Story.MISSIONS.size():
			game.campaign_index = chapter
			game.campaign_state = Runtime.new(chapter, Story.MISSIONS[chapter])
			var mission: Dictionary = Story.MISSIONS[chapter]
			for stage in ["intro", "mid", "result"]:
				game.campaign_choice_pending = stage == "result" and mission.has("decision")
				game._present_campaign(stage, true)
				var panel = game.campaign_overlay
				for _frame in 3: await process_frame
				var before_gold: Array = game.gold.duplicate()
				var before_time: float = game.remaining
				require(panel.find_child("StorySetting", true, false).text == Story.localized(mission["setting"]), "Dialogue lost its location/time context")
				if stage == "intro":
					require(panel.pages_text[0].contains(Story.localized(mission["recap"])), "Previous chapter recap is missing")
					require(panel.pages_text[-1].contains(Story.localized(mission["briefing"])) and panel.pages_text[-1].contains(Story.localized(mission["objective"])), "Final briefing omits the real objective or rule explanation")
				for page in panel.pages_text.size():
					require(panel.text_label.text == panel.pages_text[page] and not panel.speaker_label.text.is_empty(), "Story pages are lost, merged or lack speaker context")
					if game.campaign_choice_pending:
						for choice in mission["choices"]:
							var button: Button = panel.find_child("StoryChoice_" + str(choice["id"]), true, false)
							require(button.is_visible_in_tree() == (page == panel.pages_text.size() - 1), "Decision appears before its consequences have been read")
					if page + 1 < panel.pages_text.size(): panel.advance.pressed.emit()
				if panel.pages_text.size() > 1:
					panel.previous.pressed.emit()
					require(panel.page == panel.pages_text.size() - 2 and panel.text_label.text == panel.pages_text[panel.page], "Previous action cannot recover a story page")
					if game.campaign_choice_pending:
						require(not panel.choices_box.is_visible_in_tree(), "Previous page leaves a premature decision visible")
					panel.advance.pressed.emit()
				for dimensions in [Vector2i(540, 960), Vector2i(1280, 720), Vector2i(720, 1280)]:
					root.size = dimensions
					game.size = Vector2(dimensions)
					for _frame in 4: await process_frame
					var scroll: ScrollContainer = panel.find_child("DialogueScroll", true, false)
					var navigation: Control = panel.find_child("StoryNavigation", true, false)
					require(scroll.size.y >= 70 and Rect2(Vector2.ZERO, Vector2(dimensions)).grow(1).encloses(navigation.get_global_rect()), "Expanded dialogue or navigation clips after rotation " + str(dimensions))
				game._tick()
				require(game.remaining == before_time and game.gold == before_gold, "Reading, paging or rotating a scene changes battle state")
				game._close_campaign_overlay()
		# The actual saved refugee choice is restated when its consequence starts.
		game.campaign_index = 5
		for choice in ["open", "hidden"]:
			game.account.campaign_choices["dwarf_refugees"] = choice
			game._present_campaign("intro")
			var text: String = game.campaign_overlay.pages_text[0]
			require(text.contains("Otworzyłeś" if language == "pl" else "You opened") if choice == "open" else text.contains("Ukryłeś" if language == "pl" else "You hid"), "Siege recap omits the player's actual saved decision")
			game._close_campaign_overlay()
		game.queue_free()
		await process_frame
