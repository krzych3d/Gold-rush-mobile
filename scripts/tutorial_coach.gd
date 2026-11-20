extends Control
## An isolated game instance, driven by explicit clicks and observed game events.
## The normal match, account and countdown are never advanced by this controller.
const Lessons = preload("res://scripts/tutorial_lessons.gd")
const Epic = preload("res://scripts/epic_theme.gd")
const MobileLayout = preload("res://scripts/mobile_layout.gd")
var host
var sandbox
var chapter_index := 0
var step_index := 0
var chapters: Array = []
var setup_in_progress := false
var completed := false
var step_done := false
var simulation_running := false
var paused := false
var closing := false
var accumulator := 0.0
var step_serial := 0
var demo_serial := 0
var marker_before := 0
var delivery_gold := 0
var demo_actor: Dictionary = {}
var mount: Control
var panel: PanelContainer
var progress: Label
var heading: Label
var body: Label
var next_button: Button
var pause_button: Button
var replay_button: Button
var masks: Array[ColorRect] = []
var focus_rect := Rect2()
var mount_rect := Rect2()
var target_button: Button
var pulse := 0.0
var host_buttons: Array = []
var pointer: Control
var ui_elapsed := 0.0
var focus_elapsed := 0.0

func copy(pl: String, en: String) -> String:
	return Lessons.text([pl, en])

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var backdrop := ColorRect.new()
	backdrop.color = Color("071020")
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	chapters = Lessons.definitions()
	var focused: Control = get_viewport().gui_get_focus_owner()
	if focused != null:
		focused.release_focus()
	for button in host.find_children("*", "Button", true, false):
		host_buttons.append([button, button.disabled, button.focus_mode])
		button.disabled = true
		button.focus_mode = Control.FOCUS_NONE
	mount = Control.new()
	mount.name = "TrainingBoard"
	add_child(mount)
	sandbox = load("res://main.tscn").instantiate()
	sandbox.tutorial_mode = true
	sandbox.tutorial_coach = self
	sandbox.account = host.account
	sandbox.presentation = host.presentation
	sandbox.name = "TutorialSandbox"
	mount.add_child(sandbox)
	for _index in 4:
		var shade := ColorRect.new()
		shade.color = Color(0.01, 0.02, 0.06, 0.60)
		shade.mouse_filter = Control.MOUSE_FILTER_STOP
		shade.z_index = 140
		add_child(shade)
		masks.append(shade)
	pointer = Control.new()
	pointer.name = "TutorialPointer"
	pointer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pointer.z_index = 145
	pointer.draw.connect(_draw_pointer)
	add_child(pointer)
	_build_panel()
	for index in 10:
		sandbox.controls[index].pressed.connect(_on_pressed.bind("lane:%d" % index if index < 3 else "unit:%d" % (index - 3) if index < 6 else "trap:%d" % (index - 6) if index < 9 else "attack"))
	for pair in [[sandbox.guard_button, "guard"], [sandbox.ability_button, "ability"], [sandbox.invest_button, "bank"], [sandbox.raid_button, "training"]]:
		pair[0].pressed.connect(_on_pressed.bind(str(pair[1])))
	resized.connect(_layout)
	_layout()
	start_chapter(chapter_index)

func _button(parent: Node, id: String, handler: Callable, primary: bool = false) -> Button:
	var button := Button.new()
	button.name = id
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size.y = 48
	parent.add_child(button)
	Epic.button(button, primary, 18)
	button.pressed.connect(handler)
	return button

func _label(parent: Node, id: String, font_size: int) -> Label:
	var label := Label.new()
	label.name = id
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("e2e8ef"))
	parent.add_child(label)
	return label

func _build_panel() -> void:
	panel = PanelContainer.new()
	panel.name = "TutorialModal"
	panel.z_index = 150
	panel.add_theme_stylebox_override("panel", Epic.panel(12))
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	panel.add_child(column)
	var top := HBoxContainer.new()
	column.add_child(top)
	progress = _label(top, "TutorialProgress", 16)
	var exit_button := _button(top, "TutorialLessons", exit_to_lessons)
	exit_button.text = copy("Lekcje", "Lessons")
	exit_button.size_flags_horizontal = Control.SIZE_FILL
	exit_button.custom_minimum_size.x = 84
	heading = _label(column, "TutorialHeading", 24)
	Epic.heading(heading, 24)
	var scroll := ScrollContainer.new()
	scroll.name = "TutorialTextScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size.y = 64
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	body = _label(scroll, "TutorialDescription", 18)
	var navigation := HBoxContainer.new()
	navigation.add_theme_constant_override("separation", 6)
	column.add_child(navigation)
	next_button = _button(navigation, "TutorialNext", advance, true)
	pause_button = _button(navigation, "TutorialPause", _toggle_pause)
	replay_button = _button(navigation, "TutorialReplay", _replay)
	replay_button.tooltip_text = copy("Powtórz bieżącą lekcję od początku.", "Restart the current lesson.")

