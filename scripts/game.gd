extends Control

const MAX_WAVES := 999
const RACE_NAMES := ["DWARVES", "GOBLINS", "ELVES", "VOIDBORN"]
const RACE_DESCRIPTIONS := ["Ironbeards - 28% vault interest, heavy armor and fortifications", "Green Shadows - 18% interest, fast raids and escapes", "Moon Guardians - 18% interest, magic and extra loot", "Astral Assassins - 18% interest, swift strikes and rich hauls"]
const RACE_COLORS := [Color("d7a85c"), Color("78c978"), Color("a6dfff"), Color("ba8aff")]
const PREP_TIME := 30.0
const ATTACK_TIME := 60.0
const COSTS := [75, 140, 110]
const LOOTS := [50, 160, 40]
const HP := [45.0, 180.0, 75.0]
const SPEED := [0.21, 0.105, 0.15]
const TRAP_COSTS := [55, 75, 155]
const GUARD_COST := 130
const GUARD_HP := 190.0

var selected_race := 0
var wave := 1
var phase := "SELECT"
var remaining := PREP_TIME
var gold := [1000, 1000]
var interest_last := [0, 0]
var bank_level := 0
var invest_button: Button
var raid_button: Button
var raid_boost := 0
var victory_reason := ""
var lane := 1
var orders: Array = [[], []]
var traps: Array = [[], []]
var units: Array = []
var guards: Array = []
var guard_button: Button
var rng := RandomNumberGenerator.new()
var message := "Build your army with coins. Protect your vault!"
var hud: Label
var timer_label: Label
var info: Label
var arena: Control
var controls: Array[Button] = []
var visual_time := 0.0
var title_label: Label
var race_button: Button
var selection_layer: ColorRect
var faction_cards: Array[PanelContainer] = []
var camera_offset := Vector2.ZERO
var camera_zoom := 1.0
var dragging_map := false
var drag_distance := 0.0
var camera_hint: Label
var touch_points: Dictionary = {}
var last_pinch_distance := 0.0
var terrain_details: Array = []
var pine_texture: Texture2D = preload("res://assets/world/enchanted_pine.svg")
var crystal_texture: Texture2D = preload("res://assets/world/arcane_crystal.svg")
var dwarf_texture: Texture2D = preload("res://assets/world/dwarf_guard.svg")
var goblin_texture: Texture2D = preload("res://assets/world/goblin_raider.svg")

func _ready() -> void:
	rng.randomize()
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var title := Label.new()
	title_label = title
	title.text = "VAULT WARS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	root.add_child(title)
	_style_label(title, 26, Color("ffe2a0"))
	hud = Label.new()
	hud.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(hud)
	_style_label(hud, 22, Color("f8d37c"))
	timer_label = Label.new()
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(timer_label)
	_style_label(timer_label, 19, Color("d5e8fa"))
	arena = Control.new()
	arena.custom_minimum_size = Vector2(0, 450)
	arena.clip_contents = true
	arena.size_flags_vertical = Control.SIZE_EXPAND_FILL
	arena.draw.connect(_draw_arena)
	root.add_child(arena)
	arena.mouse_filter = Control.MOUSE_FILTER_STOP
	arena.gui_input.connect(_arena_input)
	camera_hint = Label.new()
	camera_hint.text = "DRAG TO PAN  •  PINCH TO ZOOM"
	camera_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(camera_hint, 15, Color("a9c7d8"))
	root.add_child(camera_hint)
	var camera_controls := HBoxContainer.new()
	root.add_child(camera_controls)
	for label in ["−", "CENTER", "+"]:
		var control := Button.new()
		control.text = label
		control.custom_minimum_size.y = 34
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_style_button(control, true)
		camera_controls.add_child(control)
		if label == "−":
			control.pressed.connect(_change_zoom.bind(-0.15))
		elif label == "+":
			control.pressed.connect(_change_zoom.bind(0.15))
		else:
			control.pressed.connect(_center_camera)
	info = Label.new()
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.custom_minimum_size.y = 48
	root.add_child(info)
	_style_label(info, 18, Color("f0e7cf"))
	race_button = Button.new()
	race_button.text = "CHOOSE YOUR RACE"
	race_button.custom_minimum_size.y = 0
	race_button.visible = false
	root.add_child(race_button)
	_style_button(race_button, true)
	race_button.disabled = true
	for labels in [["LANE 1", "LANE 2", "LANE 3"], ["RUNNER 75", "CARRIER 140", "SABOTEUR 110"], ["SPIKES 55", "SNARE 75", "TURRET 155"]]:
		var row := HBoxContainer.new()
		root.add_child(row)
		for index in 3:
			var button := Button.new()
			button.text = labels[index]
			button.custom_minimum_size.y = 51
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
	guard_button = Button.new()
	guard_button.text = "HIRE DEFENDER 130"
	guard_button.custom_minimum_size.y = 48
	guard_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(guard_button)
	_style_button(guard_button, true)
	guard_button.pressed.connect(_buy_guard)
	var economy_row := HBoxContainer.new()
	root.add_child(economy_row)
	invest_button = Button.new()
	invest_button.text = "UPGRADE BANK"
	invest_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	invest_button.custom_minimum_size.y = 48
	_style_button(invest_button, true)
	economy_row.add_child(invest_button)
	invest_button.pressed.connect(_upgrade_bank)
	raid_button = Button.new()
	raid_button.text = "RAID BOOST"
	raid_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	raid_button.custom_minimum_size.y = 48
	_style_button(raid_button, true)
	economy_row.add_child(raid_button)
	raid_button.pressed.connect(_buy_raid_boost)
	var start := Button.new()
	start.text = "START ATTACK"
	start.custom_minimum_size.y = 60
	root.add_child(start)
	_style_button(start, false)
	controls.append(start)
	start.pressed.connect(_start_pressed)
	var clock := Timer.new()
	clock.wait_time = 0.1
	clock.timeout.connect(_tick)
	add_child(clock)
	clock.start()
	_generate_terrain_details()
	_refresh()
	_show_race_selection()

