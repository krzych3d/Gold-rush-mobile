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
var overview_mode := true
var expanded_map := false
var gameplay_panel: VBoxContainer
var map_toggle_button: Button
var camera_controls_row: HBoxContainer
# True 2:1 diamond projection: world X/Y become screen diagonal axes.
const ISO_X := Vector2(1.0, 0.0)
const ISO_Y := Vector2(0.0, 1.0)
const WORLD_HALF_LENGTH := 1050.0
var dragging_map := false
var drag_distance := 0.0
var camera_hint: Label
var touch_points: Dictionary = {}
var last_pinch_distance := 0.0
var terrain_details: Array = []
var hit_sparks: Array = []
var fallen_actors: Array = []
var pine_texture: Texture2D = preload("res://assets/world/enchanted_pine.svg")
var crystal_texture: Texture2D = preload("res://assets/world/arcane_crystal.svg")
var dwarf_texture: Texture2D = preload("res://assets/world/dwarf_guard.svg")
var goblin_texture: Texture2D = preload("res://assets/world/goblin_raider.svg")
var vault_texture: Texture2D = preload("res://assets/world/royal_vault.svg")
var bridge_texture: Texture2D = preload("res://assets/world/ancient_bridge.svg")
var road_texture: Texture2D = preload("res://assets/world/stone_path.svg")
var elf_texture: Texture2D = preload("res://assets/world/elf_ranger.svg")
var void_texture: Texture2D = preload("res://assets/world/void_assassin.svg")
var waterfall_texture: Texture2D = preload("res://assets/world/waterfall.svg")
var ground_texture: Texture2D = preload("res://assets/world/enchanted_ground.svg")
var valley_texture: Texture2D = preload("res://assets/world/epic_valley.svg")
var epic_battlefield_texture: Texture2D = preload("res://assets/epic/world/battlefield_clean.jpg")
var sprite_dwarf_defender: Texture2D = preload("res://assets/epic/units/dwarf_defender.png")
var sprite_dwarf_carrier: Texture2D = preload("res://assets/epic/units/dwarf_carrier.png")
var sprite_elf_ranger: Texture2D = preload("res://assets/epic/units/elf_ranger.png")
var sprite_arcane_mage: Texture2D = preload("res://assets/epic/units/arcane_mage.png")
var sprite_goblin_raider: Texture2D = preload("res://assets/epic/units/goblin_raider.png")
var sprite_goblin_saboteur: Texture2D = preload("res://assets/epic/units/goblin_saboteur.png")
var sprite_shadow_wolf: Texture2D = preload("res://assets/epic/units/shadow_wolf.png")
var atlas_arcane_mage: Texture2D = preload("res://assets/epic/animations/arcane_mage_sheet.png")
var atlas_dwarf_carrier: Texture2D = preload("res://assets/epic/animations/dwarf_carrier_sheet.png")
var atlas_dwarf_defender: Texture2D = preload("res://assets/epic/animations/dwarf_defender_sheet.png")
var atlas_elf_ranger: Texture2D = preload("res://assets/epic/animations/elf_ranger_sheet.png")
var atlas_goblin_raider: Texture2D = preload("res://assets/epic/animations/goblin_raider_sheet.png")
var atlas_goblin_saboteur: Texture2D = preload("res://assets/epic/animations/goblin_saboteur_sheet.png")
var atlas_shadow_wolf: Texture2D = preload("res://assets/epic/animations/shadow_wolf_sheet.png")
var cliff_texture: Texture2D = preload("res://assets/world/mossy_cliff.svg")
var grove_texture: Texture2D = preload("res://assets/world/moonlit_grove.svg")
var shrine_texture: Texture2D = preload("res://assets/world/ancient_shrine.svg")
var banner_texture: Texture2D = preload("res://assets/world/war_banner.svg")

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
	arena.custom_minimum_size = Vector2(0, 300)
	arena.clip_contents = true
	arena.size_flags_vertical = Control.SIZE_EXPAND_FILL
	arena.draw.connect(_draw_arena)
	root.add_child(arena)
	arena.mouse_filter = Control.MOUSE_FILTER_STOP
	arena.gui_input.connect(_arena_input)
	arena.resized.connect(_on_arena_resized)
	camera_hint = Label.new()
	camera_hint.text = "THREE LANES • TAP A ROAD TO SELECT"
	camera_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(camera_hint, 15, Color("a9c7d8"))
	root.add_child(camera_hint)
	camera_hint.visible = false
	var camera_controls := HBoxContainer.new()
	camera_controls_row = camera_controls
	root.add_child(camera_controls)
	camera_controls.visible = false
	for label in ["−", "FIT MAP", "+", "EXPAND"]:
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
		elif label == "EXPAND":
			map_toggle_button = control
			control.pressed.connect(_toggle_map_expanded)
		else:
			control.pressed.connect(_center_camera)
	gameplay_panel = VBoxContainer.new()
	root.add_child(gameplay_panel)
	info = Label.new()
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.custom_minimum_size.y = 32
	gameplay_panel.add_child(info)
	_style_label(info, 18, Color("f0e7cf"))
	race_button = Button.new()
	race_button.text = "CHOOSE YOUR RACE"
	race_button.custom_minimum_size.y = 0
	race_button.visible = false
	gameplay_panel.add_child(race_button)
	_style_button(race_button, true)
	race_button.disabled = true
	for labels in [["LANE 1", "LANE 2", "LANE 3"], ["RUNNER 75", "CARRIER 140", "SABOTEUR 110"], ["SPIKES 55", "SNARE 75", "TURRET 155"]]:
		var row := HBoxContainer.new()
		gameplay_panel.add_child(row)
		for index in 3:
			var button := Button.new()
			button.text = labels[index]
			button.custom_minimum_size.y = 40
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
	guard_button.custom_minimum_size.y = 40
	guard_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gameplay_panel.add_child(guard_button)
	_style_button(guard_button, true)
	guard_button.pressed.connect(_buy_guard)
	var economy_row := HBoxContainer.new()
	gameplay_panel.add_child(economy_row)
	invest_button = Button.new()
	invest_button.text = "UPGRADE BANK"
	invest_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	invest_button.custom_minimum_size.y = 40
	_style_button(invest_button, true)
	economy_row.add_child(invest_button)
	invest_button.pressed.connect(_upgrade_bank)
	raid_button = Button.new()
	raid_button.text = "RAID BOOST"
	raid_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	raid_button.custom_minimum_size.y = 40
	_style_button(raid_button, true)
	economy_row.add_child(raid_button)
	raid_button.pressed.connect(_buy_raid_boost)
	var start := Button.new()
	start.text = "START ATTACK"
	start.custom_minimum_size.y = 46
	gameplay_panel.add_child(start)
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
		frame.bg_color = Color("0b1426", 0.94)
		frame.border_color = RACE_COLORS[i]
		frame.set_border_width_all(2)
		frame.set_corner_radius_all(8)
		frame.set_content_margin_all(2)
		card.add_theme_stylebox_override("panel", frame)
		cards.add_child(card)
		faction_cards.append(card)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 9)
		card.add_child(row)
		var portrait := TextureRect.new()
		portrait.custom_minimum_size = Vector2(195, 150)
		portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		portrait.size_flags_stretch_ratio = 1.0
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		var epic_portrait_path: String = "res://assets/epic/portraits/%s.jpg" % str(RACE_NAMES[i]).to_lower()
		portrait.texture = load(epic_portrait_path) if ResourceLoader.exists(epic_portrait_path) else load("res://assets/factions/" + RACE_NAMES[i].to_lower() + "_epic.svg")
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
			hit_sparks.append({"p": _point(int(target["lane"]), clampf(float(target["position"]), 0.0, 1.0), int(target["side"])), "life": 0.5, "friendly": int(guard["side"]) == 0})
			guard["cooldown"] = 0.9
			if float(target["health"]) <= 0.0:
				_record_fallen(target)
				if int(target["carried"]) > 0:
					gold[int(guard["side"])] += int(target["carried"])
				units.erase(target)
		for unit in units:
			if int(unit["side"]) == int(guard["side"]) or int(unit["lane"]) != int(guard["lane"]):
				continue
			var up: Vector2 = _point(int(unit["lane"]), clampf(float(unit["position"]), 0.0, 1.0), int(unit["side"]))
			if gp.distance_to(up) < 48.0:
				guard["health"] -= (9.0 if int(unit["kind"]) == -1 else 14.0) * dt

