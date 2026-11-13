extends SceneTree
const Account = preload("res://scripts/account_progress.gd")
const RewardPanel = preload("res://scripts/account_progress_panel.gd")
const PATH := "user://qa-reward-presentation.cfg"
var game

func _initialize() -> void:
	call_deferred("_run")

func require(value: bool, reason: String) -> bool:
	if not value:
		push_error(reason)
		quit(1)
	return value

func resize_game(dimensions: Vector2i) -> void:
	root.size = dimensions
	game.size = Vector2(dimensions)
	for _frame in 4:
		await process_frame

func _run() -> void:
	for suffix in ["", ".bak", ".pending"]:
		if FileAccess.file_exists(PATH + suffix):
			DirAccess.remove_absolute(PATH + suffix)
	root.size = Vector2i(720, 1280)
	game = load("res://main.tscn").instantiate()
	game.account = Account.new(PATH)
	game.account.total_xp = Account.xp_for_level(20)
	game.presentation.language = "pl"
	game.presentation.reduced_motion = false
	root.add_child(game)
	for child in game.get_children():
		if child is Timer:
			child.stop()
	game._choose_faction(1)
	for dimensions in [Vector2i(540, 960), Vector2i(720, 1440), Vector2i(720, 1560), Vector2i(1280, 720)]:
		await resize_game(dimensions)
		for race in 4:
			game._choose_faction(race)
			for index in range(3, 9):
				var surface = game.controls[index].get_node("LocalizedSurface")
				if not require(surface.illustration.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED and surface.illustration.size.x <= 190.1 and surface.illustration.size.y <= 126.1, "Battle illustration is cropped or grows with a tall phone"):
					return
				if not require(surface.illustration.get_rect().end.y <= surface.caption.position.y + 1 and not surface.cost.text.is_empty(), "Compact art covers a card caption or price"):
					return
			var banner = game.guard_button.get_node("LocalizedSurface")
			if not require(banner.illustration.get_rect().end.x < banner.caption.position.x and banner.illustration.size.x <= 164.1, "Banner thumbnail overlaps its label"):
				return
			for card in [game.guard_button, game.ability_button]:
				var crop := card.get_node("LocalizedSurface").illustration.texture as AtlasTexture
				if crop.atlas.get_width() <= crop.atlas.get_height() * 2:
					if not require(crop.region.size.x >= crop.atlas.get_width() * 0.9, "Portrait banner is cropped as if it were a wide source strip"):
						return
	await resize_game(Vector2i(720, 1280))
	game._choose_faction(0)
	game.account.total_xp = 680
	game._begin_attack()
	game.account_battle_seconds = 1
	game.gold[1] = 0
	game._check_vaults()
	for _frame in 5:
		await process_frame
	var badge = game.result_overlay.find_child("OutcomeAccountProgress", true, false)
	if not require(badge != null and not badge.visual_done and badge.displayed_xp == 680 and game.account.total_xp == 750, "Reward presentation does not start at old XP with the final award already saved"):
		return
	var disk_before: String = FileAccess.get_file_as_string(PATH)
	var gold_before: Array = game.gold.duplicate()
	var flight = badge.flight
	flight.set_process(false)
	badge.hide()
	var elapsed: float = flight.elapsed
	flight.advance(1)
	if not require(is_equal_approx(flight.elapsed, elapsed), "Hidden reward keeps consuming its flight animation"):
		return
	badge.show()
	flight.advance(flight.delay + flight.DURATION * 0.60 - flight.elapsed)
	if not require(badge.displayed_xp > 680 and badge.displayed_xp < 700 and badge.bar.max_value == 250, "XP begins counting before arrival or uses the wrong pre-level range"):
		return
	flight.advance(flight.DURATION * 0.20)
	if not require(badge.displayed_xp >= 700 and badge.level_number.text == "5" and badge.bar.max_value == 300 and badge.find_child("UnlockedRace2", true, false).visible, "Level-up range and unlock are not synchronized with arriving gold"):
		return
	game._stage_reward_visual_for_menu()
	if not require(has_meta(game.PENDING_REWARD_META), "Leaving an unfinished reward drops the menu handoff"):
		return
	var pending: Dictionary = get_meta(game.PENDING_REWARD_META).duplicate(true)
	if not require(pending["before_xp"] == badge.displayed_xp and pending["gained"] == 750 - badge.displayed_xp, "Menu handoff rewinds experience that already arrived"):
		return
	remove_meta(game.PENDING_REWARD_META)
	flight.advance(3)
	if not require(badge.visual_done and badge.displayed_xp == 750 and badge.bar.value == 50 and game.gold == gold_before and FileAccess.get_file_as_string(PATH) == disk_before, "Coin flight changes saved XP/gold or fails to finish at the exact award"):
		return
	game._stage_reward_visual_for_menu()
	if not require(not has_meta(game.PENDING_REWARD_META), "A completed reward is replayed in the next menu"):
		return
	# A real scene replacement consumes only the unfinished visual, never XP again.
	game.queue_free()
	await process_frame
	set_meta("vault_wars_pending_reward_visual", pending)
	game = load("res://main.tscn").instantiate()
	game.account = Account.new(PATH)
	game.presentation.reduced_motion = false
	root.add_child(game)
	for _frame in 5:
		await process_frame
	var home = game.main_menu_overlay.account_badge
	if not require(not home.visual_done and home.flight != null and not has_meta(game.PENDING_REWARD_META) and game.account.total_xp == 750, "Menu cannot resume unfinished reward without awarding it twice"):
		return
	home.flight.set_process(false)
	await resize_game(Vector2i(1280, 720))
	home.flight.advance(0.5)
	if not require(home.flight.target_visible(), "Flight target leaves the screen after rotating"):
		return
	home.flight.advance(4)
	if not require(home.visual_done and game.pending_account_reward.is_empty() and game.account.total_xp == 750 and FileAccess.get_file_as_string(PATH) == disk_before, "Menu handoff mutates progression or leaves a repeatable reward"):
		return
	# Reduced motion and failed/duplicate/no-award results must not create particles.
	var reduced := RewardPanel.new()
	reduced.profile = game.account
	reduced.reward = pending
	reduced.allow_motion = false
	root.add_child(reduced)
	for _frame in 2:
		await process_frame
	if not require(reduced.visual_done and reduced.flight == null and reduced.displayed_xp == 750, "Reduced motion leaves an unfinished reward"):
		return
	reduced.queue_free()
	for status in ["save_failed", "already_claimed", "ineligible"]:
		var static_panel := RewardPanel.new()
		static_panel.profile = game.account
		static_panel.reward = {"status": status, "gained": 0}
		root.add_child(static_panel)
		if not require(static_panel.visual_done and static_panel.flight == null, "An unearned reward creates flying gold"):
			return
		static_panel.queue_free()
	# Backup codes are deliberately local and must never reduce existing XP.
	if not require(Account.recovery_code_for_xp(225) == "VW1-225-EE853895", "Recovery code differs from the independently checked screenshot total"):
		return
	if not require(game.account.restore_recovery_code("VW1-225-EE853895") == "unchanged" and game.account.total_xp == 750, "An older backup lowers account progress"):
		return
	if not require(game.account.restore_recovery_code("VW1-225-00000000") == "invalid" and game.account.total_xp == 750, "Bad recovery checksum changes progress"):
		return
	game._show_settings()
	game.settings_overlay.find_child("RestoreAccountCode", true, false).text = Account.recovery_code_for_xp(2700)
	game.settings_overlay.find_child("RestoreAccountProgress", true, false).pressed.emit()
	var restored = Account.new(PATH)
	if not require(restored.total_xp == 2700 and restored.level() == 10 and game.settings_overlay.find_child("AccountRecoveryCode", true, false).text == restored.recovery_code(), "Settings recovery does not persist XP and unlocks"):
		return
	game.queue_free()
	await process_frame
	for suffix in ["", ".bak", ".pending"]:
		if FileAccess.file_exists(PATH + suffix):
			DirAccess.remove_absolute(PATH + suffix)
	print("Reward presentation PASSED: compact art in four sizes/factions, gold arrivals, level crossing, exact saved XP, no double award, menu handoff, rotation and reduced motion")
	quit(0)