func _show_race_selection() -> void:
	selection_layer = ColorRect.new()
	selection_layer.color = Color("0a1020")
	faction_cards.clear()
	selection_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(selection_layer)
	var background := TextureRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.texture = load("res://assets/factions/enchanted_menu.svg")
	background.modulate = Color(0.78, 0.83, 0.94, 0.9)
	selection_layer.add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	selection_layer.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 7)
	margin.add_child(column)
	var title := Label.new()
	title.text = "GOLD RUSH"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(title, 43, Color("ffd579"))
	column.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "VAULT WARS  •  CHOOSE YOUR RACE"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(subtitle, 20, Color("e8d3a8"))
	column.add_child(subtitle)
	var cards := VBoxContainer.new()
	cards.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cards.add_theme_constant_override("separation", 7)
	column.add_child(cards)
	for i in 4:
		var card := PanelContainer.new()
		card.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var frame := StyleBoxFlat.new()
		frame.bg_color = Color("131c30")
		frame.border_color = RACE_COLORS[i]
		frame.set_border_width_all(2)
		frame.set_corner_radius_all(15)
		frame.set_content_margin_all(4)
		card.add_theme_stylebox_override("panel", frame)
		cards.add_child(card)
		faction_cards.append(card)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 9)
		card.add_child(row)
		var portrait := TextureRect.new()
		portrait.custom_minimum_size = Vector2(175, 150)
		portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		portrait.size_flags_stretch_ratio = 1.0
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		portrait.texture = load("res://assets/factions/" + RACE_NAMES[i].to_lower() + ".svg")
		row.add_child(portrait)
		var details := VBoxContainer.new()
		details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		details.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_child(details)
		var name_label := Label.new()
		name_label.text = RACE_NAMES[i]
		_style_label(name_label, 25, RACE_COLORS[i])
		details.add_child(name_label)
		var description := Label.new()
		description.text = RACE_DESCRIPTIONS[i]
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_style_label(description, 15, Color("d9e1ec"))
		details.add_child(description)
		var choose := Button.new()
		choose.text = "CHOOSE"
		choose.custom_minimum_size.y = 44
		_style_button(choose, true)
		details.add_child(choose)
		choose.pressed.connect(_preview_faction.bind(i))
	var footer := Label.new()
	footer.text = "YOUR LEGEND BEGINS HERE"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(footer, 16, Color("d8c49a"))
	column.add_child(footer)
	var confirm := Button.new()
	confirm.name = "ConfirmFaction"
	confirm.text = "PLAY BATTLE"
	confirm.custom_minimum_size.y = 66
	_style_button(confirm, false)
	column.add_child(confirm)
	confirm.pressed.connect(_confirm_faction)
	_preview_faction(0)

func _preview_faction(index: int) -> void:
	selected_race = index
	for i in faction_cards.size():
		var style := faction_cards[i].get_theme_stylebox("panel") as StyleBoxFlat
		if style != null:
			style.border_color = Color("fff2c2") if i == index else RACE_COLORS[i].darkened(0.42)
			style.set_border_width_all(5 if i == index else 2)
	var confirm := selection_layer.find_child("ConfirmFaction", true, false) as Button
	if confirm != null:
		confirm.text = "PLAY AS " + RACE_NAMES[index]
		confirm.add_theme_color_override("font_color", RACE_COLORS[index])

func _confirm_faction() -> void:
	_choose_faction(selected_race)

func _choose_faction(index: int) -> void:
	selected_race = index
	phase = "PREP"
	remaining = PREP_TIME
	message = RACE_DESCRIPTIONS[index]
	selection_layer.queue_free()
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

func _upgrade_bank() -> void:
	var cost: int = 180 + bank_level * 110
	if phase != "PREP" or bank_level >= 5 or gold[0] < cost:
		return
	gold[0] -= cost
	_check_vaults()
	bank_level += 1
	message = "BANK LEVEL %d! +4%% interest each wave." % bank_level
	_refresh()

func _buy_raid_boost() -> void:
	if phase != "PREP" or gold[0] < 120 or raid_boost >= 3:
		return
	gold[0] -= 120
	_check_vaults()
	raid_boost += 1
	message = "Raid training %d/3: faster, stronger thieves." % raid_boost
	_refresh()

func _buy_guard() -> void:
	if phase != "PREP":
		return
	var count := 0
	for guard in guards:
		if int(guard["side"]) == 0 and int(guard["lane"]) == lane:
			count += 1
	if gold[0] < GUARD_COST or count >= 3:
		message = "Need 130 vault gold; max 3 defenders per lane."
		_refresh()
		return
	gold[0] -= GUARD_COST
	guards.append({"side": 0, "lane": lane, "position": 0.19 + float(count) * 0.11, "health": GUARD_HP, "max_health": GUARD_HP, "cooldown": 0.0})
	_check_vaults()
	message = "Defender assigned to lane %d" % (lane + 1)
	_refresh()