func _record_fallen(data: Dictionary) -> void:
	fallen_actors.append({"side": int(data["side"]), "kind": int(data["kind"]), "lane": int(data["lane"]), "position": float(data["position"]), "age": 0.0})
	if fallen_actors.size() > 30:
		fallen_actors.pop_front()

func _draw_health_bar(p: Vector2, health: float, max_health: float, friendly: bool, width: float = 34.0) -> void:
	var ratio: float = clampf(health / maxf(max_health, 1.0), 0.0, 1.0)
	var top_left := p + Vector2(-width * 0.5, -82)
	arena.draw_rect(Rect2(top_left - Vector2(2, 2), Vector2(width + 4, 12)), Color("08111c"))
	arena.draw_rect(Rect2(top_left, Vector2(width, 8)), Color("542f37"))
	arena.draw_rect(Rect2(top_left, Vector2(width * ratio, 8)), Color("55e98b") if friendly else Color("ff6976"))

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
	for fallen in fallen_actors.duplicate():
		fallen["age"] = float(fallen["age"]) + dt
		if float(fallen["age"]) >= 0.8:
			fallen_actors.erase(fallen)
	for spark in hit_sparks.duplicate():
		spark["life"] = float(spark["life"]) - dt
		if float(spark["life"]) <= 0.0:
			hit_sparks.erase(spark)
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
			_record_fallen(unit)
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
	info.text = "LANE %d  •  %s  •  UNITS %d  •  TRAPS %d" % [lane + 1, message, orders[0].size(), traps[0].size()]
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
	var t: float = progress if side == 0 else 1.0 - progress
	var x: float = lerpf(-WORLD_HALF_LENGTH, WORLD_HALF_LENGTH, t)
	var lane_y: float = -200.0 + float(path) * 245.0
	return Vector2(x, lane_y)

