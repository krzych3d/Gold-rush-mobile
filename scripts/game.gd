extends Control

const AnimationGallery = preload("res://scripts/animation_gallery.gd")
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
var ability_button: Button
var ability_used := false
const ABILITY_NAMES := ["IRON WALL", "GOBLIN FRENZY", "MOON BLESSING", "SHADOW STEP"]
var rng := RandomNumberGenerator.new()
var message := "Build your army with coins. Protect your vault!"
var hud: Label
var timer_label: Label
var info: Label
var arena: Control
var controls: Array[Button] = []
var visual_time := 0.0
var goblin_walk_prototype: Texture2D
# Optional separate, foot-aligned 192px PNG strips: idle/walk/attack/hit/carry/deposit/death.
var goblin_action_strips: Dictionary = {}
# 10 imported epic RGBA atlases are now present; trigger a fresh Android build.
# Optional 8x6 high-quality special action sheets. Base art remains playable
# until the validated ZIP has actually been imported into the repository.
var special_animation_atlases: Dictionary = {}
# Voidborn has four independent animated unit roles (guard, runner, carrier, mage).
# Dedicated high-detail variants are loaded after the validated sprite-pack import.
var void_animation_atlases: Dictionary = {}
const GOBLIN_ACTIONS := ["idle", "walk", "attack", "hit", "death", "deposit", "carry"]
const GOBLIN_ACTION_FPS := [5.0, 11.0, 12.0, 12.0, 12.0, 12.0, 11.0]
var menu_music: AudioStreamPlayer
var performance_label: Label
var performance_elapsed := 0.0
var render_elapsed := 0.0
var ui_elapsed := 0.0
var title_label: Label
var race_button: Button
var selection_layer: ColorRect
var faction_cards: Array[PanelContainer] = []
var camera_offset := Vector2.ZERO
var camera_zoom := 1.0
var overview_mode := true
var expanded_map := false
var last_icon_race := -1
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
var turret_bolts: Array = []
var turret_texture: Texture2D = preload("res://assets/ui/turret.svg")
var spikes_texture: Texture2D = preload("res://assets/ui/spikes.svg")
var snare_texture: Texture2D = preload("res://assets/ui/snare.svg")
var fallen_actors: Array = []
var deposit_actors: Array = []
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
	# Optional test atlas: keep the shipping animation when the file is absent.
	if ResourceLoader.exists("res://assets/epic/animations/Obraz ChatGPT 2 lis 2026, 22_37_21.png"):
		goblin_walk_prototype = load("res://assets/epic/animations/Obraz ChatGPT 2 lis 2026, 22_37_21.png") as Texture2D
	for action in GOBLIN_ACTIONS:
		var path: String = "res://assets/epic/animations/goblin_raider_%s.png" % action
		if ResourceLoader.exists(path):
			var strip := load(path) as Texture2D
			if strip != null and strip.get_height() == 192 and strip.get_width() >= 192 and strip.get_width() % 192 == 0:
				goblin_action_strips[action] = strip
	for name in ["goblin_raider", "shadow_wolf", "arcane_mage", "dwarf_defender", "dwarf_carrier", "elf_ranger", "goblin_saboteur"]:
		var special_path: String = "res://assets/epic/animations/%s_special_sheet.png" % name
		if ResourceLoader.exists(special_path):
			var special_tex := load(special_path) as Texture2D
			if special_tex != null and special_tex.get_size() == Vector2(1024, 768):
				special_animation_atlases[name] = special_tex
	for name in ["void_sentinel", "void_stalker", "void_collector", "void_weaver"]:
		var void_path: String = "res://assets/epic/animations/%s_sheet.png" % name
		if ResourceLoader.exists(void_path):
			var void_tex := load(void_path) as Texture2D
			if void_tex != null and void_tex.get_size() == Vector2(1024, 768):
				void_animation_atlases[name] = void_tex
	menu_music = AudioStreamPlayer.new()
	menu_music.name = "EnchantedMenuScore"
	menu_music.volume_db = -9.0
	add_child(menu_music)
	if ResourceLoader.exists("res://assets/audio/enchanted_vault_theme.wav"):
		var score := load("res://assets/audio/enchanted_vault_theme.wav") as AudioStreamWAV
		if score != null:
			score.loop_mode = AudioStreamWAV.LOOP_FORWARD
			menu_music.stream = score
			menu_music.play()
	# Functional native Godot HUD. The full-screen concept painting is a style
	# reference only: every control below is a real button with a real handler.
	var backdrop := ColorRect.new()
	backdrop.color = Color("070e1d")
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 4)
	add_child(root)

	var header_frame := PanelContainer.new()
	_apply_epic_panel(header_frame, Color("111c32"), Color("edc078"), 4)
	root.add_child(header_frame)
	var header := VBoxContainer.new()
	header.add_theme_constant_override("separation", 0)
	header_frame.add_child(header)
	var title := Label.new()
	title_label = title
	title.text = "VAULT WARS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(title, 25, Color("ffdc95"))
	header.add_child(title)
	var banner := HBoxContainer.new()
	header.add_child(banner)
	hud = Label.new()
	hud.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_label(hud, 18, Color("f8d47e"))
	banner.add_child(hud)
	timer_label = Label.new()
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(timer_label, 16, Color("d1eaff"))
	header.add_child(timer_label)
	performance_label = Label.new()
	performance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(performance_label, 11, Color("87b2c9"))
	performance_label.modulate.a = 0.75
	header.add_child(performance_label)

	var battlefield_frame := PanelContainer.new()
	_apply_epic_panel(battlefield_frame, Color("071728"), Color("98713d"), 3)
	battlefield_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Keep the map panel close to its original 2400:1060 landscape ratio.
	battlefield_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	battlefield_frame.custom_minimum_size.y = 335
	root.add_child(battlefield_frame)
	arena = Control.new()
	arena.custom_minimum_size = Vector2(0, 325)
	arena.clip_contents = true
	arena.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arena.size_flags_vertical = Control.SIZE_EXPAND_FILL
	arena.draw.connect(_draw_arena)
	arena.mouse_filter = Control.MOUSE_FILTER_STOP
	arena.gui_input.connect(_arena_input)
	arena.resized.connect(_on_arena_resized)
	battlefield_frame.add_child(arena)

	# Preserved camera functionality; mobile keeps the entire map in view.
	camera_hint = Label.new()
	camera_hint.visible = false
	root.add_child(camera_hint)
	var camera_controls := HBoxContainer.new()
	camera_controls_row = camera_controls
	camera_controls.visible = false
	root.add_child(camera_controls)
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

	var command_frame := PanelContainer.new()
	command_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	command_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_apply_epic_panel(command_frame, Color("10192e"), Color("bc884a"), 5)
	root.add_child(command_frame)
	gameplay_panel = VBoxContainer.new()
	gameplay_panel.add_theme_constant_override("separation", 6)
	gameplay_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	command_frame.add_child(gameplay_panel)
	info = Label.new()
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.custom_minimum_size.y = 25
	_style_label(info, 14, Color("f3d598"))
	gameplay_panel.add_child(info)
	race_button = Button.new()
	race_button.visible = false
	gameplay_panel.add_child(race_button)
	race_button.disabled = true

	var lane_row := HBoxContainer.new()
	lane_row.add_theme_constant_override("separation", 5)
	gameplay_panel.add_child(lane_row)
	for index in 3:
		var lane_button := Button.new()
		lane_button.text = "LANE %d" % (index + 1)
		lane_button.custom_minimum_size.y = 50
		lane_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		lane_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lane_button.focus_mode = Control.FOCUS_NONE
		_style_button(lane_button, true)
		lane_row.add_child(lane_button)
		controls.append(lane_button)
		lane_button.pressed.connect(_select_lane.bind(index))

	var unit_row := HBoxContainer.new()
	unit_row.add_theme_constant_override("separation", 6)
	unit_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	gameplay_panel.add_child(unit_row)
	for index in 3:
		var unit_key: String = _character_key(0, index)
		var unit_button := _epic_card(["RUNNER", "CARRIER", "SABOTEUR"][index],
			COSTS[index], _preview_frame(_character_atlas(unit_key)), 125)
		unit_row.add_child(unit_button)
		controls.append(unit_button)
		unit_button.pressed.connect(_buy_unit.bind(index))

	var trap_row := HBoxContainer.new()
	trap_row.add_theme_constant_override("separation", 6)
	trap_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	gameplay_panel.add_child(trap_row)
	for index in 3:
		var icon_path: String = ["res://assets/ui/spikes.svg", "res://assets/ui/snare.svg", "res://assets/ui/turret.svg"][index]
		var trap_button := _epic_card(["SPIKES", "SNARE", "TURRET"][index],
			TRAP_COSTS[index], load(icon_path) as Texture2D, 108)
		trap_row.add_child(trap_button)
		controls.append(trap_button)
		trap_button.pressed.connect(_buy_trap.bind(index))

	guard_button = Button.new()
	guard_button.text = "⚔  HIRE DEFENDER  ·  130 GOLD"
	guard_button.custom_minimum_size.y = 52
	guard_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	guard_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_button(guard_button, true)
	gameplay_panel.add_child(guard_button)
	guard_button.pressed.connect(_buy_guard)
	ability_button = Button.new()
	ability_button.custom_minimum_size.y = 52
	ability_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ability_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_button(ability_button, false)
	gameplay_panel.add_child(ability_button)
	ability_button.pressed.connect(_use_race_ability)

	var economy_row := HBoxContainer.new()
	economy_row.add_theme_constant_override("separation", 5)
	economy_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	gameplay_panel.add_child(economy_row)
	invest_button = Button.new()
	invest_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	invest_button.custom_minimum_size.y = 52
	invest_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_style_button(invest_button, true)
	economy_row.add_child(invest_button)
	invest_button.pressed.connect(_upgrade_bank)
	raid_button = Button.new()
	raid_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	raid_button.custom_minimum_size.y = 52
	raid_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_style_button(raid_button, true)
	economy_row.add_child(raid_button)
	raid_button.pressed.connect(_buy_raid_boost)

	var start := Button.new()
	start.text = "⚔  UNLEASH THE RAID  ⚔"
	start.custom_minimum_size.y = 64
	start.size_flags_vertical = Control.SIZE_EXPAND_FILL
	start.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_button(start, false)
	gameplay_panel.add_child(start)
	controls.append(start)
	start.pressed.connect(_start_pressed)
	var clock := Timer.new()
	clock.wait_time = 0.05
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
	var gallery_button := Button.new()
	gallery_button.text = "VIEW 7 ANIMATED HEROES"
	gallery_button.custom_minimum_size.y = 48
	_style_button(gallery_button, true)
	column.add_child(gallery_button)
	gallery_button.pressed.connect(_open_animation_gallery)
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

