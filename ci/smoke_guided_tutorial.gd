extends SceneTree
const Lessons = preload("res://scripts/tutorial_lessons.gd")
const L10n = preload("res://scripts/localization.gd")
var game
var checks := 0
var visited := 0
var clicked := 0
const ACCOUNT := "user://qa-guided-tutorial-account.cfg"
const SETTINGS := "user://qa-guided-tutorial-settings.cfg"

func _initialize() -> void:
	call_deferred("run")

func require(ok: bool, reason: String) -> bool:
	checks += 1
	if not ok:
		push_error(reason)
		quit(1)
	return ok

func frames(count: int = 3) -> void:
	for _index in count:
		await process_frame

func tap(control: Control) -> void:
	var point: Vector2 = control.get_global_rect().get_center()
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.position = point
	press.pressed = true
	root.push_input(press, true)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.position = point
	release.pressed = false
	root.push_input(release, true)
	await frames()

func english(text: String) -> bool:
	for letter in "ąćęłńóśźżĄĆĘŁŃÓŚŹŻ":
		if text.contains(letter):
			return false
	return true

func run() -> void:
	root.size = Vector2i(720, 1280)
	game = load("res://main.tscn").instantiate()
	game.account = game.AccountProgress.new(ACCOUNT)
	game.presentation = game.MobileSettings.new(SETTINGS)
	game.presentation.language = "pl"
	root.add_child(game)
	await frames()
	if not require(game.main_menu_overlay.find_child("OpenTutorial", true, false) != null, "Main menu has no tutorial entry"):
		return
	game._show_how_to_play()
	if not require(game.help_overlay.find_children("TutorialChapter*", "Button", true, false).size() == 15, "Hub does not expose every item and all four faction lessons"):
		return
	game.help_overlay.find_child("BeginFromHowTo", true, false).pressed.emit()
	await frames()
	var coach = game.tutorial_session
	coach.set_process(false) # Feed the real simulator fixed steps without wall-clock waiting.
	var board = coach.sandbox
	if not require(board != game and board.tutorial_mode and board.account_match_id.is_empty() and board.units.size() == 1, "Tutorial does not start with one actor in an isolated game"):
		return
	var before_position: float = board.units[0]["position"]
	var before_gold: Array = board.gold.duplicate()
	for _index in 1000:
		board._tick()
		game._tick()
	if not require(board.remaining == 0 and board.wave == 1 and board.units[0]["position"] == before_position and board.gold == before_gold, "Waiting starts a countdown, changes money or moves a unit"):
		return
	if not require(not board.purchase_unit(0, 1, 2) and not board.activate_ability(0), "An unrelated purchase bypasses the highlighted action"):
		return
	board._select_lane(0)
	board._begin_attack()
	if not require(board.lane == 1 and board.units.size() == 1 and board.phase == "PREP", "An unrelated lane or attack bypasses the guide"):
		return
	# Complete every lesson through actual GUI mouse input, in both languages.
	for language in ["pl", "en"]:
		game._change_language(language)
		for chapter in coach.chapters.size():
			coach.start_chapter(chapter)
			await frames()
			while not coach.completed:
				visited += 1
				var old_step: int = coach.step_index
				var data: Dictionary = coach.current_step()
				var action: String = data["action"]
				if not require(not coach.heading.text.is_empty() and not coach.body.text.is_empty(), "An instruction is blank"):
					return
				if language == "en" and not require(english(coach.heading.text + coach.body.text + board.timer_label.text), "Tutorial has untranslated English instructions"):
					return
				if action == "observe":
					if not require(coach.next_button.disabled, "An example can be skipped before showing the effect"):
						return
					if chapter == 0 and str(data["goal"]) == "pickup":
						coach.pause_button.pressed.emit()
						var paused_position: float = board.units[0]["position"]
						for _index in 50:
							coach.simulate_step()
						if not require(board.units[0]["position"] == paused_position and coach.paused, "Pause does not freeze the demonstration"):
							return
						coach.pause_button.pressed.emit()
					for _tick in 1800:
						coach.simulate_step()
						if coach.step_done:
							break
					if not require(coach.step_done, "Example cannot finish: %s/%s; units=%s traps=%s" % [coach.chapters[chapter]["id"], data["goal"], board.units, board.traps]):
						return
					if not require(not coach.next_button.disabled, "Next stays disabled after an observed outcome"):
						return
					await tap(coach.next_button)
				elif action == "next":
					await tap(coach.next_button)
				else:
					var button: Control = coach._control(action)
					coach._reveal_target()
					await frames()
					var point: Vector2 = button.get_global_rect().get_center()
					if not require(not button.disabled and button.is_visible_in_tree() and coach.focus_rect.has_point(point) and not coach.panel.get_global_rect().has_point(point), "Required control is disabled, hidden or covered: %s/%s; button=%s focus=%s panel=%s" % [coach.chapters[chapter]["id"], action, button.get_global_rect(), coach.focus_rect, coach.panel.get_global_rect()]):
						return
					clicked += 1
					await tap(button)
				if not require(coach.completed or coach.step_index == old_step + 1, "Real GUI click did not advance exactly one step: %s/%s" % [coach.chapters[chapter]["id"], action]):
					return
			if not require(game.account.total_xp == 0 and not game.account.race_unlocked(2) and not game.account.race_unlocked(3), "Training changes XP or unlocks real factions"):
				return
			print("Tutorial lesson PASSED: %s/%s" % [language, coach.chapters[chapter]["id"]])
	# Rapid repeated signals must not double-charge or skip a step.
	coach.start_chapter(1)
	board.controls[3].pressed.emit()
	board.controls[3].pressed.emit()
	await frames()
	if not require(board.orders[0].size() == 1 and board.gold[0] == 1000 - board.COSTS[0] and coach.step_index == 1, "A double tap buys twice or skips an instruction"):
		return
	coach.replay_button.pressed.emit()
	if not require(coach.step_index == 0 and board.gold[0] == 1000 and board.orders[0].is_empty(), "Repeat does not restart the current lesson cleanly"):
		return
	# Rotation and short phones must keep the caption separate from the action.
	for dimensions in [Vector2i(540, 960), Vector2i(720, 1280), Vector2i(720, 1560), Vector2i(1080, 1920), Vector2i(1280, 720), Vector2i(960, 540), Vector2i(1560, 720)]:
		root.size = dimensions
		game.size = Vector2(dimensions)
		await frames(5)
		for chapter in [0, 7, 8, 9]:
			coach.start_chapter(chapter)
			await frames(5)
			coach._reveal_target()
			await frames()
			var p: Rect2 = coach.panel.get_global_rect()
			if not require(p.end.x <= game.size.x + 1 and p.end.y <= game.size.y + 1 and not p.intersects(coach.mount_rect), "Instruction panel clips or covers the training board at " + str(dimensions)):
				return
			if chapter > 0:
				var target: Control = coach._control(str(coach.current_step()["action"]))
				var center: Vector2 = target.get_global_rect().get_center()
				if not require(coach.focus_rect.has_point(center) and coach.mount_rect.has_point(center), "Auto-scroll does not reveal a required control at " + str(dimensions)):
					return
	# Even an otherwise eligible empty vault cannot award XP or create a result.
	board.account_match_id = "00112233445566778899aabbccddeeff"
	board.account_battle_seconds = 100.0
	board.account_finished_waves = 8
	board.gold = [1000, 0]
	if not require(not board._check_vaults() and board.result_overlay == null and game.account.total_xp == 0 and not FileAccess.file_exists(ACCOUNT), "Tutorial can farm match rewards or writes account progress"):
		return
	game._navigate_back()
	if not require(game.tutorial_session == null and game.help_overlay.visible, "Android Back cannot return to the lesson list"):
		return
	game._close_how_to_play()
	game._choose_faction(1)
	game._buy_unit(0)
	var real_gold: Array = game.gold.duplicate()
	var real_orders: Array = game.orders.duplicate(true)
	var remaining: float = game.remaining
	game._show_how_to_play()
	game._start_tutorial(14)
	await frames()
	game.tutorial_session.set_process(false)
	for _index in 200:
		game._tick()
	if not require(game.phase == "PREP" and game.remaining == remaining and game.gold == real_gold and game.orders == real_orders and not game.purchase_training(0), "Opening a faction lesson changes or spends from the real match"):
		return
	game._close_tutorial()
	game.help_overlay.find_child("PlayAfterTutorial", true, false).pressed.emit()
	game._tick()
	if not require(game.remaining < remaining and not game.controls[4].disabled and game.selection_layer == null and game.gold == real_gold and game.orders == real_orders, "The original match and controls do not resume after exit, or the hub opens a new faction selection"):
		return
	DirAccess.remove_absolute(SETTINGS)
	game.queue_free()
	await frames()
	print("Guided tutorial PASSED: 15 lessons in PL/EN; %d steps, %d real clicks, no countdown, action gating, outcomes, pause/repeat, seven sizes, unlocked previews and isolated XP/match state" % [visited, clicked])
	quit(0)
