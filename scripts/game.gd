extends Control

const MAX_WAVES := 5
const RACE_NAMES := ["DWARVES", "GOBLINS", "ELVES", "VOIDBORN"]
const PREP_TIME := 30.0
const ATTACK_TIME := 60.0
const COSTS := [75, 140, 110]
const LOOTS := [50, 160, 40]
const HP := [45.0, 180.0, 75.0]
const SPEED := [0.21, 0.105, 0.15]
const TRAP_COSTS := [55, 75, 155]

var selected_race := 0
var wave := 1
var phase := "PREP"
var remaining := PREP_TIME
var gold := [1000, 1000]
var lane := 1
var orders: Array = [[], []]
var traps: Array = [[], []]
var units: Array = []
var rng := RandomNumberGenerator.new()
var message := "Every purchase reduces your vault!"
var hud: Label
var timer_label: Label
var info: Label
var arena: Control
var controls: Array[Button] = []
var visual_time := 0.0
var title_label: Label
var race_button: Button

func _ready() -> void:
	rng.randomize()
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var title := Label.new()
	title_label = title
	title.text = "GOLD RUSH: VAULT WARS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	root.add_child(title)
	_style_label(title, 31, Color("ffe2a0"))
	hud = Label.new()
	hud.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(hud)
	_style_label(hud, 22, Color("f8d37c"))
	timer_label = Label.new()
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(timer_label)
	_style_label(timer_label, 19, Color("d5e8fa"))
	arena = Control.new()
	arena.custom_minimum_size = Vector2(0, 570)
	arena.size_flags_vertical = Control.SIZE_EXPAND_FILL
	arena.draw.connect(_draw_arena)
	root.add_child(arena)
	arena.mouse_filter = Control.MOUSE_FILTER_STOP
	arena.gui_input.connect(_arena_input)
	info = Label.new()
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.custom_minimum_size.y = 72
	root.add_child(info)
	_style_label(info, 18, Color("f0e7cf"))
	race_button = Button.new()
	race_button.text = "CHOOSE YOUR RACE"
	race_button.custom_minimum_size.y = 56
	root.add_child(race_button)
	_style_button(race_button, true)
	race_button.pressed.connect(_change_race)
	for labels in [["LANE 1", "LANE 2", "LANE 3"], ["RUNNER 75", "CARRIER 140", "SABOTEUR 110"], ["SPIKES 55", "SNARE 75", "TURRET 155"]]:
		var row := HBoxContainer.new()
		root.add_child(row)
		for index in 3:
			var button := Button.new()
			button.text = labels[index]
			button.custom_minimum_size.y = 62
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(button)
			_style_button(button, controls.size() < 3)
			controls.append(button)
			if controls.size() <= 3:
				button.pressed.connect(_select_lane.bind(index))
			elif controls.size() <= 6:
				button.pressed.connect(_buy_unit.bind(index))
			else:
				button.pressed.connect(_buy_trap.bind(index))
	var start := Button.new()
	start.text = "START ATTACK"
	start.custom_minimum_size.y = 70
	root.add_child(start)
	_style_button(start, false)
	controls.append(start)
	start.pressed.connect(_start_pressed)
	var clock := Timer.new()
	clock.wait_time = 0.1
	clock.timeout.connect(_tick)
	add_child(clock)
	clock.start()
	_refresh()

func _change_race() -> void:
	if phase != "PREP" or wave != 1:
		return
	selected_race = (selected_race + 1) % RACE_NAMES.size()
	message = "Playing as " + RACE_NAMES[selected_race]
	_refresh()

func _select_lane(index: int) -> void:
	lane = index
	message = "Selected lane %d" % (lane + 1)
	_refresh()

func _buy_unit(kind: int) -> void:
	if phase != "PREP":
		return
	var lane_count := 0
	for order in orders[0]:
		if order["lane"] == lane:
			lane_count += 1
	if gold[0] < COSTS[kind] or orders[0].size() >= 6 or lane_count >= 4:
		message = "Not enough gold or unit limit reached."
		_refresh()
		return
	gold[0] -= COSTS[kind]
	orders[0].append({"kind": kind, "lane": lane})
	message = "Thief queued on lane %d" % (lane + 1)
	_refresh()