func _guard_combat(dt: float) -> void:
	for guard in guards.duplicate():
		if float(guard["health"]) <= 0.0:
			guards.erase(guard)
			continue
		guard["cooldown"] = maxf(0.0, float(guard["cooldown"]) - dt)
		var gp: Vector2 = _point(int(guard["lane"]), float(guard["position"]), int(guard["side"]))
		var target: Dictionary = {}
		var nearest := 135.0
		for unit in units:
			if int(unit["side"]) == int(guard["side"]) or int(unit["lane"]) != int(guard["lane"]):
				continue
			var up: Vector2 = _point(int(unit["lane"]), clampf(float(unit["position"]), 0.0, 1.0), int(unit["side"]))
			var distance: float = gp.distance_to(up)
			if distance < nearest:
				nearest = distance
				target = unit
		if not target.is_empty() and float(guard["cooldown"]) <= 0.0:
			target["health"] -= 26.0
			guard["cooldown"] = 0.9
			if float(target["health"]) <= 0.0:
				if int(target["carried"]) > 0:
					gold[int(guard["side"])] += int(target["carried"])
				units.erase(target)
		for unit in units:
			if int(unit["side"]) == int(guard["side"]) or int(unit["lane"]) != int(guard["lane"]):
				continue
			var up: Vector2 = _point(int(unit["lane"]), clampf(float(unit["position"]), 0.0, 1.0), int(unit["side"]))
			if gp.distance_to(up) < 48.0:
				guard["health"] -= (9.0 if int(unit["kind"]) == -1 else 14.0) * dt

func _draw_health_bar(p: Vector2, health: float, max_health: float, friendly: bool, width: float = 34.0) -> void:
	var ratio: float = clampf(health / maxf(max_health, 1.0), 0.0, 1.0)
	var top_left := p + Vector2(-width * 0.5, -54)
	arena.draw_rect(Rect2(top_left - Vector2(2, 2), Vector2(width + 4, 10)), Color("08111c"))
	arena.draw_rect(Rect2(top_left, Vector2(width, 6)), Color("542f37"))
	arena.draw_rect(Rect2(top_left, Vector2(width * ratio, 6)), Color("55e98b") if friendly else Color("ff6976"))

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
	_check_vaults()
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
	_check_vaults()
	traps[0].append({"lane": lane, "kind": kind, "charges": [3, 2, 999][kind]})
	message = "Trap built on lane %d" % (lane + 1)
	_refresh()

func _bot_prepare() -> void:
	var budget: int = mini(400, gold[1])
	while budget >= 75 and orders[1].size() < 4:
		var kind := rng.randi_range(0, 2)
		if COSTS[kind] > budget or COSTS[kind] > gold[1]:
			break
		orders[1].append({"lane": rng.randi_range(0, 2), "kind": kind})
		gold[1] -= COSTS[kind]
		_check_vaults()
		budget -= COSTS[kind]
	if gold[1] >= GUARD_COST + 1 and guards.size() < mini(3 + wave, 9):
		var bot_lane: int = rng.randi_range(0, 2)
		var bot_count := 0
		for guard in guards:
			if int(guard["side"]) == 1 and int(guard["lane"]) == bot_lane:
				bot_count += 1
		if bot_count < 3:
			gold[1] -= GUARD_COST
			guards.append({"side": 1, "lane": bot_lane, "position": 0.19 + float(bot_count) * 0.11, "health": GUARD_HP, "max_health": GUARD_HP, "cooldown": 0.0})
	if gold[1] >= 55 and traps[1].size() < wave * 2:
		gold[1] -= 55
		_check_vaults()
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
	if side == 0:
		unit_health *= 1.0 + float(raid_boost) * 0.12
		unit_speed *= 1.0 + float(raid_boost) * 0.08
	units.append({"side": side, "lane": path, "kind": kind, "position": offset, "returning": false, "health": unit_health, "max_health": unit_health, "speed": unit_speed, "capacity": unit_capacity, "carried": 0, "stunned": 0.0, "disarmed": false, "triggered": []})

func _tick() -> void:
	if phase == "SELECT":
		return
	visual_time += 0.1
	arena.queue_redraw()
	if phase == "END":
		return
	if _check_vaults():
		_refresh()
		return
	remaining -= 0.1
	if phase == "PREP":
		if remaining <= 0.0:
			_begin_attack()
	else:
		_simulate(0.1)
		if _check_vaults():
			_refresh()
			return
		if remaining <= 0.0 or units.is_empty():
			_end_wave()
	_refresh()

func _simulate(dt: float) -> void:
	_guard_combat(dt)
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
				if _check_vaults():
					return
				unit["returning"] = true
		else:
			unit["position"] -= unit["speed"] * dt
			if unit["position"] <= 0.0:
				gold[unit["side"]] += unit["carried"]
				units.erase(unit)

func _check_vaults() -> bool:
	if phase == "END" or phase == "SELECT":
		return phase == "END"
	if gold[0] > 0 and gold[1] > 0:
		return false
	phase = "END"
	remaining = 0.0
	if gold[0] <= 0 and gold[1] <= 0:
		message = "DRAW! BOTH VAULTS ARE EMPTY"
	elif gold[1] <= 0:
		message = "VICTORY! ENEMY VAULT DESTROYED"
	else:
		message = "DEFEAT! YOUR VAULT IS EMPTY"
	victory_reason = message
	return true