func _iso_project(world: Vector2) -> Vector2:
	return ISO_X * world.x + ISO_Y * world.y

func _iso_unproject(screen: Vector2) -> Vector2:
	return screen

func _iso_transform() -> Transform2D:
	return Transform2D(ISO_X * camera_zoom, ISO_Y * camera_zoom, arena.size * 0.5 + camera_offset)

func _sprite_transform(p: Vector2, rotation: float = 0.0) -> Transform2D:
	# Billboard sprites stay upright while their feet occupy isometric ground.
	var sprite_basis := Transform2D(rotation, Vector2.ONE * camera_zoom)
	sprite_basis.origin = arena.size * 0.5 + camera_offset + _iso_project(p) * camera_zoom
	return sprite_basis

func _draw_iso_sprite(texture: Texture2D, p: Vector2, size: Vector2, tint: Color = Color.WHITE) -> void:
	arena.draw_set_transform_matrix(_sprite_transform(p))
	arena.draw_texture_rect(texture, Rect2(Vector2(-size.x * 0.5, -size.y), size), false, tint)
	arena.draw_set_transform_matrix(_iso_transform())

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

func _on_arena_resized() -> void:
	if overview_mode:
		call_deferred("_fit_map")

func _fit_map() -> void:
	# Fixed camera: fit the complete painted map, including both castles.
	camera_zoom = maxf(0.01, minf(arena.size.x / 2400.0, arena.size.y / 1060.0))
	camera_offset = Vector2.ZERO
	overview_mode = true
	arena.queue_redraw()

