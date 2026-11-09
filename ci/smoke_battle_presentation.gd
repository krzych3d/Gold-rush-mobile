extends SceneTree
## Real navigation, gold visibility, responsive drawers and camera gestures.
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
	root.add_child(game)
	game._choose_faction(1)
	game.presentation.reduced_motion = true
	await process_frame
	await process_frame
	var shell = game.battle_shell
	for dimensions in [Vector2i(540, 960), Vector2i(720, 1280), Vector2i(720, 1560), Vector2i(1080, 1920)]:
		root.size = dimensions
		game.size = Vector2(dimensions)
		await process_frame
		await process_frame
		for opened in [false, true]:
			shell.set_drawer_open(opened, false)
			await process_frame
			var gold_bounds: Rect2 = game.hud.get_global_rect()
			var enemy_bounds: Rect2 = shell.enemy_gold.get_global_rect()
			if not _require(game.hud.is_visible_in_tree() and gold_bounds.position.y >= 0 and gold_bounds.end.y < 130 and enemy_bounds.end.x <= dimensions.x and gold_bounds.end.x <= enemy_bounds.position.x, "Gold is hidden, overlaps or leaves viewport at " + str(dimensions)):
				return
			if not _require(game.hud.get_theme_font_size("font_size") >= 28 and game.arena.size.y >= dimensions.y - 2, "Gold too small or battlefield is not full screen"):
				return
			if not _require(shell.dock.get_global_rect().end.y <= dimensions.y and shell.drawer.visible == opened, "Drawer or permanent actions overflow"):
				return
		var saved_gold: Array = game.gold.duplicate()
		game.map_mode_button.pressed.emit()
		if not _require(shell.overview and game.camera_zoom * 2400 <= game.arena.size.x + 2, "Overview crops one of the vaults"):
			return
		if not _require(is_equal_approx(game._sprite_transform(Vector2.ZERO).x.length(), game.camera_zoom), "Ground rings or sprites ignore camera scale"):
			return
		game.map_mode_button.pressed.emit()
		if not _require(not shell.overview and game.camera_zoom * 1060 >= game.arena.size.y - 2 and game.gold == saved_gold, "Focus mode changes economy or leaves blank bars"):
			return
	root.size = Vector2i(720, 1280)
	game.size = Vector2(720, 1280)
	await process_frame
	await process_frame
	shell.set_drawer_open(true, false)
	var before: int = game.gold[0]
	game.controls[3].pressed.emit()
	if not _require(game.gold[0] == before - game.COSTS[0] and game.hud.text == "ZŁOTO %d" % game.gold[0], "Purchase did not update permanent gold immediately"):
		return
	shell.drawer_button.pressed.emit()
	if not _require(not shell.drawer_open, "Arsenal toggle cannot close panel"):
		return
	shell.drawer_button.pressed.emit()
	if not _require(shell.drawer_open, "Arsenal toggle cannot reopen panel"):
		return
	# A camera drag must not be misinterpreted as a lane selection.
	shell.focus_location(0)
	var old_lane: int = game.lane
	var press := InputEventScreenTouch.new()
	press.pressed = true
	press.position = Vector2(360, 600)
	shell.handle_input(press)
	var drag := InputEventScreenDrag.new()
	drag.relative = Vector2(140, 0)
	shell.handle_input(drag)
	press.pressed = false
	press.position += drag.relative
	shell.handle_input(press)
	if not _require(game.camera_offset.x > 0 and game.lane == old_lane and not shell.follow_action, "Camera swipe selects a lane or fails to pan"):
		return
	game.controls[9].pressed.emit()
	if not _require(game.phase == "ATTACK" and not shell.drawer_open and game.controls[9].text == "BITWA TRWA", "Starting attack must close arsenal and retain status"):
		return
	# Also exercise the animated path and rapid repeated toggles.
	game.presentation.reduced_motion = false
	for _index in 5:
		shell.set_drawer_open(true)
		shell.set_drawer_open(false)
	await create_timer(0.4).timeout
	if not _require(not shell.drawer.visible and game.hud.is_visible_in_tree(), "Interrupted drawer tween leaves input or currency covered"):
		return
	print("Battle presentation PASSED: persistent gold, 4 phone sizes, purchase sync, full screen, overview, swipe, sliding arsenal and attack transition")
	game.queue_free()
	await process_frame
	quit(0)