func _end_wave() -> void:
	if phase != "ATTACK":
		return
	for unit in units:
		if unit["carried"] > 0:
			gold[1 - unit["side"]] += unit["carried"]
	units.clear()
	orders[0].clear()
	orders[1].clear()
	if _check_vaults():
		return
	# Vault savings compound; dwarves receive a substantial faction bonus.
	for side in 2:
		var rate: float = 0.18
		if side == 0:
			rate = 0.28 if selected_race == 0 else 0.18
			rate += float(bank_level) * 0.04
		var payout: int = maxi(20, int(floor(float(gold[side]) * rate)))
		interest_last[side] = payout
		gold[side] += payout
	wave += 1
	phase = "PREP"
	remaining = PREP_TIME
	message = "INTEREST +%d GOLD! Protect savings or invest in your army." % interest_last[0]

func _refresh() -> void:
	race_button.text = "RACE: " + RACE_NAMES[selected_race]
	race_button.disabled = true
	hud.text = "YOUR GOLD %d  •  ENEMY %d" % [gold[0], gold[1]]
	timer_label.text = "WAVE %d  |  %s  |  %02d s  |  INTEREST %d%%" % [wave, phase, int(maxf(0.0, ceilf(remaining))), (28 if selected_race == 0 else 18) + bank_level * 4]
	info.text = message + "\nLane: %d | Units: %d | Traps: %d" % [lane + 1, orders[0].size(), traps[0].size()]
	for i in range(3, 9):
		controls[i].disabled = phase != "PREP"
	guard_button.disabled = phase != "PREP" or gold[0] < GUARD_COST
	invest_button.disabled = phase != "PREP" or bank_level >= 5 or gold[0] < 180 + bank_level * 110
	raid_button.disabled = phase != "PREP" or raid_boost >= 3 or gold[0] < 120
	invest_button.text = "BANK LV%d (%d)" % [bank_level, 180 + bank_level * 110] if bank_level < 5 else "BANK MAX"
	raid_button.text = "RAID LV%d (120)" % raid_boost if raid_boost < 3 else "RAID MAX"
	controls[9].disabled = phase == "ATTACK"
	controls[9].text = "PLAY AGAIN" if phase == "END" else "UNLEASH THE RAID" if phase == "PREP" else "BATTLE IN PROGRESS"
	for i in 3:
		controls[i].modulate = Color("ffe29a") if i == lane else Color.WHITE
	arena.queue_redraw()

func _point(path: int, progress: float, side: int) -> Vector2:
	var center := Vector2.ZERO
	var t: float = progress if side == 0 else 1.0 - progress
	var x: float = lerpf(-arena.size.x * 0.75, arena.size.x * 0.75, t)
	var lane_y: float = (float(path) - 1.0) * 210.0
	var bend: float = sin(t * PI * 2.0 + float(path) * 1.35) * 45.0 * sin(t * PI)
	return center + Vector2(x, lane_y + bend)

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

func _center_camera() -> void:
	camera_offset = Vector2.ZERO
	camera_zoom = 1.0
	arena.queue_redraw()

func _change_zoom(delta: float) -> void:
	camera_zoom = clampf(camera_zoom + delta, 0.65, 2.25)
	arena.queue_redraw()

func _arena_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_points[event.index] = event.position
			dragging_map = true
			drag_distance = 0.0
		else:
			if touch_points.size() == 1 and drag_distance < 12.0:
				_select_lane(_nearest_lane(event.position))
			touch_points.erase(event.index)
			last_pinch_distance = 0.0
			dragging_map = not touch_points.is_empty()
	elif event is InputEventScreenDrag:
		if not touch_points.has(event.index):
			return
		touch_points[event.index] = event.position
		if touch_points.size() >= 2:
			var points: Array = touch_points.values()
			var distance: float = (points[0] as Vector2).distance_to(points[1] as Vector2)
			if last_pinch_distance > 0.0:
				camera_zoom = clampf(camera_zoom * distance / maxf(last_pinch_distance, 1.0), 0.65, 2.25)
			last_pinch_distance = distance
			drag_distance = 100.0
		else:
			camera_offset += event.relative
			camera_offset.x = clampf(camera_offset.x, -arena.size.x * 1.4, arena.size.x * 1.4)
			camera_offset.y = clampf(camera_offset.y, -arena.size.y * 1.4, arena.size.y * 1.4)
			drag_distance += event.relative.length()
		arena.queue_redraw()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_change_zoom(0.12)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_change_zoom(-0.12)

func _nearest_lane(screen_position: Vector2) -> int:
	var world: Vector2 = (screen_position - arena.size * 0.5 - camera_offset) / camera_zoom
	var best_lane := 0
	var best_distance := INF
	for path in 3:
		for step in 41:
			var d: float = world.distance_squared_to(_point(path, float(step) / 40.0, 0))
			if d < best_distance:
				best_distance = d
				best_lane = path
	return best_lane

func _generate_terrain_details() -> void:
	# Deterministic decoration generated once, not on every animation frame.
	terrain_details.clear()
	var seeded := RandomNumberGenerator.new()
	seeded.seed = 24681357
	for i in 460:
		var p := Vector2(seeded.randf_range(-1800.0, 1800.0), seeded.randf_range(-1300.0, 1300.0))
		var closest: float = INF
		for path in 3:
			for step in 21:
				closest = minf(closest, p.distance_to(_point(path, float(step) / 20.0, 0)))
		if closest < 85.0:
			continue
		terrain_details.append({"p": p, "seed": float(i), "type": i % 17})

func _in_camera(p: Vector2, margin: float = 100.0) -> bool:
	var half: Vector2 = arena.size * 0.5 / camera_zoom
	var center: Vector2 = -camera_offset / camera_zoom
	return absf(p.x - center.x) < half.x + margin and absf(p.y - center.y) < half.y + margin