func _center_camera() -> void:
	_fit_map()

func _toggle_map_expanded() -> void:
	expanded_map = not expanded_map
	gameplay_panel.visible = not expanded_map
	map_toggle_button.text = "CONTROLS" if expanded_map else "EXPAND"
	call_deferred("_fit_map")

func _change_zoom(delta: float) -> void:
	camera_zoom = clampf(camera_zoom + delta, 0.12, 2.25)
	overview_mode = false
	arena.queue_redraw()

func _arena_input(event: InputEvent) -> void:
	# Single static overview; tapping a road selects a lane.
	if event is InputEventScreenTouch and not event.pressed:
		_select_lane(_nearest_lane(event.position))
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_lane(_nearest_lane(event.position))

func _nearest_lane(screen_position: Vector2) -> int:
	var world: Vector2 = _iso_unproject((screen_position - arena.size * 0.5 - camera_offset) / camera_zoom)
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
	for i in 60:
		var p := Vector2(seeded.randf_range(-1200.0, 1200.0), seeded.randf_range(-820.0, 820.0))
		var closest: float = INF
		for path in 3:
			for step in 21:
				closest = minf(closest, p.distance_to(_point(path, float(step) / 20.0, 0)))
		if closest < 260.0:
			continue
		terrain_details.append({"p": p, "seed": float(i), "type": i % 23, "scale": seeded.randf_range(0.38, 0.76)})
	terrain_details.sort_custom(func(a, b): return _iso_project(a["p"]).y < _iso_project(b["p"]).y)

func _in_camera(p: Vector2, margin: float = 100.0) -> bool:
	var projected: Vector2 = _iso_project(p) * camera_zoom + camera_offset
	return absf(projected.x) < arena.size.x * 0.5 + margin * camera_zoom and absf(projected.y) < arena.size.y * 0.5 + margin * camera_zoom