func _open_animation_gallery() -> void:
	# Add to the top-level scene, above the faction selection overlay.
	# The gallery can be closed without changing race or resetting a match.
	add_child(AnimationGallery.new())

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
	_refresh_unit_icons()
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

func _use_race_ability() -> void:
	if phase != "PREP" or ability_used or gold[0] < 120:
		return
	gold[0] -= 120
	ability_used = true
	match selected_race:
		0:
			for guard in guards:
				if int(guard["side"]) == 0:
					guard["health"] = float(guard["health"]) + 60.0
					guard["max_health"] = float(guard["max_health"]) + 60.0
		1:
			pass # Frenzy applied to all friendly raiders on spawn.
		2:
			pass # Moon blessing adds extra capacity on spawn.
		3:
			pass # Shadow step grants one trap evasion on spawn.
	message = ABILITY_NAMES[selected_race] + " ACTIVATED"
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
			# Defenders use the same non-looping defeat animation as raiders.
			_record_fallen({"side": guard["side"], "lane": guard["lane"], "kind": 0,
				"position": guard["position"], "returning": false, "guard": true})
			guards.erase(guard)
			continue
		guard["cooldown"] = maxf(0.0, float(guard["cooldown"]) - dt)
		guard["attack_time"] = maxf(0.0, float(guard.get("attack_time", 0.0)) - dt)
		guard["hit_time"] = maxf(0.0, float(guard.get("hit_time", 0.0)) - dt)
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
			target["hit_time"] = 0.24
			guard["attack_time"] = 0.38
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
				# One discrete contact strike each 0.65s: the pose now matches damage.
				# Preserve the previous average damage per second.
				if float(unit.get("strike_cooldown", 0.0)) <= 0.0:
					guard["health"] -= (9.0 if int(unit["kind"]) == -1 else 14.0) * 0.65
					guard["hit_time"] = 0.28
					unit["attack_time"] = 0.45
					unit["strike_cooldown"] = 0.65