func _draw_arena() -> void:
	var center := arena.size * 0.5
	var w: float = arena.size.x * 0.85
	var h: float = arena.size.y * 0.68
	arena.draw_rect(Rect2(Vector2.ZERO, arena.size), Color("141e32"))
	arena.draw_set_transform(arena.size * 0.5 + camera_offset, 0.0, Vector2.ONE * camera_zoom)
	center = Vector2.ZERO
	# Layered terrain: broad painted patches instead of a visible checkerboard.
	arena.draw_rect(Rect2(Vector2(-2300, -1700), Vector2(4600, 3400)), Color("253f39"))
	for i in 90:
		var sx: float = sin(float(i) * 71.37) * 1600.0
		var sy: float = cos(float(i) * 38.19) * 1200.0
		var radius: float = 95.0 + fposmod(float(i) * 23.7, 125.0)
		arena.draw_circle(Vector2(sx, sy), radius, Color("345b49", 0.38) if i % 3 == 0 else Color("43674e", 0.28))
	# Elevated rocky escarpments with lit top surfaces and dark vertical faces.
	for i in 24:
		var bx: float = sin(float(i) * 31.2) * 1300.0
		var by: float = cos(float(i) * 22.6) * 950.0
		var base := Vector2(bx, by)
		var width: float = 50.0 + fposmod(float(i) * 19.0, 65.0)
		var height: float = 22.0 + fposmod(float(i) * 11.0, 24.0)
		var top := PackedVector2Array([base + Vector2(0, -height), base + Vector2(width, 0), base + Vector2(0, height), base + Vector2(-width, 0)])
		var bottom := PackedVector2Array([base + Vector2(-width, 0), base + Vector2(0, height), base + Vector2(0, height + 22), base + Vector2(-width, 22)])
		arena.draw_colored_polygon(bottom, Color("192c2c"))
		arena.draw_colored_polygon(top, Color("4c6457") if i % 2 == 0 else Color("596e59"))
		arena.draw_line(base + Vector2(-width, 0), base + Vector2(0, -height), Color("8a9473", 0.5), 2.0)
	# A river cuts diagonally through the battlefield; lanes cross it on stone bridges.
	var river := PackedVector2Array()
	for step in 41:
		var ry: float = -1250.0 + float(step) * 62.5
		var rx: float = sin(ry / 230.0) * 100.0 + ry * 0.14
		river.append(Vector2(rx, ry))
	arena.draw_polyline(river, Color("142f3c"), 170.0, true)
	arena.draw_polyline(river, Color("285365"), 151.0, true)
	arena.draw_polyline(river, Color("397b88"), 119.0, true)
	for i in 30:
		var ry: float = -1150.0 + float(i) * 78.0
		var rx: float = sin(ry / 230.0) * 100.0 + ry * 0.14
		var ripple := Vector2(rx + sin(visual_time * 0.6 + float(i)) * 19.0, ry)
		arena.draw_arc(ripple, 13.0 + float(i % 3) * 6.0, 0.2, PI - 0.2, 12, Color("a5e7e4", 0.35), 2.0)
	# Ancient stone foundations and glowing sigils make the terrain navigable.
	for i in 9:
		var angle: float = float(i) * TAU / 9.0
		var center_ruin := Vector2(cos(angle) * 980.0, sin(angle) * 700.0)
		_draw_ruin(center_ruin, i)
	# Winding three-lane routes with cobblestone edges.
	for path in 3:
		var points := PackedVector2Array()
		for step in 41:
			points.append(_point(path, float(step) / 40.0, 0))
		arena.draw_polyline(points, Color("142b2b"), 88.0, true)
		arena.draw_polyline(points, Color("72634f"), 80.0, true)
		arena.draw_polyline(points, Color("a89571"), 70.0, true)
		arena.draw_polyline(points, Color("c4aa7b") if path == lane else Color("a78f69"), 46.0, true)
		for j in 32:
			var stone := _point(path, float(j) / 31.0, 0)
			arena.draw_line(stone + Vector2(-7, -18), stone + Vector2(6, -12), Color("665d4a", 0.5), 2.0)
			arena.draw_line(stone + Vector2(7, 9), stone + Vector2(-5, 18), Color("e1cba2", 0.32), 2.0)
	# Elevated bridges reconnect the three routes across the river.
	for path in 3:
		var crossing := _point(path, 0.5, 0)
		arena.draw_rect(Rect2(crossing + Vector2(-83, -35), Vector2(166, 70)), Color("30343a"))
		arena.draw_rect(Rect2(crossing + Vector2(-76, -41), Vector2(152, 65)), Color("9d9689"))
		for k in 7:
			var sx: float = crossing.x - 65.0 + float(k) * 21.0
			arena.draw_line(Vector2(sx, crossing.y - 38), Vector2(sx - 5.0, crossing.y + 23), Color("686c69", 0.55), 2.0)
		arena.draw_line(crossing + Vector2(-81, -37), crossing + Vector2(81, -37), Color("d9c5a0"), 6.0)
		arena.draw_line(crossing + Vector2(-81, 26), crossing + Vector2(81, 26), Color("60594f"), 6.0)
	# Forest, flowers, stones and arcane formations: render only visible props.
	for item in terrain_details:
		var p: Vector2 = item["p"]
		if not _in_camera(p, 110.0):
			continue
		var seed: float = item["seed"]
		if int(item["type"]) == 0:
			_draw_crystal(p, seed)
		elif int(item["type"]) < 12:
			_draw_tree(p, seed)
		elif int(item["type"]) < 15:
			_draw_rock(p, seed)
		else:
			_draw_flowers(p, seed)
	# Animated lanterns at strategic points along each road.
	for path in 3:
		for j in 5:
			var lamp := _point(path, float(j + 1) / 6.0, 0) + Vector2(0, -48)
			arena.draw_line(lamp, lamp + Vector2(0, -27), Color("44382e"), 4.0)
			arena.draw_circle(lamp + Vector2(0, -30), 9.0 + sin(visual_time * 2.0 + float(j)) * 1.5, Color("f6d47b", 0.3))
			arena.draw_circle(lamp + Vector2(0, -30), 4.0, Color("ffe2a1"))
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
	for guard in guards:
		var gp: Vector2 = _point(int(guard["lane"]), float(guard["position"]), int(guard["side"]))
		var friendly: bool = int(guard["side"]) == 0
		arena.draw_texture_rect(dwarf_texture if friendly else goblin_texture, Rect2(gp + Vector2(-30, -58), Vector2(60, 75)), false)
		_draw_health_bar(gp, float(guard["health"]), float(guard["max_health"]), friendly, 42)
	for unit in units:
		var p := _point(unit["lane"], clampf(unit["position"], 0.0, 1.0), unit["side"])
		var bob := sin(visual_time * 10.0 + float(unit["position"]) * 12.0) * 2.0
		var color: Color = RACE_COLORS[selected_race] if unit["side"] == 0 else Color("ff8c96")
		arena.draw_texture_rect(dwarf_texture if int(unit["side"]) == 0 else goblin_texture, Rect2(p + Vector2(-25, -50 + bob), Vector2(50, 63)), false)
		_draw_health_bar(p + Vector2(0, bob), float(unit["health"]), float(unit["max_health"]), int(unit["side"]) == 0)
	for i in 9:
		var gx := center.x + sin(float(i) * 5.12 + visual_time * 0.7) * w * 0.65
		var gy := center.y + cos(float(i) * 4.73 + visual_time * 0.4) * h * 0.48
		arena.draw_circle(Vector2(gx, gy), 2.2, Color("ffdf7a", 0.6))
	arena.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_minimap()

