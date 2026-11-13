extends SceneTree
const Account = preload("res://scripts/account_progress.gd")
const RejectSave = preload("res://ci/fixtures/reject_account_save.gd")
const PATH := "user://qa-account-progress.cfg"
var game

func _initialize() -> void:
	call_deferred("_run")

func require(value: bool, reason: String) -> bool:
	if not value:
		push_error(reason)
		quit(1)
	return value

func clean(path: String) -> void:
	for suffix in ["", ".bak", ".pending"]:
		if FileAccess.file_exists(path + suffix):
			DirAccess.remove_absolute(path + suffix)

func _run() -> void:
	clean(PATH)
	var profile = Account.new(PATH)
	if not require(profile.level() == 1 and profile.race_unlocked(0) and profile.race_unlocked(1) and not profile.race_unlocked(2) and not profile.race_unlocked(3) and not profile.race_unlocked(-1), "New account has wrong faction access"):
		return
	for target in range(2, 21):
		profile.total_xp = Account.xp_for_level(target) - 1
		if not require(profile.level() == target - 1, "Level advances before threshold " + str(target)):
			return
		profile.total_xp += 1
		if not require(profile.level() == target, "Exact level threshold not recognized " + str(target)):
			return
	if not require(Account.xp_for_level(5) == 700 and Account.xp_for_level(10) == 2700 and Account.xp_for_level(20) == 10450, "Progression curve changed unexpectedly"):
		return
	profile.total_xp = 0
	for seconds in [0.0, -1.0]:
		profile.claim_match("short", true, 1, seconds)
	profile.claim_match("no-waves", true, 0, 60)
	if not require(profile.total_xp == 0 and profile.claimed_matches.is_empty(), "Preparation or short/empty match awarded XP"):
		return
	# A fast legitimate victory/loss is still a finished game. Do not impose
	# an arbitrary duration that removes its reward after a quick vault raid.
	clean(PATH + ".fast")
	var fast = Account.new(PATH + ".fast")
	var quick_win: Dictionary = fast.claim_match("fast-win", true, 1, 2.0)
	var quick_loss: Dictionary = fast.claim_match("fast-loss", false, 1, 1.0)
	if not require(quick_win["gained"] == 70 and quick_loss["gained"] == 45, "Fast completed matches lose their XP reward"):
		return
	clean(PATH + ".fast")
	var first: Dictionary = profile.claim_match("first-win", true, 3, 60)
	if not require(first["gained"] == 110 and profile.level() == 2 and first["status"] == "saved", "Win and completed waves give wrong reward"):
		return
	profile.claim_match("first-win", true, 3, 60)
	var loaded = Account.new(PATH)
	loaded.claim_match("first-win", true, 3, 60)
	if not require(loaded.total_xp == 110, "Same match can be claimed twice or save did not survive restart"):
		return
	var loss: Dictionary = loaded.claim_match("first-loss", false, 2, 40)
	if not require(loss["gained"] == 65 and loaded.total_xp == 175, "Loss does not reward completed play correctly"):
		return
	# Primary validation fails; the previous complete snapshot must load.
	var invalid := ConfigFile.new()
	invalid.set_value("account", "version", 999)
	invalid.save(PATH)
	var recovered = Account.new(PATH)
	if not require(recovered.total_xp == 110 and not recovered.load_failed, "Backup did not recover previous valid progress"):
		return
	invalid.save(PATH + ".bak")
	var damaged = Account.new(PATH)
	var original: String = FileAccess.get_file_as_string(PATH)
	var rejected: Dictionary = damaged.claim_match("must-preserve", true, 4, 60)
	if not require(damaged.load_failed and rejected["status"] == "save_failed" and FileAccess.get_file_as_string(PATH) == original and damaged.total_xp == 0, "Unreadable saves were overwritten with a fresh level-one account"):
		return
	clean(PATH)
	var failed = RejectSave.new(PATH)
	failed.total_xp = 680
	var rollback: Dictionary = failed.claim_match("failed-write", true, 1, 20)
	if not require(rollback["status"] == "save_failed" and failed.total_xp == 680 and not failed.race_unlocked(2) and failed.claimed_matches.is_empty(), "Failed save granted an unsaved unlock or consumed the claim"):
		return
	profile = Account.new(PATH)
	profile.total_xp = 680
	var elves: Dictionary = profile.claim_match("elves", true, 1, 10)
	if not require(profile.level() == 5 and profile.race_unlocked(2) and not profile.race_unlocked(3) and elves["unlocked"] == [2], "Elf unlock is not exactly level five"):
		return
	profile.total_xp = 2680
	var voids: Dictionary = profile.claim_match("void", true, 1, 10)
	if not require(profile.level() == 10 and profile.race_unlocked(3) and voids["unlocked"] == [3], "Void unlock is not exactly level ten"):
		return
	profile.total_xp = 10440
	var cap: Dictionary = profile.claim_match("cap", true, 999, 1000)
	if not require(profile.level() == 20 and profile.total_xp == 10450 and profile.xp_needed() == 0 and cap["gained"] == 10 and cap["earned"] == 450, "Level or long-match XP cap failed"):
		return
	profile.claim_match("max-again", false, 1, 10)
	if not require(profile.level() == 20 and profile.total_xp == 10450, "XP at level 20 rolls over"):
		return
	clean(PATH)
	# Real UI and game callbacks must enforce the same unlocks as the model.
	root.size = Vector2i(720, 1280)
	game = load("res://main.tscn").instantiate()
	game.account = Account.new(PATH)
	game.presentation.language = "pl"
	game.presentation.reduced_motion = true
	root.add_child(game)
	for child in game.get_children():
		if child is Timer:
			child.stop()
	await process_frame
	await process_frame
	if not require(game.main_menu_overlay.find_child("AccountLevel", true, false).text == "POZIOM KONTA 1 / 20", "Home lacks real account level and XP bar"):
		return
	game._open_race_selection()
	for race in [2, 3]:
		game.selection_layer.select_race(race)
		var confirm: Button = game.selection_layer.find_child("ConfirmFaction", true, false)
		if not require(confirm.disabled and game.selected_race == 0 and game.selection_layer.focus_race == race, "Locked preview selects playable faction or enables confirm"):
			return
		confirm.pressed.emit()
		game._choose_faction(race)
		if not require(game.phase == "SELECT", "Direct/old confirmation callback bypasses race lock"):
			return
	game.selection_layer._inspect_race()
	if not require(game.codex_overlay.focus_race == 3 and game.selected_race == 0, "Cannot inspect a locked faction without changing gameplay selection"):
		return
	game._close_codex()
	game._change_language("en")
	if not require(game.selection_layer.focus_race == 3 and game.selection_layer.find_child("ConfirmFaction", true, false).disabled, "Language rebuild drops a locked preview or removes its lock"):
		return
	game._change_language("pl")
	game._choose_faction(0)
	game._change_race()
	game._change_race()
	if not require(game.selected_race == 0, "Legacy race cycling bypasses locks"):
		return
	game.account.total_xp = 680
	game._begin_attack()
	for _step in 220:
		game._simulate(0.05)
	if not require(game.account_battle_seconds >= 10 and game.phase == "ATTACK", "Actual battle clock failed participation tracking"):
		return
	game.gold[1] = 0
	game._check_vaults()
	for _repeat in 10:
		game._check_vaults()
	await process_frame
	await process_frame
	var end_account = Account.new(PATH)
	if not require(game.account_reward["gained"] == 70 and end_account.total_xp == 750 and end_account.level() == 5 and game.result_overlay.find_child("UnlockedRace2", true, false) != null, "Real match did not save exactly one reward and announce the new race"):
		return
	var stats_before: Dictionary = game.raider_stats(0, 0, false, 0)
	game.account.total_xp = Account.xp_for_level(20)
	if not require(game.raider_stats(0, 0, false, 0) == stats_before, "Account level changes unit combat stats"):
		return
	game.queue_free()
	await process_frame
	clean(PATH)
	print("Account progression PASSED: thresholds 1–20, normal/fast-match XP, duplicate prevention, persistent saves, backup/failed-save preservation, real race locks, previews and match-level unlock")
	quit(0)
