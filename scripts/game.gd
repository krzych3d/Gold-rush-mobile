extends Control

const MAX_WAVES := 5
const PREP_TIME := 30.0
const ATTACK_TIME := 60.0
const COSTS := [75, 140, 110]
const LOOTS := [50, 160, 40]
const HP := [45.0, 180.0, 75.0]
const SPEED := [0.21, 0.105, 0.15]
const TRAP_COSTS := [55, 75, 155]

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

func _ready() -> void:
	rng.randomize()
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var title := Label.new()
	title.text = "GOLD RUSH: VAULT WARS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	root.add_child(title)
	hud = Label.new()
	hud.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(hud)
	timer_label = Label.new()
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(timer_label)
	arena = Control.new()
	arena.custom_minimum_size = Vector2(0, 570)
	arena.size_flags_vertical = Control.SIZE_EXPAND_FILL
	arena.draw.connect(_draw_arena)
	root.add_child(arena)
	info = Label.new()
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.custom_minimum_size.y = 72
	root.add_child(info)
	for labels in [["LANE 1", "LANE 2", "LANE 3"], ["RUNNER 75", "CARRIER 140", "SABOTEUR 110"], ["SPIKES 55", "SNARE 75", "TURRET 155"]]:
		var row := HBoxContainer.new()
		root.add_child(row)
		for index in 3:
			var button := Button.new()
			button.text = labels[index]
			button.custom_minimum_size.y = 62
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(button)
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
	controls.append(start)
	start.pressed.connect(_start_pressed)
	var clock := Timer.new()
	clock.wait_time = 0.1
	clock.timeout.connect(_tick)
	add_child(clock)
	clock.start()
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
	if gold[0] <= COSTS[kind] or orders[0].size() >= 6 or lane_count >= 4:
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
	if gold[0] <= TRAP_COSTS[kind] or lane_count >= 5:
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
	units.append({"side": side, "lane": path, "kind": kind, "position": offset, "returning": false, "health": 60.0 if kind == -1 else HP[kind], "speed": 0.145 if kind == -1 else SPEED[kind], "capacity": 25 if kind == -1 else LOOTS[kind], "carried": 0, "stunned": 0.0, "disarmed": false, "triggered": []})

func _tick() -> void:
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
	hud.text = "YOUR VAULT: %d     ENEMY: %d" % [gold[0], gold[1]]
	timer_label.text = "WAVE %d/%d | %s | %02d s" % [wave, MAX_WAVES, phase, int(maxf(0.0, ceilf(remaining)))]
	info.text = message + "\nLane: %d | Thieves: %d | Traps: %d" % [lane + 1, orders[0].size(), traps[0].size()]
	for i in range(3, 9):
		controls[i].disabled = phase != "PREP"
	controls[9].disabled = phase == "ATTACK"
	controls[9].text = "RESTART" if phase == "END" else "START ATTACK" if phase == "PREP" else "ATTACK IN PROGRESS"
	arena.queue_redraw()

func _point(path: int, progress: float, side: int) -> Vector2:
	var center := arena.size * 0.5
	var left := Vector2(-arena.size.x * 0.34, -arena.size.y * 0.12 + path * 57.0)
	var right := Vector2(arena.size.x * 0.34, -arena.size.y * 0.12 + path * 57.0)
	return center + (left.lerp(right, progress) if side == 0 else right.lerp(left, progress))

func _draw_arena() -> void:
	var center := arena.size * 0.5
	var w: float = minf(arena.size.x * 0.47, 315.0)
	var h: float = minf(arena.size.y * 0.39, 230.0)
	arena.draw_colored_polygon(PackedVector2Array([center + Vector2(0, -h), center + Vector2(w, 0), center + Vector2(0, h), center + Vector2(-w, 0)]), Color("426d4d"))
	for path in 3:
		arena.draw_line(_point(path, 0, 0), _point(path, 1, 0), Color("957d57"), 24.0, true)
		arena.draw_line(_point(path, 0, 0), _point(path, 1, 0), Color("d9c297") if path == lane else Color("bca681"), 16.0, true)
	for side in 2:
		var fort := _point(1, 0, side)
		arena.draw_rect(Rect2(fort - Vector2(23, 31), Vector2(46, 55)), Color("638fc1") if side == 0 else Color("c46b60"))
		arena.draw_colored_polygon(PackedVector2Array([fort + Vector2(-28, -31), fort + Vector2(0, -56), fort + Vector2(28, -31)]), Color("315c91") if side == 0 else Color("873d39"))
		for trap in traps[side]:
			var p := _point(trap["lane"], 0.67, 1 - side)
			p.y += float(traps[side].find(trap) % 3 - 1) * 13.0
			arena.draw_circle(p, 10.0, [Color("bdb7a9"), Color("d7a04d"), Color("5e5f66")][trap["kind"]])
	for unit in units:
		var p := _point(unit["lane"], clampf(unit["position"], 0.0, 1.0), unit["side"])
		arena.draw_circle(p, 11.0 if unit["kind"] == 1 else 7.0, Color("72c6ff") if unit["side"] == 0 else Color("ff887e"))
		if unit["carried"] > 0:
			arena.draw_circle(p + Vector2(8, -8), 4.0, Color("ffdf56"))