func _draw_minimap() -> void:
	# Fixed screen-space overview, independent from the scrolling battlefield.
	var origin := Vector2(arena.size.x - 132.0, 16.0)
	var rect := Rect2(origin, Vector2(116, 102))
	arena.draw_rect(rect.grow(4), Color("081522", 0.82))
	arena.draw_rect(rect, Color("2b5548", 0.95))
	for path in 3:
		var points := PackedVector2Array()
		for step in 25:
			var world := _point(path, float(step) / 24.0, 0)
			points.append(origin + Vector2(58, 51) + Vector2(world.x / 15.0, world.y / 11.0))
		arena.draw_polyline(points, Color("cfb88a"), 3.0, true)
	arena.draw_circle(origin + Vector2(10, 51), 5, Color("7ab6ff"))
	arena.draw_circle(origin + Vector2(106, 51), 5, Color("ff7b9b"))
	var viewport_center: Vector2 = -camera_offset / camera_zoom
	var camera_marker := origin + Vector2(58, 51) + Vector2(viewport_center.x / 15.0, viewport_center.y / 11.0)
	camera_marker.x = clampf(camera_marker.x, origin.x + 5.0, origin.x + 111.0)
	camera_marker.y = clampf(camera_marker.y, origin.y + 5.0, origin.y + 97.0)
	arena.draw_rect(Rect2(camera_marker - Vector2(6, 6), Vector2(12, 12)), Color("f9f5dc"), false, 2.0)

func _draw_rock(p: Vector2, seed: float) -> void:
	var size: float = 9.0 + fposmod(seed * 7.1, 13.0)
	arena.draw_circle(p + Vector2(5, 8), size, Color("0b2627", 0.3))
	arena.draw_colored_polygon(PackedVector2Array([p + Vector2(-size, 5), p + Vector2(-size * 0.6, -size * 0.65), p + Vector2(size * 0.35, -size), p + Vector2(size, 0), p + Vector2(size * 0.5, size * 0.55)]), Color("536b66"))
	arena.draw_line(p + Vector2(-size * 0.6, -size * 0.65), p + Vector2(size * 0.35, -size), Color("a1b3a1", 0.65), 2.0)

func _draw_flowers(p: Vector2, seed: float) -> void:
	for k in 5:
		var offset := Vector2(sin(seed + float(k) * 4.3) * 15.0, cos(seed + float(k) * 2.1) * 10.0)
		arena.draw_line(p + offset, p + offset + Vector2(0, -7), Color("548d59"), 2.0)
		arena.draw_circle(p + offset + Vector2(0, -8), 3.0, Color("f5d28b") if k % 2 == 0 else Color("b7a0e6"))

func _draw_ruin(p: Vector2, seed: int) -> void:
	var stone := Color("68716d") if seed % 2 == 0 else Color("77776b")
	arena.draw_circle(p + Vector2(12, 18), 61, Color("0c2325", 0.3))
	arena.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -36), p + Vector2(64, 0), p + Vector2(0, 32), p + Vector2(-64, 0)]), Color("444e4a"))
	arena.draw_arc(p, 44, 0.0, TAU, 32, Color("8d8875"), 6.0)
	for k in 4:
		var a: float = float(k) * TAU / 4.0 + 0.4
		var pillar := p + Vector2(cos(a) * 38.0, sin(a) * 22.0)
		arena.draw_rect(Rect2(pillar + Vector2(-9, -31), Vector2(18, 34)), stone.darkened(0.35))
		arena.draw_rect(Rect2(pillar + Vector2(-9, -36), Vector2(18, 10)), stone.lightened(0.28))
	arena.draw_arc(p, 27, visual_time * 0.25, visual_time * 0.25 + PI * 1.5, 24, Color("6ce8d4", 0.65), 3.0)
	arena.draw_circle(p, 6.0 + sin(visual_time * 2.0 + float(seed)) * 2.0, Color("a6fff0"))