func _buy_trap(kind: int) -> void:
	if phase != "PREP":
		return
	var lane_count := 0
	for trap in traps[0]:
		if trap["lane"] == lane:
			lane_count += 1
	if gold[0] < TRAP_COSTS[kind] or lane_count >= 5:
		message = "Not enough gold or trap limit reached."
		_refresh()
		return
	gold[0] -= TRAP_COSTS[kind]
	traps[0].append({"lane": lane, "kind": kind, "charges": [3, 2, 999][kind]})
	message = "Trap built on lane %d" % (lane + 1)
	_refresh()

func _bot_prepare() -> void:
	var budget: int = mini(350, int(gold[1] * 0.38))
	while budget >= 75 and orders[1].size() < 4:
		var kind := rng.randi_range(0, 2)
		if COSTS[kind] > budget or COSTS[kind] >= gold[1]:
			break
		orders[1].append({"lane": rng.randi_range(0, 2), "kind": kind})
		gold[1] -= COSTS[kind]
		budget -= COSTS[kind]
	if gold[1] > 160 and traps[1].size() < wave * 2:
		gold[1] -= 55
		traps[1].append({"lane": rng.randi_range(0, 2), "kind": 0, "charges": 3})

func _start_pressed() -> void:
	if phase == "END":
		get_tree().reload_current_scene()
	elif phase == "PREP":
		_begin_attack()

func _begin_attack() -> void:
	_bot_prepare()
	phase = "ATTACK"
	remaining = ATTACK_TIME
	units.clear()
	for side in 2:
		for path in 3:
			for n in (wave + 1 if wave < 5 else 7):
				_spawn(side, path, -1, -float(n) * 0.07)
		for order in orders[side]:
			_spawn(side, order["lane"], order["kind"], -rng.randf_range(0.0, 0.15))
	message = "Attack phase! Steal gold and return home."
	_refresh()

func _spawn(side: int, path: int, kind: int, offset: float) -> void:
	var unit_health: float = 60.0 if kind == -1 else HP[kind]
	var unit_speed: float = 0.145 if kind == -1 else SPEED[kind]
	var unit_capacity: int = 25 if kind == -1 else LOOTS[kind]
	if side == 0:
		match selected_race:
			0:
				unit_health *= 1.25
			1:
				unit_speed *= 1.2
			2:
				unit_health *= 1.1
				unit_capacity += 10
			3:
				unit_speed *= 1.1
				unit_capacity += 15
	units.append({"side": side, "lane": path, "kind": kind, "position": offset, "returning": false, "health": unit_health, "speed": unit_speed, "capacity": unit_capacity, "carried": 0, "stunned": 0.0, "disarmed": false, "triggered": []})

func _tick() -> void:
	visual_time += 0.1
	arena.queue_redraw()
	if phase == "END":
		return
	remaining -= 0.1
	if phase == "PREP":
		if remaining <= 0.0:
			_begin_attack()
	else:
		_simulate(0.1)
		if remaining <= 0.0 or units.is_empty():
			_end_wave()
	_refresh()

func _simulate(dt: float) -> void:
	for unit in units.duplicate():
		if unit["stunned"] > 0.0:
			unit["stunned"] -= dt
			continue
		var defender: int = 1 - unit["side"]
		if not unit["returning"] and unit["position"] >= 0.35 and unit["position"] < 0.85:
			for trap in traps[defender].duplicate():
				if trap["lane"] != unit["lane"] or trap["charges"] <= 0:
					continue
				if trap["kind"] == 2:
					unit["health"] -= 18.0 * dt
				elif not unit["triggered"].has(trap):
					unit["triggered"].append(trap)
					if unit["kind"] == 2 and not unit["disarmed"]:
						unit["disarmed"] = true
						trap["charges"] = 0
					else:
						unit["health"] -= 40.0 if trap["kind"] == 0 else 25.0
						if trap["kind"] == 1:
							unit["stunned"] = 2.5
						trap["charges"] -= 1
					if trap["charges"] <= 0:
						traps[defender].erase(trap)
					break
		if unit["health"] <= 0:
			if unit["carried"] > 0:
				gold[defender] += unit["carried"]
			units.erase(unit)
			continue
		if not unit["returning"]:
			unit["position"] += unit["speed"] * dt
			if unit["position"] >= 1.0:
				var amount: int = mini(unit["capacity"], gold[defender])
				gold[defender] -= amount
				unit["carried"] = amount
				unit["returning"] = true
		else:
			unit["position"] -= unit["speed"] * dt
			if unit["position"] <= 0.0:
				gold[unit["side"]] += unit["carried"]
				units.erase(unit)