func _draw_arena() -> void:
	var center := arena.size * 0.5
	var w: float = arena.size.x * 0.85
	var h: float = arena.size.y * 0.68
	# Fill the tall phone viewport with a dimmed scenic continuation.
	# The crisp, fully visible battlefield is drawn above in world coordinates.
	arena.draw_texture_rect(epic_battlefield_texture, Rect2(Vector2.ZERO, arena.size), false, Color(0.25, 0.36, 0.43, 0.55))
	arena.draw_rect(Rect2(Vector2.ZERO, arena.size), Color("071421", 0.42))
	arena.draw_set_transform_matrix(_iso_transform())
	center = Vector2.ZERO
	# The battlefield is now one high-detail painting. Never draw the old
	# geometric river, bridges, trees, roads or duplicate castles over it.
	arena.draw_texture_rect(epic_battlefield_texture, Rect2(Vector2(-1200, -530), Vector2(2400, 1060)), false)
	# Subtle animated magic and river glints. These do not obscure the lanes.
	for i in 18:
		var phase_shift: float = float(i) * 1.618
		var water_y: float = -440.0 + fposmod(float(i) * 67.0 + visual_time * 21.0, 880.0)
		var water_x: float = sin(water_y * 0.008) * 36.0
		var water_pos := Vector2(water_x, water_y)
		var shimmer: float = 0.20 + 0.15 * sin(visual_time * 3.0 + phase_shift)
		arena.draw_line(water_pos - Vector2(12, 0), water_pos + Vector2(12, 0), Color(0.64, 0.96, 1.0, shimmer), 2.0)
	for i in 24:
		var seed: float = float(i) * 2.399
		var px: float = -1130.0 + fposmod(float(i) * 167.0, 2260.0)
		var py: float = -450.0 + fposmod(float(i) * 103.0 + sin(visual_time * 0.8 + seed) * 18.0, 900.0)
		var glow: float = 0.35 + 0.3 * sin(visual_time * 1.9 + seed)
		arena.draw_circle(Vector2(px, py), 2.4 + glow, Color(1.0, 0.79, 0.38, glow))
	for side in 2:
		var fort := _point(1, 0, side)
		var base_color := Color("4f86bf") if side == 0 else Color("ad5265")
		# Fortresses are already painted into the background. Add pulsing
		# vault aura only, keeping the castle illustration unobstructed.
		var aura := Color("8ad7ff") if side == 0 else Color("ff8a73")
		var aura_alpha: float = 0.10 + 0.06 * sin(visual_time * 2.0 + float(side))
		arena.draw_arc(fort + Vector2(0, -35), 56.0, 0.0, TAU, 40, Color(aura.r, aura.g, aura.b, aura_alpha), 4.0)
		for trap in traps[side]:
			var p := _point(trap["lane"], 0.67, 1 - side)
			p.y += float(traps[side].find(trap) % 3 - 1) * 13.0
			arena.draw_circle(p + Vector2(0, 5), 12, Color("142c35", 0.6))
			arena.draw_circle(p, 10, [Color("bdb7a9"), Color("e5ac4e"), Color("a8a0cf")][trap["kind"]])
			arena.draw_circle(p + Vector2(-3, -3), 3, Color("fff2cb"))
	# Draw combatants in depth order, including foot shadows and hit feedback.
	var actors: Array = []
	for guard in guards:
		actors.append({"p": _point(int(guard["lane"]), float(guard["position"]), int(guard["side"])), "data": guard, "guard": true, "side": int(guard["side"])})
	for unit in units:
		actors.append({"p": _point(int(unit["lane"]), clampf(float(unit["position"]), 0.0, 1.0), int(unit["side"])), "data": unit, "guard": false, "side": int(unit["side"])})
	actors.sort_custom(func(a, b): return _iso_project(a["p"]).y < _iso_project(b["p"]).y)
	for actor in actors:
		var p: Vector2 = actor["p"]
		if not _in_camera(p, 100.0):
			continue
		var data: Dictionary = actor["data"]
		var friendly: bool = int(actor["side"]) == 0
		var kind: int = 0 if actor["guard"] else int(data["kind"])
		var art: Texture2D = sprite_goblin_raider
		if friendly:
			match selected_race:
				0: art = sprite_dwarf_carrier if kind == 1 else sprite_arcane_mage if kind == 2 else sprite_dwarf_defender
				1: art = sprite_goblin_saboteur if kind == 2 else sprite_goblin_raider
				2: art = sprite_arcane_mage if kind == 2 else sprite_elf_ranger
				3: art = sprite_arcane_mage if kind == 2 else sprite_shadow_wolf
		else:
			art = sprite_shadow_wolf if kind == 1 else sprite_goblin_saboteur if kind == 2 else sprite_goblin_raider
		# Atlas rows: 0 idle, 1 walk, 2 attack, 3 hit, 4 defeat.
		# Seamless 128px frames, 8 frames per action; mobile palette optimized.
		var atlas: Texture2D = atlas_goblin_raider
		if art == sprite_dwarf_defender:
			atlas = atlas_dwarf_defender
		elif art == sprite_dwarf_carrier:
			atlas = atlas_dwarf_carrier
		elif art == sprite_elf_ranger:
			atlas = atlas_elf_ranger
		elif art == sprite_arcane_mage:
			atlas = atlas_arcane_mage
		elif art == sprite_goblin_saboteur:
			atlas = atlas_goblin_saboteur
		elif art == sprite_shadow_wolf:
			atlas = atlas_shadow_wolf
		var animation_row: int = 0
		if not actor["guard"] and phase == "ATTACK":
			animation_row = 1
		if float(data.get("stunned", 0.0)) > 0.0:
			animation_row = 3
		elif phase == "ATTACK":
			for opponent in units:
				if int(opponent["side"]) == int(actor["side"]) or int(opponent["lane"]) != int(data["lane"]):
					continue
				var opponent_p: Vector2 = _point(int(opponent["lane"]), float(opponent["position"]), int(opponent["side"]))
				if p.distance_to(opponent_p) < 125.0:
					animation_row = 2
					break
		var fps: float = 7.0 if animation_row == 0 else 12.0 if animation_row == 1 else 14.0
		var frame_offset: float = float(int(data["lane"]) * 3 + int(actor["side"]) * 5 + kind)
		var animation_frame: int = int(floor(visual_time * fps + frame_offset)) % 8
		# Movement-aware animation: idle breathing, two-step gait and hit recoil.
		var moving: bool = not bool(actor["guard"]) and phase == "ATTACK" and float(data.get("stunned", 0.0)) <= 0.0
		var pace: float = 12.5 if kind == 0 else 7.5 if kind == 1 else 10.0
		var walk_phase: float = visual_time * (pace if moving else 2.4) + float(data["position"]) * 21.0
		var stride: float = sin(walk_phase)
		var lift: float = absf(stride) * (5.0 if moving else 0.7)
		var squash: float = 1.0 + (0.045 if moving else 0.012) * cos(walk_phase * 2.0)
		var bob: float = -lift
		var scale_factor: float = 1.16 if actor["guard"] else 1.0
		var tilt: float = stride * (0.07 if moving else 0.018)
		var facing: float = 1.0 if friendly else -1.0
		if not actor["guard"] and bool(data.get("returning", false)):
			facing = -facing
		var staggered: bool = not actor["guard"] and float(data.get("stunned", 0.0)) > 0.0
		if staggered:
			tilt = 0.16 * sin(visual_time * 17.0)
			bob = 1.5
		var shadow_scale: float = 1.0 - lift * 0.024
		arena.draw_circle(p + Vector2(0, 9), 23.0 * scale_factor * shadow_scale, Color("071924", 0.36))
		if moving and stride > 0.82:
			var dust: float = (stride - 0.82) / 0.18
			arena.draw_circle(p + Vector2(-facing * 15.0, 5.0), 3.0 + dust * 4.0, Color(0.85, 0.77, 0.58, dust * 0.28))
		var art_size := Vector2(105, 112) * scale_factor
		var sprite_scale := Vector2(facing * squash, 1.0 / squash)
		var animation_transform := Transform2D(tilt, sprite_scale * camera_zoom)
		animation_transform.origin = arena.size * 0.5 + camera_offset + _iso_project(p) * camera_zoom
		arena.draw_set_transform_matrix(animation_transform)
		arena.draw_texture_rect_region(atlas, Rect2(Vector2(-art_size.x * 0.5, -art_size.y + bob), art_size), Rect2(Vector2(float(animation_frame * 128), float(animation_row * 128)), Vector2(128, 128)))
		arena.draw_set_transform_matrix(_iso_transform())
		if actor["guard"]:
			arena.draw_arc(p + Vector2(0, 6), 22.0, 0.0, TAU, 24, Color("e6c47b", 0.55) if friendly else Color("ee6678", 0.55), 2.5)
		_draw_health_bar(p + Vector2(0, bob), float(data["health"]), float(data["max_health"]), friendly, 42.0 if actor["guard"] else 34.0)
		# Animated weapon glints and combat trails while raiders are fighting.
		if phase == "ATTACK" and not actor["guard"]:
			var strike: float = sin(visual_time * 12.0 + float(data["position"]) * 23.0)
			if strike > 0.72:
				var fx_color := Color("78ddff", 0.72) if friendly else Color("ff996e", 0.72)
				var weapon_tip := p + Vector2(18.0 if friendly else -18.0, -20.0)
				arena.draw_arc(weapon_tip, 14.0, -1.1, 1.3, 14, fx_color, 2.6)
				arena.draw_circle(weapon_tip, 3.5, fx_color)
	# Play the defeat row once before removing fallen units from the screen.
	for fallen in fallen_actors:
		var death_p: Vector2 = _point(int(fallen["lane"]), float(fallen["position"]), int(fallen["side"]))
		if not _in_camera(death_p, 100.0):
			continue
		var death_atlas: Texture2D = atlas_goblin_raider
		if int(fallen["side"]) == 0:
			match selected_race:
				0: death_atlas = atlas_dwarf_carrier if int(fallen["kind"]) == 1 else atlas_arcane_mage if int(fallen["kind"]) == 2 else atlas_dwarf_defender
				1: death_atlas = atlas_goblin_saboteur if int(fallen["kind"]) == 2 else atlas_goblin_raider
				2: death_atlas = atlas_arcane_mage if int(fallen["kind"]) == 2 else atlas_elf_ranger
				3: death_atlas = atlas_arcane_mage if int(fallen["kind"]) == 2 else atlas_shadow_wolf
		else:
			death_atlas = atlas_shadow_wolf if int(fallen["kind"]) == 1 else atlas_goblin_saboteur if int(fallen["kind"]) == 2 else atlas_goblin_raider
		var death_frame: int = mini(7, int(float(fallen["age"]) * 10.0))
		arena.draw_set_transform_matrix(_sprite_transform(death_p))
		arena.draw_texture_rect_region(death_atlas, Rect2(Vector2(-52, -112), Vector2(105, 112)), Rect2(Vector2(float(death_frame * 128), 512.0), Vector2(128, 128)))
		arena.draw_set_transform_matrix(_iso_transform())
	for spark in hit_sparks:
		var p: Vector2 = spark["p"]
		var life: float = float(spark["life"]) / 0.5
		var color := Color("ffdd8c") if spark["friendly"] else Color("ff748f")
		arena.draw_circle(p + Vector2(0, -29), 23.0 * (1.0 - life), Color(color.r, color.g, color.b, life * 0.2))
		for k in 6:
			var angle: float = TAU * float(k) / 6.0 + visual_time
			var direction := Vector2(cos(angle), sin(angle))
			arena.draw_line(p + Vector2(0, -29) + direction * 7.0, p + Vector2(0, -29) + direction * (10.0 + (1.0 - life) * 23.0), Color(color.r, color.g, color.b, life), 2.5)
	for i in 9:
		var gx := center.x + sin(float(i) * 5.12 + visual_time * 0.7) * w * 0.65
		var gy := center.y + cos(float(i) * 4.73 + visual_time * 0.4) * h * 0.48
		arena.draw_circle(Vector2(gx, gy), 2.2, Color("ffdf7a", 0.6))
	arena.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# No minimap: the entire battlefield is always visible.

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
			points.append(origin + Vector2(58, 51) + _iso_project(world) / 23.0)
		arena.draw_polyline(points, Color("cfb88a"), 3.0, true)
	arena.draw_circle(origin + Vector2(10, 51), 5, Color("7ab6ff"))
	arena.draw_circle(origin + Vector2(106, 51), 5, Color("ff7b9b"))
	var viewport_center: Vector2 = _iso_unproject(-camera_offset / camera_zoom)
	var camera_marker := origin + Vector2(58, 51) + _iso_project(viewport_center) / 23.0
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
	_draw_iso_sprite(pine_texture, p, Vector2(size * 0.72, size))

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
	_draw_iso_sprite(crystal_texture, p, Vector2(54, 70) * pulse)

func _draw_fort(p: Vector2, color: Color, side: int) -> void:
	var glow := Color("f9d786") if side == 0 else Color("e88af1")
	# Render detailed fantasy vault artwork in the battlefield world.
	arena.draw_circle(p + Vector2(0, -70), 83, Color(glow.r, glow.g, glow.b, 0.10))
	_draw_iso_sprite(vault_texture, p + Vector2(0, 48), Vector2(250, 250), Color("ffffff") if side == 0 else Color("ffc0bd"))

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