func _draw_tree(p: Vector2, seed: float) -> void:
	var size: float = 85.0 + fposmod(seed * 11.0, 45.0)
	arena.draw_texture_rect(pine_texture, Rect2(p + Vector2(-size * 0.36, -size), Vector2(size * 0.72, size)), false)

func _draw_tree_parts(p: Vector2, size: float, seed: float) -> void:
	# Broadleaf crowns are layered and shaded, with visible trunks and depth.
	var sway: float = sin(visual_time * 0.85 + seed) * 2.2
	var crown := p + Vector2(sway, -size * 1.8)
	_draw_tree_canopy(p, crown, size, seed)

func _draw_tree_canopy(p: Vector2, crown: Vector2, size: float, seed: float) -> void:
	arena.draw_circle(p + Vector2(13, 12), size * 1.15, Color("0d2625", 0.42))
	arena.draw_line(p + Vector2(0, 4), crown + Vector2(0, 10), Color("59452f"), 9.0)
	var deep := Color("173b34") if int(seed) % 3 == 0 else Color("234a39")
	var mid := Color("366a4b") if int(seed) % 3 == 0 else Color("477853")
	arena.draw_circle(crown + Vector2(-size * 0.55, 5), size * 0.88, deep)
	arena.draw_circle(crown + Vector2(size * 0.58, 3), size * 0.85, deep)
	arena.draw_circle(crown + Vector2(0, -size * 0.35), size * 1.12, mid)
	arena.draw_circle(crown + Vector2(-size * 0.4, -size * 0.7), size * 0.65, Color("5e9160", 0.72))
	arena.draw_circle(crown + Vector2(size * 0.3, -size * 0.8), size * 0.42, Color("8caf71", 0.38))

func _draw_crystal(p: Vector2, seed: float) -> void:
	var pulse: float = 1.0 + sin(visual_time * 2.0 + seed) * 0.07
	arena.draw_circle(p + Vector2(0, -24), 32.0 * pulse, Color("6de7ff", 0.10))
	arena.draw_texture_rect(crystal_texture, Rect2(p + Vector2(-27, -70), Vector2(54, 70) * pulse), false)

func _draw_fort(p: Vector2, color: Color, side: int) -> void:
	var glow := Color("f9d786") if side == 0 else Color("e88af1")
	_draw_fort_body(p, color, glow)

func _draw_fort_body(p: Vector2, color: Color, glow: Color) -> void:
	# Tall isometric keep with shaded side walls, roof planes and battlements.
	arena.draw_colored_polygon(PackedVector2Array([p + Vector2(-77, 18), p + Vector2(0, 55), p + Vector2(77, 18), p + Vector2(0, -20)]), Color("102b30", 0.65))
	var foundation := PackedVector2Array([p + Vector2(0, -8), p + Vector2(62, 20), p + Vector2(0, 48), p + Vector2(-62, 20)])
	arena.draw_colored_polygon(foundation, color.darkened(0.48))
	arena.draw_colored_polygon(PackedVector2Array([p + Vector2(-52, -13), p + Vector2(0, 9), p + Vector2(0, 40), p + Vector2(-52, 17)]), color.darkened(0.34))
	arena.draw_colored_polygon(PackedVector2Array([p + Vector2(0, 9), p + Vector2(52, -13), p + Vector2(52, 17), p + Vector2(0, 40)]), color.darkened(0.57))
	arena.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -94), p + Vector2(42, -74), p + Vector2(42, -9), p + Vector2(0, 12)]), color.darkened(0.42))
	arena.draw_colored_polygon(PackedVector2Array([p + Vector2(-42, -74), p + Vector2(0, -94), p + Vector2(0, 12), p + Vector2(-42, -9)]), color.lightened(0.12))
	arena.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -124), p + Vector2(48, -93), p + Vector2(0, -69), p + Vector2(-48, -93)]), color.darkened(0.55))
	arena.draw_line(p + Vector2(0, -124), p + Vector2(-48, -93), glow, 3.0)
	arena.draw_line(p + Vector2(0, -124), p + Vector2(48, -93), glow.darkened(0.3), 3.0)
	for side in [-1, 1]:
		var x: float = float(side) * 33.0
		arena.draw_colored_polygon(PackedVector2Array([p + Vector2(x - 10, -81), p + Vector2(x + 10, -81), p + Vector2(x + 10, -100), p + Vector2(x - 10, -100)]), color.lightened(0.25))
		arena.draw_rect(Rect2(p + Vector2(x - 5, -65), Vector2(10, 20)), Color("162735"))
	arena.draw_colored_polygon(PackedVector2Array([p + Vector2(-12, -4), p + Vector2(0, -11), p + Vector2(12, -4), p + Vector2(12, 19), p + Vector2(0, 26), p + Vector2(-12, 19)]), Color("0c1a2b"))
	arena.draw_circle(p + Vector2(0, -79), 16.0 + sin(visual_time * 2.0) * 2.0, Color(glow.r, glow.g, glow.b, 0.25))
	arena.draw_circle(p + Vector2(0, -79), 7, glow)
	arena.draw_circle(p + Vector2(0, -79), 2, Color.WHITE)
	arena.draw_line(p + Vector2(-47, -13), p + Vector2(-47, 15), glow.darkened(0.35), 2.0)