func _end_wave() -> void:
	if phase != "ATTACK":
		return
	for unit in units:
		if unit["carried"] > 0:
			gold[1 - unit["side"]] += unit["carried"]
	units.clear()
	orders[0].clear()
	orders[1].clear()
	if gold[0] <= 0 or gold[1] <= 0 or wave >= MAX_WAVES:
		phase = "END"
		message = "YOU WIN!" if gold[0] > gold[1] else "BOT WINS!" if gold[1] > gold[0] else "DRAW!"
		return
	for side in 2:
		gold[side] += mini(100, int(gold[side] * 0.08))
	wave += 1
	phase = "PREP"
	remaining = PREP_TIME
	message = "Interest paid. Prepare for next wave!"

func _refresh() -> void:
	race_button.text = "RACE: " + RACE_NAMES[selected_race]
	race_button.disabled = phase != "PREP" or wave > 1
	hud.text = "YOUR VAULT: %d     ENEMY: %d" % [gold[0], gold[1]]
	timer_label.text = "WAVE %d/%d | %s | %02d s" % [wave, MAX_WAVES, phase, int(maxf(0.0, ceilf(remaining)))]
	info.text = message + "\nLane: %d | Thieves: %d | Traps: %d" % [lane + 1, orders[0].size(), traps[0].size()]
	for i in range(3, 9):
		controls[i].disabled = phase != "PREP"
	controls[9].disabled = phase == "ATTACK"
	controls[9].text = "PLAY AGAIN" if phase == "END" else "UNLEASH THE RAID" if phase == "PREP" else "BATTLE IN PROGRESS"
	for i in 3:
		controls[i].modulate = Color("ffe29a") if i == lane else Color.WHITE
	arena.queue_redraw()

func _point(path: int, progress: float, side: int) -> Vector2:
	var center := arena.size * 0.5
	var left := Vector2(-arena.size.x * 0.34, -arena.size.y * 0.12 + path * 57.0)
	var right := Vector2(arena.size.x * 0.34, -arena.size.y * 0.12 + path * 57.0)
	return center + (left.lerp(right, progress) if side == 0 else right.lerp(left, progress))

func _style_label(label: Label, font_size: int, color: Color) -> void:
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color("101827"))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 3)

func _style_button(button: Button, is_lane: bool) -> void:
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", Color("fff2d4"))
	button.add_theme_color_override("font_disabled_color", Color("b1a48c"))
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("314a60") if is_lane else Color("584235")
		if state == "pressed":
			style.bg_color = Color("987041")
		if state == "disabled":
			style.bg_color = Color("383b43")
		style.border_color = Color("e8bb70")
		style.set_border_width_all(2)
		style.set_corner_radius_all(12)
		style.content_margin_left = 3
		style.content_margin_right = 3
		button.add_theme_stylebox_override(state, style)

func _arena_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		var y: float = event.position.y - arena.size.y * 0.5
		var selected := clampi(int(round((y + arena.size.y * 0.12) / 57.0)), 0, 2)
		_select_lane(selected)