func _layout() -> void:
	if not is_instance_valid(panel) or size.x < 1:
		return
	var safe: Rect2 = MobileLayout.safe_rect(self)
	if safe.size.x > safe.size.y:
		var width: float = minf(380.0, safe.size.x * 0.36)
		panel.position = safe.position + Vector2(8, 8)
		panel.size = Vector2(width - 16, safe.size.y - 16)
		mount.position = safe.position + Vector2(width, 0)
		mount.size = Vector2(safe.size.x - width, safe.size.y)
	else:
		var height: float = clampf(safe.size.y * 0.26, 248, 292)
		panel.position = safe.position + Vector2(8, 8)
		panel.size = Vector2(safe.size.x - 16, height)
		mount.position = safe.position + Vector2(0, height + 16)
		mount.size = Vector2(safe.size.x, maxf(1, safe.size.y - height - 16))
	call_deferred("_reveal_target")

func current_step() -> Dictionary:
	return chapters[chapter_index]["steps"][step_index]

func start_chapter(index: int) -> void:
	chapter_index = clampi(index, 0, chapters.size() - 1)
	step_index = 0
	completed = false
	paused = false
	simulation_running = false
	setup_in_progress = true
	sandbox.selected_race = int(chapters[chapter_index]["race"])
	sandbox.bot_race = 1
	sandbox.phase = "PREP"
	sandbox.wave = 1
	sandbox.remaining = 0.0
	sandbox.gold = [1000, 1000]
	sandbox.interest_last = [0, 0]
	sandbox.lane = 1
	sandbox.bank_level = 0
	sandbox.bot_bank_level = 0
	sandbox.raid_boost = 0
	sandbox.bot_raid_boost = 0
	sandbox.ability_used = false
	sandbox.bot_ability_used = false
	sandbox.orders = [[], []]
	sandbox.traps = [[], []]
	sandbox.guards.clear()
	sandbox.account_match_id = ""
	sandbox.account_finished_waves = 0
	sandbox.account_battle_seconds = 0.0
	sandbox.account_wave_active = false
	sandbox.account_reward = {}
	_clear_demo()
	setup_in_progress = false
	_enter_step()

func _clear_demo() -> void:
	sandbox.units.clear()
	sandbox.hit_sparks.clear()
	sandbox.turret_bolts.clear()
	sandbox.fallen_actors.clear()
	sandbox.deposit_actors.clear()
	demo_actor = {}
	sandbox.phase = "PREP"

func _enter_step() -> void:
	step_serial += 1
	step_done = false
	accumulator = 0.0
	ui_elapsed = 0.0
	var data: Dictionary = current_step()
	setup_in_progress = true
	match str(data["setup"]):
		"preview":
			_clear_demo()
			sandbox._spawn(0, 1, -1, 0.23)
			demo_actor = sandbox.units.back()
		"clear_demo": _clear_demo()
		"enemy_spikes":
			_clear_demo()
			sandbox.purchase_trap(1, 1, 0)
			sandbox.purchase_trap(1, 1, 0)
		"resume_prep": sandbox.phase = "PREP"
	if str(data["action"]) not in ["observe", "next"]:
		sandbox.phase = "PREP"
	setup_in_progress = false
	simulation_running = str(data["action"]) == "observe"
	marker_before = _marker(str(data["action"]))
	sandbox._refresh()
	rebuild_language()
	call_deferred("_reveal_target")

func _marker(action: String) -> int:
	if action.begins_with("lane:"):
		return sandbox.lane
	if action.begins_with("unit:"):
		return sandbox.orders[0].size()
	if action.begins_with("trap:"):
		return sandbox.traps[0].size()
	match action:
		"guard": return sandbox.guards.size()
		"bank": return sandbox.bank_level
		"training": return sandbox.raid_boost
		"ability": return 1 if sandbox.ability_used else 0
		"attack": return demo_serial
	return 0