func _record_fallen(data: Dictionary) -> void:
	fallen_actors.append({"side": int(data["side"]), "kind": int(data["kind"]), "lane": int(data["lane"]), "position": float(data["position"]), "age": 0.0, "returning": bool(data.get("returning", false)), "guard": bool(data.get("guard", false))})
	if fallen_actors.size() > 30:
		fallen_actors.pop_front()

func _draw_health_bar(p: Vector2, health: float, max_health: float, friendly: bool, width: float = 34.0) -> void:
	var ratio: float = clampf(health / maxf(max_health, 1.0), 0.0, 1.0)
	var top_left := p + Vector2(-width * 0.5, -122)
	arena.draw_rect(Rect2(top_left - Vector2(2, 2), Vector2(width + 4, 12)), Color("08111c", 0.86))
	arena.draw_rect(Rect2(top_left, Vector2(width, 8)), Color("542f37", 0.78))
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
	traps[0].append({"lane": lane, "kind": kind, "charges": [3, 2, 999][kind],
		"slot": lane_count, "cooldown": 0.0, "fire_time": 0.0})
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
		traps[1].append({"lane": rng.randi_range(0, 2), "kind": 0, "charges": 3,
			"slot": traps[1].size() % 4, "cooldown": 0.0, "fire_time": 0.0})

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
	if side == 0 and ability_used:
		match selected_race:
			1: unit_speed *= 1.35
			2: unit_capacity += 35
			3: unit_speed *= 1.18
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
	units.append({"side": side, "lane": path, "kind": kind, "position": offset, "returning": false, "steal_timer": 0.0, "health": unit_health, "max_health": unit_health, "speed": unit_speed, "capacity": unit_capacity, "carried": 0, "stunned": 0.0, "disarmed": false, "shadow_evasion": side == 0 and ability_used and selected_race == 3, "triggered": [], "action": "walk", "action_time": 0.0, "hit_time": 0.0, "attack_time": 0.0})

func _tick() -> void:
	performance_elapsed += 0.05
	if performance_elapsed >= 1.0:
		performance_elapsed = 0.0
		performance_label.text = "FPS %d  |  SCRIPT %.1f ms  |  UNITS %d" % [Engine.get_frames_per_second(), Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0, units.size() + guards.size()]
	if phase == "SELECT":
		return
	visual_time += 0.05
	render_elapsed += 0.05
	# Rendering all 24 transparent 128px sprite regions every simulation step
	# caused significant UI jank on low-end phones. 12.5 Hz scene redraw is
	# sufficient for the current 8-frame sprite sheets; simulation stays 20 Hz.
	if render_elapsed >= 0.08:
		render_elapsed = 0.0
		arena.queue_redraw()
	if phase == "END":
		return
	if _check_vaults():
		_refresh()
		return
	remaining -= 0.05
	if phase == "PREP":
		if remaining <= 0.0:
			_begin_attack()
	else:
		_simulate(0.05)
		if _check_vaults():
			_refresh()
			return
		if remaining <= 0.0 or units.is_empty():
			_end_wave()
	_refresh()

func _simulate(dt: float) -> void:
	for side_traps in traps:
		for trap in side_traps:
			trap["cooldown"] = maxf(0.0, float(trap.get("cooldown", 0.0)) - dt)
			trap["fire_time"] = maxf(0.0, float(trap.get("fire_time", 0.0)) - dt)
	for bolt in turret_bolts.duplicate():
		bolt["age"] = float(bolt["age"]) + dt
		if float(bolt["age"]) >= 0.36:
			turret_bolts.erase(bolt)
	for deposit in deposit_actors.duplicate():
		deposit["age"] = float(deposit["age"]) + dt
		if float(deposit["age"]) >= 0.75:
			deposit_actors.erase(deposit)
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
		unit["action_time"] = float(unit.get("action_time", 0.0)) + dt
		unit["hit_time"] = maxf(0.0, float(unit.get("hit_time", 0.0)) - dt)
		unit["attack_time"] = maxf(0.0, float(unit.get("attack_time", 0.0)) - dt)
		unit["strike_cooldown"] = maxf(0.0, float(unit.get("strike_cooldown", 0.0)) - dt)
		if float(unit.get("steal_timer", 0.0)) > 0.0:
			unit["steal_timer"] = maxf(0.0, float(unit["steal_timer"]) - dt)
			continue
		if unit["stunned"] > 0.0:
			unit["stunned"] -= dt
			continue
		var defender: int = 1 - unit["side"]
		if not unit["returning"] and unit["position"] >= 0.35 and unit["position"] < 0.85:
			for trap in traps[defender].duplicate():
				if trap["lane"] != unit["lane"] or trap["charges"] <= 0:
					continue
				if bool(unit.get("shadow_evasion", false)):
					unit["shadow_evasion"] = false
					unit["triggered"].append(trap)
					break
				if trap["kind"] == 2:
					# Each tower is its own animated structure with an individual
					# reload timer, rather than invisible continuous DPS.
					if float(trap.get("cooldown", 0.0)) <= 0.0:
						unit["health"] -= 11.0
						unit["hit_time"] = 0.2
						trap["cooldown"] = 0.6
						trap["fire_time"] = 0.28
						var muzzle: Vector2 = _trap_position(trap, defender) + Vector2(0, -65)
						var hit_at: Vector2 = _point(int(unit["lane"]), float(unit["position"]), int(unit["side"])) + Vector2(0, -70)
						turret_bolts.append({"from": muzzle, "to": hit_at, "age": 0.0, "friendly": defender == 0})
						if turret_bolts.size() > 45:
							turret_bolts.pop_front()
				elif not unit["triggered"].has(trap):
					unit["triggered"].append(trap)
					if unit["kind"] == 2 and not unit["disarmed"]:
						unit["disarmed"] = true
						trap["charges"] = 0
					else:
						unit["health"] -= 40.0 if trap["kind"] == 0 else 25.0
						unit["hit_time"] = 0.28
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
				unit["steal_timer"] = 0.65
				unit["action_time"] = 0.0
				if _check_vaults():
					return
				unit["returning"] = true
				# Reset pose phase exactly on direction reversal; return uses mirrored frames.
				unit["action_time"] = 0.0
		else:
			unit["position"] -= unit["speed"] * dt
			if unit["position"] <= 0.0:
				gold[unit["side"]] += unit["carried"]
				deposit_actors.append({"side": int(unit["side"]), "lane": int(unit["lane"]), "kind": int(unit["kind"]), "age": 0.0, "amount": int(unit["carried"])})
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
	ability_used = false
	phase = "PREP"
	remaining = PREP_TIME
	message = "INTEREST +%d GOLD! Protect savings or invest in your army." % interest_last[0]

