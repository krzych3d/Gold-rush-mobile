extends SceneTree
## Full gameplay contract: epic start menu, tutorial, upgrades, navigation,
## victory/defeat presentation and original orchestral audio.

func _initialize() -> void:
	call_deferred("_run")

func _fail(reason: String) -> void:
	push_error(reason)
	quit(1)

func _run() -> void:
	var scene := load("res://main.tscn") as PackedScene
	if scene == null:
		_fail("Cannot load Vault Wars")
		return
	var game = scene.instantiate()
	game.presentation.language = "en"
	root.add_child(game)
	game.size = Vector2(720, 1280)
	await process_frame
	await process_frame
	if game.main_menu_overlay == null or game.main_menu_overlay.find_child("StartGame", true, false) == null:
		_fail("Illustrated MAIN MENU / Start Game not visible at launch")
		return
	game.main_menu_overlay.find_child("OpenCodex", true, false).pressed.emit()
	var help: Button = game.codex_overlay.find_child("HowToPlay", true, false) as Button
	if help == null:
		_fail("Game guide lacks how-to button")
		return
	help.pressed.emit()
	if game.help_overlay == null or game.help_overlay.find_child("BeginFromHowTo", true, false) == null:
		_fail("How-to-play rules screen missing")
		return
	var back: Button = game.help_overlay.find_child("BackToMainMenu", true, false) as Button
	back.pressed.emit()
	if game.help_overlay != null:
		_fail("Cannot return from rules to main menu")
		return
	var start: Button = game.main_menu_overlay.find_child("StartGame", true, false) as Button
	start.pressed.emit()
	if game.selection_layer == null or game.selection_layer.find_child("ConfirmFaction", true, false) == null:
		_fail("START GAME does not show race selection")
		return
	game._choose_faction(0)
	if game.phase != "PREP" or game.main_menu_overlay != null:
		_fail("Selecting dwarves did not enter preparation phase")
		return
	for tier in 5:
		if game.VAULT_TIER_ART[tier] == null:
			_fail("Missing vault tier %d artwork" % (tier + 1))
			return
		game.gold[0] = 2500
		game._upgrade_bank()
		if game.bank_level != tier + 1:
			_fail("BANK upgrade failed to change the vault visual tier")
			return
		var dynamic_price: Label = game.invest_button.get_node_or_null("OriginalDynamicText") as Label
		if dynamic_price != null and not dynamic_price.text.contains("LV%d" % game.bank_level):
			_fail("Bank artwork retained outdated LV0 text after upgrade")
			return
	if game.invest_button.get_node_or_null("DynamicPriceMask") == null:
		_fail("Legacy bank price artwork still has overlapping baked labels")
		return
	game.main_menu_button.pressed.emit()
	if game.menu_confirmation == null:
		_fail("Menu button did not display match-exit confirmation")
		return
	var stay: Button = game.menu_confirmation.find_child("StayInBattle", true, false) as Button
	stay.pressed.emit()
	if game.menu_confirmation != null or game.phase != "PREP":
		_fail("Canceling exit unexpectedly ends the match")
		return
	game._begin_attack()
	game.gold[1] = 0
	if not game._check_vaults():
		_fail("Enemy vault zero failed to end the match")
		return
	await process_frame
	await process_frame
	if game.result_overlay == null:
		_fail("Victory did not show a cinematic end screen")
		return
	var headline: Label = game.result_overlay.find_child("OutcomeHeadline", true, false) as Label
	if headline == null or headline.text != "VICTORY":
		_fail("Victory cinematic shows the wrong headline")
		return
	if game.result_overlay.find_child("CinematicResultScore", true, false) == null:
		_fail("Victory has no original victory music player")
		return
	if game.result_overlay.find_child("PlayAgain", true, false) == null or game.result_overlay.find_child("MainMenu", true, false) == null:
		_fail("Result must allow replay AND returning to main menu")
		return
	print("Cinematic UI smoke PASSED: main menu, rules, 5 vault tiers, match exit, victory, music")
	game.queue_free()
	quit(0)