func allows(action: String) -> bool:
	if setup_in_progress:
		return true
	if closing or completed or chapters.is_empty() or current_step()["action"] != action:
		return false
	return action.begins_with("lane:") or _marker(action) == marker_before

func _on_pressed(action: String) -> void:
	if closing or completed or action != current_step()["action"]:
		return
	if action.begins_with("lane:"):
		if sandbox.lane != int(action.get_slice(":", 1)):
			return
	elif _marker(action) == marker_before:
		return
	call_deferred("_accept_action", step_serial)

func _accept_action(serial: int) -> void:
	if closing or serial != step_serial or completed:
		return
	_next_step()

func advance() -> void:
	if completed:
		if chapter_index + 1 < chapters.size():
			start_chapter(chapter_index + 1)
		else:
			exit_to_lessons()
	elif current_step()["action"] == "next" or (current_step()["action"] == "observe" and step_done):
		_next_step()

func _next_step() -> void:
	simulation_running = false
	if step_index + 1 >= chapters[chapter_index]["steps"].size():
		completed = true
		step_done = true
		rebuild_language()
		sync_controls()
		return
	step_index += 1
	_enter_step()

func _control(target: String) -> Control:
	if target.begins_with("lane:"):
		return sandbox.controls[int(target.get_slice(":", 1))]
	if target.begins_with("unit:"):
		return sandbox.controls[3 + int(target.get_slice(":", 1))]
	if target.begins_with("trap:"):
		return sandbox.controls[6 + int(target.get_slice(":", 1))]
	match target:
		"guard_button", "guard": return sandbox.guard_button if current_step()["action"] == "guard" else null
		"ability": return sandbox.ability_button
		"bank": return sandbox.invest_button
		"training": return sandbox.raid_button
		"attack": return sandbox.controls[9]
		"gold": return sandbox.hud
		"arena": return sandbox.arena
	return null

func sync_controls() -> void:
	if not is_instance_valid(sandbox) or sandbox.controls.size() < 10 or chapters.is_empty():
		return
	target_button = null
	if not completed:
		target_button = _control(str(current_step()["action"])) as Button
	var target_available: bool = is_instance_valid(target_button) and allows(str(current_step()["action"])) and (str(current_step()["action"]).begins_with("lane:") or not target_button.disabled)
	var buttons: Array = sandbox.controls.duplicate()
	buttons.append_array([sandbox.guard_button, sandbox.ability_button, sandbox.invest_button, sandbox.raid_button, sandbox.main_menu_button, sandbox.race_button, sandbox.map_mode_button])
	if is_instance_valid(sandbox.battle_shell):
		buttons.append(sandbox.battle_shell.drawer_button)
	for button in buttons:
		button.disabled = button != target_button or not target_available
		button.focus_mode = Control.FOCUS_ALL if button == target_button and target_available else Control.FOCUS_NONE

func _reveal_target() -> void:
	if closing or not is_instance_valid(sandbox.battle_shell):
		return
	var target: Control = _control(str(current_step()["target"])) if not completed else null
	var show_commands: bool = is_instance_valid(target) and (target is Button) and target != sandbox.controls[9]
	if sandbox.battle_shell.landscape:
		sandbox.battle_shell.set_drawer_open(show_commands, false)
	if show_commands:
		sandbox.battle_shell.drawer.ensure_control_visible(target)
	_sync_focus()

func rebuild_language() -> void:
	if not is_instance_valid(progress):
		return
	progress.text = copy("LEKCJA %d/%d • KROK %d/%d", "LESSON %d/%d • STEP %d/%d") % [chapter_index + 1, chapters.size(), step_index + 1, chapters[chapter_index]["steps"].size()]
	heading.text = copy("Lekcja ukończona", "Lesson complete") if completed else Lessons.text(current_step()["title"])
	body.text = copy("Możesz przejść do następnej lekcji, powtórzyć tę albo wrócić do listy. Złoto i EXP twojej gry pozostały bez zmian.", "Continue to the next lesson, repeat this one or return to the list. Your real match's gold and XP are unchanged.") if completed else Lessons.text(current_step()["body"])
	if step_done and not completed:
		body.text += "\n\n" + copy("Efekt pokazany. Kliknij Dalej, kiedy skończysz czytać.", "Example complete. Tap Next when you have finished reading.")
	(find_child("TutorialLessons", true, false) as Button).text = copy("Lekcje", "Lessons")
	next_button.text = copy("Następna", "Next lesson") if completed and chapter_index + 1 < chapters.size() else copy("Zakończ", "Finish") if completed else copy("Dalej", "Next")
	next_button.disabled = not completed and current_step()["action"] != "next" and not step_done
	pause_button.text = copy("Wznów", "Resume") if paused else copy("Pauza", "Pause")
	pause_button.disabled = not simulation_running or step_done
	replay_button.text = copy("Powtórz", "Repeat")
	for button in [next_button, pause_button, replay_button]:
		Epic._fit_button(button)
	sandbox._refresh()