func _refresh() -> void:
	race_button.text = "RACE: " + RACE_NAMES[selected_race]
	race_button.disabled = true
	hud.text = "✦ YOUR GOLD %d   ◆   ENEMY %d ✦" % [gold[0], gold[1]]
	timer_label.text = "WAVE %d   |   %s   |   %02d s   |   INTEREST %d%%" % [
		wave, "PREPARE" if phase == "PREP" else "BATTLE" if phase == "ATTACK" else phase,
		int(maxf(0.0, ceilf(remaining))), (28 if selected_race == 0 else 18) + bank_level * 4]
	var active_friendly: int = 0
	for unit in units:
		if int(unit["side"]) == 0:
			active_friendly += 1
	var displayed_units: int = active_friendly if phase == "ATTACK" else orders[0].size()
	info.text = "◆ LANE %d  •  %s  •  UNITS %d  •  TRAPS %d" % [
		lane + 1, message, displayed_units, traps[0].size()]
	_refresh_unit_icons()
	var queued_in_lane: int = 0
	var traps_in_lane: int = 0
	var guards_in_lane: int = 0
	for order in orders[0]:
		if int(order["lane"]) == lane:
			queued_in_lane += 1
	for trap in traps[0]:
		if int(trap["lane"]) == lane:
			traps_in_lane += 1
	for guard in guards:
		if int(guard["side"]) == 0 and int(guard["lane"]) == lane:
			guards_in_lane += 1
	for i in 3:
		var available_unit: bool = phase == "PREP" and gold[0] >= COSTS[i] and orders[0].size() < 6 and queued_in_lane < 4
		var unit_card := controls[3 + i]
		unit_card.disabled = not available_unit
		unit_card.modulate = Color.WHITE
		var available_trap: bool = phase == "PREP" and gold[0] >= TRAP_COSTS[i] and traps_in_lane < 5
		var trap_card := controls[6 + i]
		trap_card.disabled = not available_trap
		trap_card.modulate = Color.WHITE
	guard_button.disabled = phase != "PREP" or gold[0] < GUARD_COST or guards_in_lane >= 3
	ability_button.disabled = phase != "PREP" or ability_used or gold[0] < 120
	ability_button.text = "✦ %s  •  120 GOLD" % ABILITY_NAMES[selected_race] if not ability_used else "✓ %s ACTIVE" % ABILITY_NAMES[selected_race]
	invest_button.disabled = phase != "PREP" or bank_level >= 5 or gold[0] < 180 + bank_level * 110
	raid_button.disabled = phase != "PREP" or raid_boost >= 3 or gold[0] < 120
	invest_button.text = "🏛 BANK LV%d  •  %d" % [bank_level, 180 + bank_level * 110] if bank_level < 5 else "🏛 BANK MAX"
	raid_button.text = "⚔ RAID LV%d  •  120" % raid_boost if raid_boost < 3 else "⚔ RAID MAX"
	controls[9].disabled = phase == "ATTACK"
	controls[9].text = "↻  PLAY AGAIN" if phase == "END" else "⚔  UNLEASH THE RAID  ⚔" if phase == "PREP" else "⚔  BATTLE IN PROGRESS  ⚔"
	for i in 3:
		controls[i].text = ("◆  " if i == lane else "") + "LANE %d" % (i + 1)
		controls[i].modulate = Color("ffe09d") if i == lane else Color("d8e9f8")
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

func _apply_epic_panel(panel: PanelContainer, bg: Color, outline: Color, margin: int) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = outline
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = margin
	style.content_margin_right = margin
	style.content_margin_top = 3
	style.content_margin_bottom = 3
	panel.add_theme_stylebox_override("panel", style)

func _preview_frame(sheet: Texture2D) -> Texture2D:
	if sheet == null:
		return null
	var preview := AtlasTexture.new()
	preview.atlas = sheet
	preview.region = Rect2(15, 6, 100, 116)
	return preview

func _epic_card(caption: String, price: int, art: Texture2D, minimum_height: float) -> Button:
	var button := Button.new()
	button.name = caption
	button.custom_minimum_size.y = minimum_height
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	_style_button(button, false)
	var portrait := TextureRect.new()
	portrait.name = "Artwork"
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.texture = art
	# Multiply the intentionally dark Voidborn sheet by a neutral brightness
	# boost in the command cards, not on battlefield sprites.
	portrait.modulate = Color(1.7, 1.7, 1.7)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	button.add_child(portrait)
	portrait.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait.offset_left = 3
	portrait.offset_right = -3
	portrait.offset_top = 3
	portrait.offset_bottom = -32
	var label := Label.new()
	label.name = "Caption"
	label.text = "%s  •  %d" % [caption, price]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_style_label(label, 17, Color("fff0c7"))
	button.add_child(label)
	label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	label.offset_top = -29
	label.offset_bottom = -2
	return button