func _draw_arena() -> void:
	var center := arena.size * 0.5
	var w: float = minf(arena.size.x * 0.47, 315.0)
	var h: float = minf(arena.size.y * 0.39, 230.0)
	arena.draw_rect(Rect2(Vector2.ZERO, arena.size), Color("141e32"))
	# Animated sky, distant mountain silhouettes and drifting stars.
	for i in 22:
		var sx := fposmod(float(i * 137) + sin(visual_time * 0.23 + float(i)) * 9.0, arena.size.x)
		var sy := fposmod(float(i * 79), arena.size.y * 0.62)
		arena.draw_circle(Vector2(sx, sy), 1.5 + sin(visual_time * 1.8 + float(i)) * 0.7, Color("b8d8ff", 0.48))
	for i in 7:
		var mx := float(i) * arena.size.x / 6.0
		arena.draw_colored_polygon(PackedVector2Array([Vector2(mx - 160, center.y + 45), Vector2(mx, center.y - 170 - float(i % 3) * 22), Vector2(mx + 180, center.y + 45)]), Color("243a50"))
	arena.draw_colored_polygon(PackedVector2Array([center + Vector2(0, -h), center + Vector2(w, 0), center + Vector2(0, h), center + Vector2(-w, 0)]), Color("365c50"))
	arena.draw_colored_polygon(PackedVector2Array([center + Vector2(0, -h + 19), center + Vector2(w - 20, 0), center + Vector2(0, h - 19), center + Vector2(-w + 20, 0)]), Color("46785d"))
	for i in 14:
		var seed := float(i)
		var x := center.x + sin(seed * 8.31) * w * 0.74
		var y := center.y + cos(seed * 3.47) * h * 0.67
		arena.draw_circle(Vector2(x, y), 3.0, Color("8fba79"))
	for path in 3:
		var a := _point(path, 0, 0)
		var b := _point(path, 1, 0)
		arena.draw_line(a + Vector2(0, 7), b + Vector2(0, 7), Color("1c332e"), 33.0, true)
		arena.draw_line(a, b, Color("8a674c"), 29.0, true)
		arena.draw_line(a, b, Color("edc88c") if path == lane else Color("b99b72"), 22.0, true)
		for j in 12:
			var p := a.lerp(b, float(j) / 11.0)
			arena.draw_line(p + Vector2(-3, -8), p + Vector2(3, 8), Color("81664e", 0.5), 2.0)
	for side in 2:
		var fort := _point(1, 0, side)
		var base_color := Color("4f86bf") if side == 0 else Color("ad5265")
		_draw_fort(fort, base_color, side)
		for trap in traps[side]:
			var p := _point(trap["lane"], 0.67, 1 - side)
			p.y += float(traps[side].find(trap) % 3 - 1) * 13.0
			arena.draw_circle(p + Vector2(0, 5), 12, Color("142c35", 0.6))
			arena.draw_circle(p, 10, [Color("bdb7a9"), Color("e5ac4e"), Color("a8a0cf")][trap["kind"]])
			arena.draw_circle(p + Vector2(-3, -3), 3, Color("fff2cb"))
	for unit in units:
		var p := _point(unit["lane"], clampf(unit["position"], 0.0, 1.0), unit["side"])
		var bob := sin(visual_time * 10.0 + float(unit["position"]) * 12.0) * 2.0
		var color := Color("69c9ff") if unit["side"] == 0 else Color("ff8c96")
		_draw_character(p + Vector2(0, bob), color, unit)
	for i in 9:
		var gx := center.x + sin(float(i) * 5.12 + visual_time * 0.7) * w * 0.65
		var gy := center.y + cos(float(i) * 4.73 + visual_time * 0.4) * h * 0.48
		arena.draw_circle(Vector2(gx, gy), 2.2, Color("ffdf7a", 0.6))

func _draw_fort(p: Vector2, color: Color, side: int) -> void:
	arena.draw_circle(p + Vector2(0, 24), 30, Color("101d2a", 0.5))
	arena.draw_rect(Rect2(p + Vector2(-24, -38), Vector2(48, 62)), color)
	arena.draw_rect(Rect2(p + Vector2(-18, -32), Vector2(36, 50)), color.lightened(0.24))
	arena.draw_colored_polygon(PackedVector2Array([p + Vector2(-31, -38), p + Vector2(0, -70), p + Vector2(31, -38)]), color.darkened(0.38))
	arena.draw_rect(Rect2(p + Vector2(-8, -9), Vector2(16, 32)), Color("182538"))
	arena.draw_circle(p + Vector2(0, -20), 7, Color("ffdf81", 0.85))
	for x in [-18, 18]:
		arena.draw_rect(Rect2(p + Vector2(x - 5, -47), Vector2(10, 12)), color.lightened(0.4))

func _draw_character(p: Vector2, color: Color, unit: Dictionary) -> void:
	var radius := 13.0 if unit["kind"] == 1 else 10.0
	arena.draw_circle(p + Vector2(0, 10), radius, Color("101c27", 0.55))
	arena.draw_circle(p + Vector2(0, 1), radius, color.darkened(0.22))
	arena.draw_circle(p + Vector2(0, -8), radius * 0.8, Color("f0c4a2"))
	arena.draw_colored_polygon(PackedVector2Array([p + Vector2(-radius, -9), p + Vector2(0, -radius - 15), p + Vector2(radius, -9)]), color.darkened(0.48))
	arena.draw_circle(p + Vector2(-3, -8), 1.5, Color("1d2534"))
	arena.draw_circle(p + Vector2(3, -8), 1.5, Color("1d2534"))
	if unit["carried"] > 0:
		arena.draw_circle(p + Vector2(12, -13), 7, Color("eebc48"))
		arena.draw_circle(p + Vector2(10, -16), 2, Color("fff2a4"))