func _toggle_pause() -> void:
	if not simulation_running or step_done:
		return
	paused = not paused
	rebuild_language()

func _replay() -> void:
	start_chapter(chapter_index)

func exit_to_lessons() -> void:
	if closing:
		return
	closing = true
	simulation_running = false
	host._close_tutorial()

func restore_host_controls() -> void:
	for state in host_buttons:
		if is_instance_valid(state[0]):
			state[0].disabled = state[1]
			state[0].focus_mode = state[2]
	host_buttons.clear()

func _spawn(side: int, kind: int, position: float, path: int = 1) -> void:
	sandbox._spawn(side, path, kind, position)
	demo_actor = sandbox.units.back()

func launch_demo() -> void:
	demo_serial += 1
	delivery_gold = sandbox.gold[0]
	setup_in_progress = true
	var demo: String = current_step()["demo"]
	if demo != "resume":
		_clear_demo()
	sandbox.phase = "ATTACK"
	match demo:
		"free": _spawn(0, -1, 0.0, sandbox.lane)
		"ordered", "ordered_near":
			for index in sandbox.orders[0].size():
				var order: Dictionary = sandbox.orders[0][index]
				var start: float = 0.9 if demo == "ordered_near" else 0.42 if str(chapters[chapter_index]["id"]) in ["saboteur", "voidborn"] else -float(index) * 0.07
				_spawn(0, int(order["kind"]), start, int(order["lane"]))
		"guard": _spawn(1, 0, 0.76)
		"spikes", "snare": _spawn(1, 0, 0.45)
		"turret": _spawn(1, 1, 0.36)
		"tower_counter": _spawn(1, 2, 0.34)
		"interest", "shield_settlement": sandbox._end_wave()
		"training":
			var level: int = sandbox.raid_boost
			sandbox.raid_boost = 0
			_spawn(0, -1, 0.0, 0)
			sandbox.raid_boost = level
			_spawn(0, -1, 0.0, 2)
		"shield": _spawn(1, 1, 0.80)
		"frenzy":
			sandbox.phase = "PREP"
			sandbox.purchase_guard(1, 1)
			sandbox.phase = "ATTACK"
			_spawn(0, 1, 0.80)
	setup_in_progress = false

func _goal_met(goal: String) -> bool:
	match goal:
		"pickup":
			for unit in sandbox.units:
				if int(unit["side"]) == 0 and bool(unit["returning"]) and int(unit["carried"]) > 0:
					return true
		"delivery": return sandbox.units.is_empty() and sandbox.deposit_actors.is_empty() and int(sandbox.gold[0]) > delivery_gold
		"disarmed": return not demo_actor.is_empty() and bool(demo_actor["disarmed"])
		"damaged": return not demo_actor.is_empty() and float(demo_actor["health"]) < float(demo_actor["max_health"])
		"defended": return sandbox.units.is_empty() and sandbox.fallen_actors.is_empty()
		"stunned": return not demo_actor.is_empty() and float(demo_actor["stunned"]) > 1.0
		"tower_removed": return sandbox.traps[0].is_empty() and not demo_actor.is_empty() and bool(demo_actor["disarmed"])
		"trained_ahead": return sandbox.units.size() == 2 and float(sandbox.units[1]["position"]) > float(sandbox.units[0]["position"]) + 0.045
		"shield_hit": return not sandbox.guards.is_empty() and float(sandbox.guards[0].get("shield", 0.0)) < sandbox.Rules.IRON_SHIELD
		"frenzy_hit": return not demo_actor.is_empty() and bool(demo_actor.get("frenzy", false)) and float(demo_actor.get("attack_time", 0.0)) > 0.0
		"evaded": return not demo_actor.is_empty() and not bool(demo_actor.get("shadow_evasion", true)) and float(demo_actor["health"]) == float(demo_actor["max_health"])
	return false

func simulate_step(dt: float = 0.05) -> void:
	if closing or not simulation_running or paused or step_done:
		return
	sandbox._simulate(dt)
	if _goal_met(str(current_step()["goal"])):
		step_done = true
		simulation_running = false
		rebuild_language()
	else:
		ui_elapsed += dt
		if ui_elapsed >= 0.2:
			ui_elapsed = 0.0
			sandbox._refresh()