func _refresh_unit_icons() -> void:
	if last_icon_race == selected_race:
		return
	last_icon_race = selected_race
	for kind in 3:
		if controls.size() <= kind + 3:
			return
		var icon_rect := controls[kind + 3].get_node_or_null("Artwork") as TextureRect
		if icon_rect != null:
			icon_rect.texture = _preview_frame(_character_atlas(_character_key(0, kind)))

func _style_button(button: Button, is_lane: bool) -> void:
	button.add_theme_font_size_override("font_size", 17 if is_lane else 19)
	button.add_theme_color_override("font_color", Color("fff0d4"))
	button.add_theme_color_override("font_hover_color", Color("fff8db"))
	button.add_theme_color_override("font_pressed_color", Color("ffffff"))
	button.add_theme_color_override("font_disabled_color", Color("a2a2aa"))
	button.add_theme_color_override("font_focus_color", Color("ffffff"))
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("152842") if is_lane else Color("2e1938")
		if state == "hover":
			style.bg_color = Color("395979") if is_lane else Color("593057")
		elif state == "pressed":
			style.bg_color = Color("86572b")
		elif state == "disabled":
			style.bg_color = Color("24344b")
		elif state == "focus":
			style.bg_color = Color("1c3450")
		style.border_color = Color("f8ca75") if state != "disabled" else Color("a48c68")
		style.set_border_width_all(2)
		style.set_corner_radius_all(9)
		style.content_margin_left = 4
		style.content_margin_right = 4
		style.content_margin_top = 3
		style.content_margin_bottom = 3
		if state == "hover" or state == "focus":
			style.shadow_size = 4
			style.shadow_color = Color("ffbb55", 0.27)
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

func _character_key(side: int, kind: int, is_guard: bool = false) -> String:
	# One authoritative map for battle, gold deposit, death and Animation Studio.
	# Do not reuse a wolf as Voidborn or a generic mage as a Voidborn saboteur.
	var role: int = clampi(kind, 0, 2)
	if side != 0:
		if is_guard:
			return "goblin_raider"
		return ["goblin_raider", "shadow_wolf", "goblin_saboteur"][role]
	match selected_race:
		0:
			return "dwarf_defender" if is_guard or role == 0 else "dwarf_carrier" if role == 1 else "arcane_mage"
		1:
			return "goblin_raider" if is_guard or role != 2 else "goblin_saboteur"
		2:
			return "elf_ranger" if is_guard or role != 2 else "arcane_mage"
		3:
			if is_guard:
				return "void_sentinel"
			return ["void_stalker", "void_collector", "void_weaver"][role]
	return "goblin_raider"

func _character_atlas(key: String) -> Texture2D:
	match key:
		"dwarf_defender": return atlas_dwarf_defender
		"dwarf_carrier": return atlas_dwarf_carrier
		"elf_ranger": return atlas_elf_ranger
		"arcane_mage": return atlas_arcane_mage
		"goblin_raider": return atlas_goblin_raider
		"goblin_saboteur": return atlas_goblin_saboteur
		"shadow_wolf": return atlas_shadow_wolf
		# Explicit fallbacks keep the game bootable before external PNG upload.
		"void_sentinel": return void_animation_atlases.get(key, atlas_dwarf_defender)
		"void_stalker": return void_animation_atlases.get(key, atlas_goblin_saboteur)
		"void_collector": return void_animation_atlases.get(key, atlas_dwarf_carrier)
		"void_weaver": return void_animation_atlases.get(key, atlas_arcane_mage)
	return atlas_goblin_raider

func _travel_facing(side: int, returning: bool) -> float:
	# Side 0 attacks towards screen right; side 1 attacks towards screen left.
	# The actual return journey always reverses that direction.
	return -1.0 if ((side == 1) != returning) else 1.0

func _directional_sprite_transform(p: Vector2, facing: float, tilt: float = 0.0) -> Transform2D:
	# Construct a negative-X basis explicitly. No sprite mirror is inferred
	# from Transform2D rotation/scale decomposition and no static images are rotated.
	var direction: float = -1.0 if facing < 0.0 else 1.0
	var c: float = cos(tilt)
	var sn: float = sin(tilt)
	var zoom: float = camera_zoom
	var origin := arena.size * 0.5 + camera_offset + _iso_project(p) * zoom
	return Transform2D(Vector2(c * zoom * direction, sn * zoom * direction), Vector2(-sn * zoom, c * zoom), origin)

func _trap_position(trap: Dictionary, owner: int) -> Vector2:
	var slot: int = int(trap.get("slot", 0))
	return _point(int(trap["lane"]), 0.48 + float(slot % 5) * 0.085, 1 - owner)