func _draw_character(p: Vector2, color: Color, unit: Dictionary) -> void:
	var friendly: bool = unit["side"] == 0
	var faction: int = selected_race if friendly else 1
	var radius: float = 15.0 if unit["kind"] == 1 else 12.0
	var moving: float = sin(visual_time * 10.0 + float(unit["position"]) * 13.0)
	var cloak := color.darkened(0.48)
	arena.draw_circle(p + Vector2(0, 14), radius + 5.0, Color("0a1421", 0.5))
	# Two walking feet and a trailing cloak, distinct from circular placeholder units.
	arena.draw_line(p + Vector2(-5, 5), p + Vector2(-7 + moving * 3.0, 15), Color("292637"), 5.0)
	arena.draw_line(p + Vector2(5, 5), p + Vector2(7 - moving * 3.0, 15), Color("292637"), 5.0)
	arena.draw_colored_polygon(PackedVector2Array([p + Vector2(-radius, -7), p + Vector2(radius, -7), p + Vector2(radius + 4, 11), p + Vector2(-radius - 4, 11)]), cloak)
	arena.draw_rect(Rect2(p + Vector2(-radius + 3, -5), Vector2(radius * 2.0 - 6, 14)), color)
	arena.draw_line(p + Vector2(-radius + 3, 2), p + Vector2(radius - 3, 2), Color("e7bd73"), 3.0)
	arena.draw_circle(p + Vector2(0, -12), radius * 0.83, Color("f1c7a5") if faction != 3 else Color("2c2545"))
	match faction:
		0:
			# Dwarf: steel helm, heavy golden beard and hammer.
			arena.draw_rect(Rect2(p + Vector2(-radius, -21), Vector2(radius * 2.0, 7)), Color("aebdcc"))
			arena.draw_colored_polygon(PackedVector2Array([p + Vector2(-8, -8), p + Vector2(0, 5), p + Vector2(8, -8)]), Color("dc9749"))
			arena.draw_line(p + Vector2(radius + 4, -3), p + Vector2(radius + 8, -24), Color("b9a78b"), 3.0)
			arena.draw_rect(Rect2(p + Vector2(radius + 1, -27), Vector2(15, 8)), Color("c7d3df"))
		1:
			# Goblin: green face, long pointed ears, curved dagger.
			arena.draw_circle(p + Vector2(0, -12), radius * 0.8, Color("88bc69"))
			arena.draw_colored_polygon(PackedVector2Array([p + Vector2(-8, -15), p + Vector2(-radius - 10, -23), p + Vector2(-radius + 3, -7)]), Color("80b56b"))
			arena.draw_colored_polygon(PackedVector2Array([p + Vector2(8, -15), p + Vector2(radius + 10, -23), p + Vector2(radius - 3, -7)]), Color("80b56b"))
			arena.draw_line(p + Vector2(radius + 2, 3), p + Vector2(radius + 13, -13), Color("c8dce1"), 3.0)
		2:
			# Elf: silver circlet, pointed ears, glowing moon staff.
			arena.draw_line(p + Vector2(-radius + 3, -14), p + Vector2(-radius - 9, -23), Color("ccecff"), 4.0)
			arena.draw_line(p + Vector2(radius - 3, -14), p + Vector2(radius + 9, -23), Color("ccecff"), 4.0)
			arena.draw_arc(p + Vector2(0, -16), radius * 0.8, PI, TAU, 12, Color("e8f5ff"), 3.0)
			arena.draw_line(p + Vector2(radius + 7, -23), p + Vector2(radius + 7, 10), Color("e0f0ff"), 3.0)
			arena.draw_circle(p + Vector2(radius + 7, -25), 5.0 + sin(visual_time * 4.0) * 1.0, Color("93eaff"))
		3:
			# Voidborn: faceless hood, violet eyes and twin astral blades.
			arena.draw_colored_polygon(PackedVector2Array([p + Vector2(-radius, -13), p + Vector2(0, -radius - 23), p + Vector2(radius, -13)]), Color("302446"))
			arena.draw_line(p + Vector2(-5, -12), p + Vector2(-2, -12), Color("d69aff"), 2.0)
			arena.draw_line(p + Vector2(2, -12), p + Vector2(5, -12), Color("d69aff"), 2.0)
			arena.draw_line(p + Vector2(-radius, 4), p + Vector2(-radius - 12, -15), Color("b887ff"), 4.0)
			arena.draw_line(p + Vector2(radius, 4), p + Vector2(radius + 12, -15), Color("b887ff"), 4.0)
			arena.draw_arc(p, radius + 7.0, visual_time, visual_time + PI * 0.8, 12, Color("b66aff", 0.65), 2.0)
	if faction != 3:
		arena.draw_circle(p + Vector2(-4, -12), 1.8, Color("182234"))
		arena.draw_circle(p + Vector2(4, -12), 1.8, Color("182234"))
	if unit["carried"] > 0:
		arena.draw_circle(p + Vector2(13, -22), 8, Color("f6b83f"))
		arena.draw_circle(p + Vector2(11, -25), 3, Color("fff3b1"))
	if unit["stunned"] > 0.0:
		for i in 3:
			var a := visual_time * 4.0 + float(i) * TAU / 3.0
			arena.draw_circle(p + Vector2(cos(a) * 18.0, -24 + sin(a) * 7.0), 3, Color("fff09a"))