func _process(delta: float) -> void:
	if closing or not is_instance_valid(sandbox):
		return
	if simulation_running and not paused:
		accumulator = minf(0.25, accumulator + delta)
		while accumulator >= 0.05 and simulation_running:
			accumulator -= 0.05
			simulate_step()
	if not host.presentation.reduced_motion:
		pulse += delta
	focus_elapsed += delta
	if focus_elapsed >= 1.0 / host.presentation.battlefield_fps():
		focus_elapsed = 0.0
		_sync_focus()
		pointer.queue_redraw()

func _actor_rect(data: Dictionary, is_guard: bool = false) -> Rect2:
	if data.is_empty():
		return Rect2()
	var world: Vector2 = sandbox._point(int(data["lane"]), clampf(float(data["position"]), 0.0, 1.0), int(data["side"]))
	var point: Vector2 = sandbox.arena.get_global_transform() * (sandbox._iso_transform() * world)
	point = get_global_transform().affine_inverse() * point
	var height := 92.0 if is_guard else 82.0
	return Rect2(point + Vector2(-42, -height), Vector2(84, height + 12))

func _sync_focus() -> void:
	if not is_instance_valid(sandbox.arena) or chapters.is_empty():
		return
	mount_rect = Rect2(mount.position, mount.size)
	var target: String = "arena" if completed else str(current_step()["target"])
	var control: Control = _control(target)
	focus_rect = Rect2()
	if is_instance_valid(control):
		focus_rect = get_global_transform().affine_inverse() * control.get_global_rect()
	elif target == "actor":
		focus_rect = _actor_rect(demo_actor)
		if sandbox.units.is_empty() and not demo_actor.is_empty() and int(demo_actor.get("carried", 0)) > 0 and float(demo_actor.get("health", 0)) > 0:
			focus_rect = get_global_transform().affine_inverse() * sandbox.hud.get_global_rect()
	elif target == "guard" and not sandbox.guards.is_empty():
		focus_rect = _actor_rect(sandbox.guards[0], true)
	elif target == "trap" and not sandbox.traps[0].is_empty():
		var trap: Dictionary = sandbox.traps[0][0]
		var global_point: Vector2 = sandbox.arena.get_global_transform() * (sandbox._iso_transform() * sandbox._trap_position(trap, 0))
		var point: Vector2 = get_global_transform().affine_inverse() * global_point
		focus_rect = Rect2(point + Vector2(-48, -90), Vector2(96, 106))
	if focus_rect.size == Vector2.ZERO:
		focus_rect = get_global_transform().affine_inverse() * sandbox.arena.get_global_rect()
	if str(current_step()["action"]) == "observe" and target in ["guard", "trap"]:
		focus_rect = focus_rect.merge(_actor_rect(demo_actor))
	focus_rect = focus_rect.grow(5).intersection(mount_rect)
	if focus_rect.size.x < 1 or focus_rect.size.y < 1:
		for mask in masks:
			mask.position = mount.position
			mask.size = mount.size
		return
	var r := focus_rect
	var areas := [Rect2(mount_rect.position, Vector2(mount_rect.size.x, maxf(0, r.position.y - mount_rect.position.y))),
		Rect2(Vector2(mount_rect.position.x, r.end.y), Vector2(mount_rect.size.x, maxf(0, mount_rect.end.y - r.end.y))),
		Rect2(Vector2(mount_rect.position.x, r.position.y), Vector2(maxf(0, r.position.x - mount_rect.position.x), r.size.y)),
		Rect2(Vector2(r.end.x, r.position.y), Vector2(maxf(0, mount_rect.end.x - r.end.x), r.size.y))]
	for index in 4:
		masks[index].position = areas[index].position
		masks[index].size = areas[index].size

func _draw_pointer() -> void:
	if focus_rect.size.x <= 0 or focus_rect.size.y <= 0:
		return
	var strength: float = 0.85 + 0.15 * sin(pulse * 3.0)
	pointer.draw_rect(focus_rect, Color(1.0, 0.82, 0.40, strength), false, 3.0)
	var tip := Vector2(focus_rect.get_center().x, focus_rect.position.y + 6)
	pointer.draw_colored_polygon(PackedVector2Array([tip, tip + Vector2(-9, -15), tip + Vector2(9, -15)]), Color("ffda88"))
