extends SceneTree
## Exercise the real fixed map, both orientations, touch hit tests and drawer races.
var game

func _initialize() -> void:
	call_deferred("_run")

func _require(value: bool, reason: String) -> bool:
	if not value:
		push_error(reason)
		quit(1)
	return value

func _resize(dimensions: Vector2i) -> void:
	root.size = dimensions
	game.size = Vector2(dimensions)
	for _frame in 4:
		await process_frame

func _run() -> void:
	root.size = Vector2i(720, 1280)
	game = load("res://main.tscn").instantiate()
	game.presentation.config_path = "user://qa-rotation.cfg"
	game.presentation.language = "pl"
	root.add_child(game)
	game._choose_faction(1)
	game.presentation.reduced_motion = true
	await process_frame
	var shell = game.battle_shell
	if not _require(ProjectSettings.get_setting("display/window/handheld/orientation") == DisplayServer.SCREEN_SENSOR, "Android still locks the display orientation"):
		return
	# Physical devices scale from a square minimum so their short axis stays 720.
	if not _require(root.content_scale_size == Vector2i(720, 720), "Logical UI shrinks when rotated"):
		return
	var saved_gold: Array = game.gold.duplicate()
	var saved_phase: String = game.phase
	var saved_race: int = game.selected_race
	for dimensions in [Vector2i(540, 960), Vector2i(720, 1280), Vector2i(720, 1560), Vector2i(1280, 720), Vector2i(1560, 720), Vector2i(960, 540), Vector2i(720, 1280)]:
		await _resize(dimensions)
		var wide: bool = dimensions.x > dimensions.y
		if not _require(shell.landscape == wide and shell.drawer_open == not wide, "Rotation did not switch portrait commands/landscape immersion at " + str(dimensions)):
			return
		var viewport := Rect2(Vector2.ZERO, Vector2(dimensions))
		for node in [game.hud, shell.enemy_gold, game.main_menu_button, shell.dock]:
			if not _require(viewport.grow(2).encloses(node.get_global_rect()), "HUD or actions leave viewport at " + str(dimensions)):
				return
		if not _require(game.hud.get_global_rect().end.x <= shell.enemy_gold.get_global_rect().position.x, "Player and enemy gold overlap"):
			return
		var map_bounds := Rect2(game.arena.size * 0.5 - Vector2(1200, 530) * game.camera_zoom, Vector2(2400, 1060) * game.camera_zoom)
		if not _require(Rect2(Vector2.ZERO, game.arena.size).grow(1).encloses(map_bounds) and game.camera_offset == Vector2.ZERO, "Map crops a vault or camera drifts after rotation"):
			return
		if not wide:
			if not _require(game.battlefield_frame.get_global_rect().end.y <= shell.drawer.get_global_rect().position.y and shell.drawer.get_global_rect().end.y <= shell.dock.position.y + 2, "Portrait menu covers map or permanent actions"):
				return
		var art_size: Vector2 = game._unit_art_size()
		var logical_height: float = art_size.y * game.camera_zoom
		if not _require(is_equal_approx(art_size.x, art_size.y) and logical_height >= 57.9 and logical_height <= 86.1, "Unit anatomy or readable size lost on rotation: " + str(logical_height)):
			return
		for path in 3:
			var target: Vector2 = game.arena.size * 0.5 + game._point(path, 0.5, 0) * game.camera_zoom
			var touch := InputEventScreenTouch.new()
			touch.position = target
			touch.pressed = true
			shell.handle_input(touch)
			touch.pressed = false
			shell.handle_input(touch)
			if not _require(game.lane == path, "Resized map uses wrong lane hit coordinates"):
				return
		if not _require(game.gold == saved_gold and game.phase == saved_phase and game.selected_race == saved_race, "Rotation changed a match"):
			return
		game.map_mode_button.pressed.emit()
		if not _require(shell.overview and game.camera_offset == Vector2.ZERO, "Old zoom callback re-enabled a cropped view"):
			return
	await _resize(Vector2i(1280, 720))
	shell.set_drawer_open(true, false)
	var before: int = game.gold[0]
	game.controls[3].pressed.emit()
	if not _require(game.gold[0] == before - game.COSTS[0] and game.hud.text == "ZŁOTO %d" % game.gold[0], "Purchase did not update permanent gold"):
		return
	shell.drawer_button.pressed.emit()
	if not _require(not shell.drawer_open, "Landscape drawer cannot close"):
		return
	shell.drawer_button.pressed.emit()
	if not _require(shell.drawer_open, "Landscape drawer cannot reopen"):
		return
	var old_lane: int = game.lane
	var press := InputEventScreenTouch.new()
	press.pressed = true
	press.position = Vector2(360, 200)
	shell.handle_input(press)
	var drag := InputEventScreenDrag.new()
	drag.relative = Vector2(140, 0)
	shell.handle_input(drag)
	press.pressed = false
	press.position += drag.relative
	shell.handle_input(press)
	if not _require(game.camera_offset == Vector2.ZERO and game.lane == old_lane and not shell.follow_action, "Swipe pans the map or selects a lane"):
		return
	game.controls[9].pressed.emit()
	if not _require(game.phase == "ATTACK" and not shell.drawer_open, "Landscape attack did not close drawer"):
		return
	# Freeze only the simulation clock while comparing exact actor dictionaries.
	# Rendering and container resizes keep running; normal time may advance units.
	for child in game.get_children():
		if child is Timer:
			child.stop()
	var snapshot: Array = game.units.duplicate(true)
	await _resize(Vector2i(720, 1280))
	if not _require(game.units == snapshot and shell.drawer_open, "Rotating an active match resets units or hides portrait commands"):
		return
	await _resize(Vector2i(1280, 720))
	game.presentation.reduced_motion = false
	for _index in 5:
		shell.set_drawer_open(true)
		shell.set_drawer_open(false)
	# Rotate during animation: obsolete tweens must not move the portrait menu.
	await _resize(Vector2i(720, 1280))
	await create_timer(0.3).timeout
	if not _require(shell.drawer.visible and is_equal_approx(shell.drawer.position.y, shell.command_top), "Interrupted tween moved the portrait menu off-screen"):
		return
	game._navigate_back()
	if not _require(game.menu_confirmation != null, "Android Back gets trapped trying to close permanent portrait commands"):
		return
	game._dismiss_menu_confirmation()
	DirAccess.remove_absolute("user://qa-rotation.cfg")
	print("Battle presentation PASSED: seven sizes, rotation during a match/tween, whole fixed map, HUD, readable unit scale, lane hits and purchases")
	game.queue_free()
	await process_frame
	quit(0)