func _draw_arena() -> void:
	var center := arena.size * 0.5
	var w: float = arena.size.x * 0.85
	var h: float = arena.size.y * 0.68
	# Fill the tall phone viewport with a dimmed scenic continuation.
	# The crisp, fully visible battlefield is drawn above in world coordinates.
	arena.draw_rect(Rect2(Vector2.ZERO, arena.size), Color("071421"))
	# No stretched, dark duplicate of the battlefield behind the crisp image.
	arena.draw_set_transform_matrix(_iso_transform())
	center = Vector2.ZERO
	# The battlefield is now one high-detail painting. Never draw the old
	# geometric river, bridges, trees, roads or duplicate castles over it.
	arena.draw_texture_rect(epic_battlefield_texture, Rect2(Vector2(-1200, -530), Vector2(2400, 1060)), false)
	# Mobile: use a few inexpensive ambient highlights instead of dozens of
	# per-frame animated primitives across the entire battlefield.
	for i in 6:
		var water_y: float = -380.0 + float(i) * 150.0
		var water_pos := Vector2(sin(water_y * 0.008) * 36.0, water_y)
		var shimmer: float = 0.14 + 0.10 * sin(visual_time * 1.5 + float(i))
		arena.draw_line(water_pos - Vector2(9, 0), water_pos + Vector2(9, 0), Color(0.64, 0.96, 1.0, shimmer), 2.0)
	for side in 2:
		var fort := _point(1, 0, side)
		var base_color := Color("4f86bf") if side == 0 else Color("ad5265")
		# Fortresses are already painted into the background. Add pulsing
		# vault aura only, keeping the castle illustration unobstructed.
		var aura := Color("8ad7ff") if side == 0 else Color("ff8a73")
		var aura_alpha: float = 0.10 + 0.06 * sin(visual_time * 2.0 + float(side))
		arena.draw_arc(fort + Vector2(0, -35), 56.0, 0.0, TAU, 40, Color(aura.r, aura.g, aura.b, aura_alpha), 4.0)
		for trap in traps[side]:
			var p: Vector2 = _trap_position(trap, side)
			var trap_kind: int = int(trap["kind"])
			var icon_texture: Texture2D = turret_texture if trap_kind == 2 else snare_texture if trap_kind == 1 else spikes_texture
			var shimmer: float = 0.55 + 0.25 * sin(visual_time * 4.0 + float(trap.get("slot", 0)))
			arena.draw_circle(p + Vector2(0, 7), 29.0, Color("05091d", 0.55))
			var glow: Color = Color("5bcfff", 0.40 * shimmer) if trap_kind == 2 else Color("b568ff", 0.4 * shimmer) if trap_kind == 1 else Color("ffae60", 0.3 * shimmer)
			arena.draw_arc(p + Vector2(0, -32), 32.0 + 3.0 * shimmer, 0.0, TAU, 24, glow, 3.0)
			arena.draw_texture_rect(icon_texture, Rect2(p + Vector2(-45, -87), Vector2(90, 90)), false)
			if trap_kind == 2 and float(trap.get("fire_time", 0.0)) > 0.0:
				var fire: float = float(trap["fire_time"]) / 0.28
				arena.draw_circle(p + Vector2(0, -66), 13.0 + 6.0 * (1.0 - fire), Color("9aeaff", fire * 0.8))
	# Animated turret bolts move between the tower and the target.
	for bolt in turret_bolts:
		var t: float = clampf(float(bolt["age"]) / 0.36, 0.0, 1.0)
		var a: Vector2 = bolt["from"]
		var b: Vector2 = bolt["to"]
		var projectile: Vector2 = a.lerp(b, t) + Vector2(0, -38.0 * sin(t * PI))
		var tail: Vector2 = a.lerp(b, maxf(0.0, t - 0.13)) + Vector2(0, -38.0 * sin(maxf(0.0, t - 0.13) * PI))
		var shot_color: Color = Color("92eaff", 1.0 - 0.45 * t) if bool(bolt["friendly"]) else Color("ff8ab5", 1.0 - 0.45 * t)
		arena.draw_line(tail, projectile, shot_color, 5.0)
		arena.draw_circle(projectile, 6.0, shot_color)
		arena.draw_circle(projectile, 2.5, Color("ffffff", 0.92))
	# Draw combatants in depth order, including foot shadows and hit feedback.
	var actors: Array = []
	for guard in guards:
		actors.append({"p": _point(int(guard["lane"]), float(guard["position"]), int(guard["side"])), "data": guard, "guard": true, "side": int(guard["side"])})
	for unit in units:
		if float(unit["position"]) < -0.035:
			continue # Units enter the battlefield gradually instead of stacking at the castle.
		actors.append({"p": _point(int(unit["lane"]), clampf(float(unit["position"]), -0.035, 1.0), int(unit["side"])), "data": unit, "guard": false, "side": int(unit["side"])})
	actors.sort_custom(func(a, b): return _iso_project(a["p"]).y < _iso_project(b["p"]).y)
	for actor in actors:
		var p: Vector2 = actor["p"]
		if not _in_camera(p, 100.0):
			continue
		var data: Dictionary = actor["data"]
		var friendly: bool = int(actor["side"]) == 0
		var kind: int = 0 if actor["guard"] else int(data["kind"])
		var character_key: String = _character_key(int(actor["side"]), kind, bool(actor["guard"]))
		var atlas: Texture2D = _character_atlas(character_key)
		# Each playable role maps to one actual sprite atlas, never a static placeholder.
		# 6 rows × 8 distinct pose frames: idle, run, attack, hit, defeat, loot.
		var animation_row: int = 0
		if not actor["guard"] and phase == "ATTACK":
			animation_row = 1
		if float(data.get("steal_timer", 0.0)) > 0.0:
			animation_row = 5
		elif not actor["guard"] and bool(data.get("returning", false)) and int(data.get("carried", 0)) > 0:
			# Carry is a moving state, not a repeated deposit animation.
			animation_row = 1
		if float(data.get("hit_time", 0.0)) > 0.0 or float(data.get("stunned", 0.0)) > 0.0:
			animation_row = 3
		if float(data.get("attack_time", 0.0)) > 0.0 and animation_row != 3 and animation_row != 5:
			animation_row = 2
		var fps: float = 5.0 if animation_row == 0 else 10.0 if animation_row == 1 else 11.0 if animation_row == 2 else 10.0
		var frame_offset: float = float(int(data["lane"]) * 3 + int(actor["side"]) * 5 + kind)
		var animation_frame: int = int(floor(float(data.get("action_time", visual_time)) * fps + frame_offset)) % 8
		# Combat poses play from start to finish rather than randomly cycling.
		if animation_row == 2:
			animation_frame = clampi(int((0.45 - float(data.get("attack_time", 0.0))) * 18.0), 0, 7)
		# Advance the atlas frames; individual poses are supplied by the artwork.
		if animation_row == 3 and float(data.get("hit_time", 0.0)) > 0.0:
			animation_frame = mini(7, int((0.28 - float(data["hit_time"])) * 28.0))
		if animation_row == 5:
			animation_frame = mini(7, int((0.65 - float(data.get("steal_timer", 0.0))) * 12.0))
		# Movement-aware animation: idle breathing, two-step gait and hit recoil.
		var moving: bool = not bool(actor["guard"]) and phase == "ATTACK" and animation_row == 1 and float(data.get("stunned", 0.0)) <= 0.0
		var pace: float = 12.5 if kind == 0 else 7.5 if kind == 1 else 10.0
		var walk_phase: float = visual_time * (pace if moving else 2.4) + float(data["position"]) * 21.0
		var stride: float = sin(walk_phase)
		var lift: float = 0.0
		var squash: float = 1.0
		var bob: float = -lift
		var scale_factor: float = 1.0
		var tilt: float = 0.0
		var facing: float = _travel_facing(int(actor["side"]), not bool(actor["guard"]) and bool(data.get("returning", false)))
		var staggered: bool = not actor["guard"] and float(data.get("stunned", 0.0)) > 0.0
		if staggered:
			tilt = 0.16 * sin(visual_time * 17.0)
			bob = 1.5
		var shadow_scale: float = 1.0 - lift * 0.024
		arena.draw_circle(p + Vector2(0, 9), 23.0 * scale_factor * shadow_scale, Color("071924", 0.36))
		if moving and stride > 0.82 and goblin_walk_prototype == null:
			var dust: float = (stride - 0.82) / 0.18
			arena.draw_circle(p + Vector2(-facing * 15.0, 5.0), 3.0 + dust * 4.0, Color(0.85, 0.77, 0.58, dust * 0.28))
		var art_size := Vector2(105, 112) * scale_factor
		var animation_transform := _directional_sprite_transform(p, facing, tilt)
		arena.draw_set_transform_matrix(animation_transform)
		# A genuine special sprite replaces the basic pose only for actions it
		# visually depicts. All other states keep the upgraded six-row atlas.
		var special_sheet: Texture2D = null
		var special_row: int = -1
		if special_animation_atlases.has(character_key):
			special_sheet = special_animation_atlases[character_key]
			if animation_row == 2:
				match character_key:
					"arcane_mage": special_row = 3 # Beam
					"dwarf_carrier": special_row = 3 # Bashing dodge
					_: special_row = 2 # Distinct class attack (blade/arrow/hammer/bomb)
			elif moving:
				if character_key == "dwarf_carrier" and int(data.get("carried", 0)) > 0:
					special_row = 2 # Returning with actual gold animation
				elif bool(data.get("returning", false)) or float(data.get("speed", 0.0)) > 0.17:
					special_row = 0 # Distinct sprint/run poses
		# Voidborn uses its own six-row atlases, never the mage/wolf specials.
		var goblin_action: String = GOBLIN_ACTIONS[animation_row]
		if character_key == "goblin_raider" and animation_row == 1 and bool(data.get("returning", false)) and int(data.get("carried", 0)) > 0:
			goblin_action = "carry"
		if special_sheet != null and special_row >= 0:
			var special_frame: int = int(floor(float(data.get("action_time", visual_time)) * 12.0 + frame_offset)) % 8
			if animation_row == 2:
				special_frame = clampi(int((0.45 - float(data.get("attack_time", 0.0))) * 8.0 / 0.45), 0, 7)
			arena.draw_texture_rect_region(special_sheet, Rect2(Vector2(-art_size.x * 0.5, -art_size.y + bob), art_size),
				Rect2(Vector2(float(special_frame * 128), float(special_row * 128)), Vector2(128, 128)))
		elif character_key == "goblin_raider" and goblin_action_strips.has(goblin_action):
			var strip: Texture2D = goblin_action_strips[goblin_action]
			var count: int = strip.get_width() / 192
			var strip_frame: int = int(floor(float(data.get("action_time", visual_time)) * GOBLIN_ACTION_FPS[animation_row] + frame_offset)) % count
			if animation_row == 2:
				strip_frame = clampi(int((0.45 - float(data.get("attack_time", 0.0))) * float(count) / 0.45), 0, count - 1)
			elif animation_row == 3:
				strip_frame = clampi(int((0.28 - float(data.get("hit_time", 0.0))) * float(count) / 0.28), 0, count - 1)
			arena.draw_texture_rect_region(strip, Rect2(Vector2(-art_size.x * 0.5, -art_size.y + bob), art_size), Rect2(Vector2(float(strip_frame * 192), 0.0), Vector2(192, 192)))
		elif goblin_walk_prototype != null and not special_animation_atlases.has("goblin_raider") and character_key == "goblin_raider" and (animation_row == 1 or (actor["guard"] and animation_row == 0)):
			var walk_frame: int = int(floor(float(data.get("action_time", visual_time)) * 11.0 + frame_offset)) % 12 if animation_row == 1 else 0
			arena.draw_texture_rect_region(goblin_walk_prototype, Rect2(Vector2(-art_size.x * 0.5, -art_size.y + bob), art_size), Rect2(Vector2(float(walk_frame * 192), 0.0), Vector2(192, 192)))
		else:
			arena.draw_texture_rect_region(atlas, Rect2(Vector2(-art_size.x * 0.5, -art_size.y + bob), art_size), Rect2(Vector2(float(animation_frame * 128), float(animation_row * 128)), Vector2(128, 128)))
		arena.draw_set_transform_matrix(_iso_transform())
		if actor["guard"]:
			arena.draw_arc(p + Vector2(0, 6), 22.0, 0.0, TAU, 24, Color("e6c47b", 0.55) if friendly else Color("ee6678", 0.55), 2.5)
		_draw_health_bar(p + Vector2(0, bob), float(data["health"]), float(data["max_health"]), friendly, 42.0 if actor["guard"] else 34.0)
		# All seven character sheets now have their own attack visual language.
		if phase == "ATTACK" and animation_row == 2:
			_draw_attack_effect(p, character_key, facing, friendly, float(data.get("attack_time", 0.0)))
		if not actor["guard"] and int(data.get("carried", 0)) > 0:
			_draw_carried_gold(p, facing, int(data["carried"]))
	# Deposit gold at the home vault with a dedicated eight-frame coin-release action.
	for deposit in deposit_actors:
		var dp: Vector2 = _point(int(deposit["lane"]), 0.0, int(deposit["side"]))
		if not _in_camera(dp, 100.0):
			continue
		var deposit_key: String = _character_key(int(deposit["side"]), int(deposit["kind"]))
		var da: Texture2D = _character_atlas(deposit_key)
		# Deposit occurs at the HOME vault, after the actor has turned around.
		var dtf := _directional_sprite_transform(dp, _travel_facing(int(deposit["side"]), true))
		arena.draw_set_transform_matrix(dtf)
		var deposit_frame: int = mini(7, int(float(deposit["age"]) * 11.0))
		if deposit_key == "goblin_raider" and goblin_action_strips.has("deposit"):
			var deposit_strip: Texture2D = goblin_action_strips["deposit"]
			var deposit_count: int = deposit_strip.get_width() / 192
			var df: int = mini(deposit_count - 1, int(float(deposit["age"]) / 0.75 * deposit_count))
			arena.draw_texture_rect_region(deposit_strip, Rect2(Vector2(-52, -112), Vector2(105, 112)), Rect2(Vector2(float(df * 192), 0), Vector2(192, 192)))
		else:
			arena.draw_texture_rect_region(da, Rect2(Vector2(-52, -112), Vector2(105, 112)), Rect2(Vector2(float(deposit_frame * 128), 640.0), Vector2(128, 128)))
		arena.draw_set_transform_matrix(_iso_transform())
		_draw_deposit_effect(dp, float(deposit["age"]), int(deposit["amount"]))
	# Play the defeat row once before removing fallen units from the screen.
	for fallen in fallen_actors:
		var death_p: Vector2 = _point(int(fallen["lane"]), float(fallen["position"]), int(fallen["side"]))
		if not _in_camera(death_p, 100.0):
			continue
		var death_key: String = _character_key(int(fallen["side"]), int(fallen["kind"]), bool(fallen.get("guard", false)))
		var death_atlas: Texture2D = _character_atlas(death_key)
		var death_frame: int = mini(7, int(float(fallen["age"]) * 10.0))
		var fallen_transform := _directional_sprite_transform(death_p, _travel_facing(int(fallen["side"]), bool(fallen.get("returning", false))))
		arena.draw_set_transform_matrix(fallen_transform)
		if death_key == "goblin_raider" and goblin_action_strips.has("death"):
			var death_strip: Texture2D = goblin_action_strips["death"]
			var death_count: int = death_strip.get_width() / 192
			var f: int = mini(death_count - 1, int(float(fallen["age"]) / 0.8 * death_count))
			arena.draw_texture_rect_region(death_strip, Rect2(Vector2(-52, -112), Vector2(105, 112)), Rect2(Vector2(float(f * 192), 0), Vector2(192, 192)))
		else:
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

func _draw_attack_effect(p: Vector2, character_key: String, facing: float, friendly: bool, remaining_attack: float) -> void:
	# Lightweight world-space effects; sprite anatomy comes from the actual atlas frames.
	var progress: float = clampf(1.0 - remaining_attack / 0.45, 0.0, 1.0)
	var energy: float = sin(progress * PI)
	if energy <= 0.03:
		return
	var tip := p + Vector2(facing * 19.0, -48.0)
	var faction_color := Color("81dfff", 0.72 * energy) if friendly else Color("ff8b6e", 0.72 * energy)
	if character_key == "arcane_mage" or character_key == "void_weaver":
		arena.draw_arc(tip, 14.0 + 17.0 * progress, 0.0, TAU, 20, Color("c49bff", 0.7 * energy), 2.6)
		for i in 4:
			var theta: float = progress * TAU + float(i) * TAU / 4.0
			arena.draw_circle(tip + Vector2(cos(theta), sin(theta)) * 24.0, 3.0, faction_color)
	elif character_key == "elf_ranger":
		var arrow_base := p + Vector2(facing * 6.0, -52.0)
		var arrow_head := arrow_base + Vector2(facing * (15.0 + 42.0 * progress), -6.0)
		arena.draw_line(arrow_base, arrow_head, Color("c9f4b0", energy), 3.0)
		arena.draw_line(arrow_head, arrow_head + Vector2(-facing * 10.0, -5.0), Color("c9f4b0", energy), 2.0)
		arena.draw_line(arrow_head, arrow_head + Vector2(-facing * 10.0, 5.0), Color("c9f4b0", energy), 2.0)
	elif character_key == "shadow_wolf":
		for i in 3:
			var origin := tip + Vector2(0, float(i - 1) * 12.0)
			arena.draw_arc(origin, 16.0, -0.8 + progress, 1.5 + progress, 12, Color("d2baff", 0.78 * energy), 2.5)
	elif character_key == "goblin_saboteur" or character_key == "void_stalker":
		for i in 5:
			var drift: float = float(i) * 1.7 + progress * 3.0
			arena.draw_circle(tip + Vector2(cos(drift) * 14.0, sin(drift) * 12.0), 3.0 + float(i % 2), Color("9dff80", 0.64 * energy))
	elif character_key == "dwarf_defender" or character_key == "void_sentinel":
		arena.draw_arc(tip, 20.0, -1.5 + progress, 0.6 + progress * 2.0, 18, Color("ffd48c", 0.85 * energy), 4.0)
	elif character_key == "dwarf_carrier" or character_key == "void_collector":
		arena.draw_arc(tip, 18.0, -0.5 + progress, 1.1 + progress * 1.8, 16, Color("f7c76a", 0.7 * energy), 3.0)
	else:
		arena.draw_arc(tip, 18.0, -1.2 + progress, 1.2 + progress * 1.7, 17, faction_color, 3.3)

func _draw_carried_gold(p: Vector2, facing: float, amount: int) -> void:
	# Visible payload travels with the carrier, rather than drawing a deposit pose.
	var coin_p := p + Vector2(-facing * 15.0, -69.0)
	var glimmer: float = 0.45 + 0.35 * sin(visual_time * 7.0 + p.x)
	arena.draw_circle(coin_p, 6.0 + minf(float(amount) / 100.0, 3.0), Color("ecae43", 0.9))
	arena.draw_arc(coin_p, 4.5, 0.0, TAU, 12, Color("fff2bc", glimmer), 1.8)

func _draw_deposit_effect(p: Vector2, age: float, amount: int) -> void:
	var t: float = clampf(age / 0.75, 0.0, 1.0)
	var alpha: float = 1.0 - t
	for i in 5:
		var angle: float = TAU * float(i) / 5.0 + t * 1.5
		var spread: float = 8.0 + 32.0 * t
		var location := p + Vector2(cos(angle) * spread, -64.0 - t * 26.0 + sin(angle) * 10.0)
		arena.draw_circle(location, 2.8 + minf(float(amount) / 180.0, 2.0), Color("ffd56a", alpha))

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
