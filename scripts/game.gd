extends Control
const L10n = preload("res://scripts/localization.gd")
const LocalizedCard = preload("res://scripts/localized_card.gd")

const AnimationGallery = preload("res://scripts/animation_gallery.gd")
const OrnateHUD = preload("res://scripts/ornate_hud.gd")
const Epic = preload("res://scripts/epic_theme.gd")
const BattlePresentation = preload("res://scripts/battle_presentation.gd")
const Battlefields = preload("res://scripts/battlefields.gd")
const BATTLE_SCENERY = preload("res://assets/ui/lobby/epic_vault_menu.png")
var battle_shell: Control
const CinematicOutcome = preload("res://scripts/cinematic_outcome.gd")
const LobbyScreen = preload("res://scripts/lobby_screen.gd")
const MobileSettings = preload("res://scripts/mobile_settings.gd")
const AccountProgress = preload("res://scripts/account_progress.gd")
const Catalog = preload("res://scripts/game_catalog.gd")
const VAULT_TIER_ART = [
	preload("res://assets/world/vault_tier_1.svg"),
	preload("res://assets/world/vault_tier_2.svg"),
	preload("res://assets/world/vault_tier_3.svg"),
	preload("res://assets/world/vault_tier_4.svg"),
	preload("res://assets/world/vault_tier_5.svg")
]
const MAX_WAVES := 999
const RACE_NAMES := ["DWARVES", "GOBLINS", "ELVES", "VOIDBORN"]
const RACE_ART_PREFIX := ["dwarf", "goblin", "elf", ""]
const RACE_DESCRIPTIONS := ["Krasnoludy: 28% odsetek i +25% PŻ najeźdźców", "Gobliny: 18% odsetek i +20% tempa najeźdźców", "Elfy: 18% odsetek, +10% PŻ i +10 złota pojemności", "Voidborn: 18% odsetek, +10% tempa i +15 złota pojemności"]
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
const ABILITY_COST := 120
const RAID_COST := 120
const BANK_BASE_COST := 180
const BANK_STEP_COST := 110
const TRAP_DAMAGE := [40.0, 25.0, 11.0]
const TRAP_CHARGES := [3, 2, 999]

var presentation = MobileSettings.new()
var account = AccountProgress.new()
var account_match_id := ""
var account_battle_seconds := 0.0
var account_finished_waves := 0
var account_wave_active := false
var account_reward: Dictionary = {}
var codex_overlay: Control
var settings_overlay: Control

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
var message_key := "Build your army with coins. Protect your vault!"
var message_arguments: Array = []
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
var selection_layer: Control
var faction_cards: Array[PanelContainer] = []
var camera_offset := Vector2.ZERO
var camera_zoom := 1.0
var overview_mode := true
var expanded_map := false
var last_icon_race := -1
var last_ornate_lane := -1
var ornate_ui = OrnateHUD.new()
var original_png_ui := false
var last_original_raid_skin := ""
var gameplay_panel: VBoxContainer
var command_frame: PanelContainer
var battlefield_frame: PanelContainer
var main_menu_button: Button
var map_mode_button: Button
var menu_confirmation: Control
var result_overlay: Control
var main_menu_overlay: Control
var help_overlay: Control
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
	if OS.has_feature("android"):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_SENSOR)
	_set_battlefield(presentation.battlefield, false)
	L10n.set_language(presentation.language)
	_set_message(message_key)
	rng.randomize()
	# Android Back is routed through our overlays rather than quitting the app.
	get_tree().quit_on_go_back = false
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
	menu_music.stream_paused = not presentation.music_enabled
	add_child(menu_music)
	if ResourceLoader.exists("res://assets/audio/enchanted_vault_theme.wav"):
		var score := load("res://assets/audio/enchanted_vault_theme.wav") as AudioStreamWAV
		if score != null:
			score.loop_mode = AudioStreamWAV.LOOP_FORWARD
			menu_music.stream = score
			menu_music.play()
	original_png_ui = ornate_ui.has_original_art()
	# Functional native Godot HUD. The full-screen concept painting is a style
	# reference only: every control below is a real button with a real handler.
	var backdrop := ColorRect.new()
	backdrop.color = Color("070e1d")
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 2)
	add_child(root)

	var header_frame := PanelContainer.new()
	ornate_ui.panel(header_frame, "hud_bar", 42, 14)
	root.add_child(header_frame)
	var header := VBoxContainer.new()
	header.add_theme_constant_override("separation", 0)
	header_frame.add_child(header)
	var title := Label.new()
	title_label = title
	title.text = "VAULT WARS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_style_label(title, 29, Color("ffdc95"))
	var title_plaque := PanelContainer.new()
	title_plaque.name = "IllustratedTitle"
	title_plaque.custom_minimum_size.y = 68
	ornate_ui.panel(title_plaque, "crest", 125, 13)
	header.add_child(title_plaque)
	title_plaque.add_child(title)
	if original_png_ui:
		ornate_ui.original_panel(title_plaque, "title")
		title.text = "" # Title is engraved in the genuine PNG
		title_plaque.custom_minimum_size.y = 82
	var banner := HBoxContainer.new()
	var gold_plaque := PanelContainer.new()
	gold_plaque.name = "ResourceArtwork"
	ornate_ui.panel(gold_plaque, "hud_bar", 45, 12)
	header.add_child(gold_plaque)
	gold_plaque.add_child(banner)
	if original_png_ui:
		ornate_ui.original_panel(gold_plaque, "gold_bar")
		gold_plaque.custom_minimum_size.y = 37
	hud = Label.new()
	hud.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_label(hud, 18, Color("f8d47e"))
	banner.add_child(hud)
	timer_label = Label.new()
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(timer_label, 16, Color("d1eaff"))
	var phase_plaque := PanelContainer.new()
	phase_plaque.name = "PhaseArtwork"
	ornate_ui.panel(phase_plaque, "status_bar", 47, 11)
	header.add_child(phase_plaque)
	phase_plaque.add_child(timer_label)
	if original_png_ui:
		ornate_ui.original_panel(phase_plaque, "phase_bar")
		phase_plaque.custom_minimum_size.y = 34
	performance_label = Label.new()
	performance_label.visible = presentation.show_fps
	performance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(performance_label, 11, Color("87b2c9"))
	performance_label.modulate.a = 0.70
	var title_actions := HBoxContainer.new()
	title_actions.add_theme_constant_override("separation", 5)
	header.add_child(title_actions)
	performance_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_actions.add_child(performance_label)
	main_menu_button = Button.new()
	main_menu_button.name = "MainMenuToggle"
	main_menu_button.text = "☰ MENU"
	main_menu_button.custom_minimum_size = Vector2(110, 36)
	ornate_ui.button(main_menu_button, "lane_blue", "lane_selected", true)
	title_actions.add_child(main_menu_button)
	main_menu_button.pressed.connect(_request_main_menu)
	map_mode_button = Button.new()
	map_mode_button.name = "MapViewToggle"
	map_mode_button.text = "⛶ MAP"
	map_mode_button.custom_minimum_size = Vector2(100, 36)
	ornate_ui.button(map_mode_button, "lane_blue", "lane_selected", true)
	title_actions.add_child(map_mode_button)
	map_mode_button.pressed.connect(_toggle_map_expanded)

	battlefield_frame = PanelContainer.new()
	_apply_epic_panel(battlefield_frame, Color("071728"), Color("98713d"), 3)
	battlefield_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Keep the map panel close to its original 2400:1060 landscape ratio.
	battlefield_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	battlefield_frame.custom_minimum_size.y = 328
	root.add_child(battlefield_frame)
	arena = Control.new()
	arena.custom_minimum_size = Vector2(0, 322)
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

	command_frame = PanelContainer.new()
	command_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	command_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_apply_epic_panel(command_frame, Color("10192e"), Color("bc884a"), 2)
	root.add_child(command_frame)
	gameplay_panel = VBoxContainer.new()
	gameplay_panel.add_theme_constant_override("separation", 2)
	gameplay_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	command_frame.add_child(gameplay_panel)
	info = Label.new()
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.custom_minimum_size.y = 25
	_style_label(info, 14, Color("f3d598"))
	var message_plaque := PanelContainer.new()
	message_plaque.name = "MessageArtwork"
	message_plaque.custom_minimum_size.y = 36
	ornate_ui.panel(message_plaque, "status_bar", 40, 12)
	gameplay_panel.add_child(message_plaque)
	message_plaque.add_child(info)
	if original_png_ui:
		ornate_ui.original_panel(message_plaque, "message_bar")
	race_button = Button.new()
	race_button.visible = false
	gameplay_panel.add_child(race_button)
	race_button.disabled = true

	var lane_row := HBoxContainer.new()
	lane_row.add_theme_constant_override("separation", 2)
	gameplay_panel.add_child(lane_row)
	for index in 3:
		var lane_button := Button.new()
		lane_button.text = L10n.t("LANE %d") % (index + 1)
		lane_button.custom_minimum_size.y = 50
		lane_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		lane_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lane_button.focus_mode = Control.FOCUS_NONE
		_style_button(lane_button, true)
		ornate_ui.button(lane_button, "lane_blue", "lane_selected", true)
		lane_row.add_child(lane_button)
		controls.append(lane_button)
		lane_button.pressed.connect(_select_lane.bind(index))

	var unit_row := HBoxContainer.new()
	unit_row.add_theme_constant_override("separation", 2)
	unit_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	gameplay_panel.add_child(unit_row)
	for index in 3:
		var unit_key: String = _character_key(0, index)
		var unit_button := _epic_card([L10n.t("RUNNER"), L10n.t("CARRIER"), L10n.t("SABOTEUR")][index],
			COSTS[index], _preview_frame(_character_atlas(unit_key)), 125)
		unit_row.add_child(unit_button)
		controls.append(unit_button)
		unit_button.pressed.connect(_buy_unit.bind(index))

	var trap_row := HBoxContainer.new()
	trap_row.add_theme_constant_override("separation", 2)
	trap_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	gameplay_panel.add_child(trap_row)
	for index in 3:
		var icon_path: String = ["res://assets/ui/spikes.svg", "res://assets/ui/snare.svg", "res://assets/ui/turret.svg"][index]
		var trap_button := _epic_card([L10n.t("SPIKES"), L10n.t("SNARE"), L10n.t("TURRET")][index],
			TRAP_COSTS[index], load(icon_path) as Texture2D, 108)
		trap_row.add_child(trap_button)
		controls.append(trap_button)
		trap_button.pressed.connect(_buy_trap.bind(index))

	guard_button = Button.new()
	guard_button.text = "⚔  HIRE DEFENDER  ·  130 GOLD"
	guard_button.custom_minimum_size.y = 84
	guard_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_button(guard_button, true)
	ornate_ui.button(guard_button, "banner_blue", "banner_gold")
	gameplay_panel.add_child(guard_button)
	guard_button.pressed.connect(_buy_guard)
	ability_button = Button.new()
	ability_button.custom_minimum_size.y = 84
	ability_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_button(ability_button, false)
	ornate_ui.button(ability_button, "banner_purple", "banner_gold")
	gameplay_panel.add_child(ability_button)
	ability_button.pressed.connect(_use_race_ability)

	var economy_row := HBoxContainer.new()
	economy_row.add_theme_constant_override("separation", 2)
	economy_row.custom_minimum_size.y = 84
	gameplay_panel.add_child(economy_row)
	invest_button = Button.new()
	invest_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	invest_button.custom_minimum_size.y = 52
	invest_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_style_button(invest_button, true)
	ornate_ui.button(invest_button, "banner_blue", "banner_gold")
	economy_row.add_child(invest_button)
	invest_button.pressed.connect(_upgrade_bank)
	raid_button = Button.new()
	raid_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	raid_button.custom_minimum_size.y = 52
	raid_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_style_button(raid_button, true)
	ornate_ui.button(raid_button, "banner_blue", "banner_gold")
	economy_row.add_child(raid_button)
	raid_button.pressed.connect(_buy_raid_boost)

	var start := Button.new()
	start.text = "⚔  UNLEASH THE RAID  ⚔"
	start.custom_minimum_size.y = 64
	start.size_flags_vertical = Control.SIZE_EXPAND_FILL
	start.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_button(start, false)
	ornate_ui.button(start, "banner_purple", "banner_gold")
	gameplay_panel.add_child(start)
	controls.append(start)
	start.pressed.connect(_start_pressed)
	var clock := Timer.new()
	clock.wait_time = 0.05
	clock.timeout.connect(_tick)
	add_child(clock)
	clock.start()
	_generate_terrain_details()
	if original_png_ui:
		_install_original_png_buttons()
	_refresh()
	_apply_presentation()
	battle_shell = BattlePresentation.new()
	battle_shell.game = self
	battle_shell.legacy_root = root
	add_child(battle_shell)
	_show_main_menu()

func _show_main_menu() -> void:
	if main_menu_overlay != null:
		main_menu_overlay.show()
		return
	main_menu_overlay = LobbyScreen.new()
	main_menu_overlay.name = "VaultWarsMainMenu"
	main_menu_overlay.game = self
	main_menu_overlay.mode = "home"
	main_menu_overlay.z_index = 90
	add_child(main_menu_overlay)

func _open_race_selection() -> void:
	if main_menu_overlay != null:
		main_menu_overlay.queue_free()
		main_menu_overlay = null
	if help_overlay != null:
		help_overlay.queue_free()
		help_overlay = null
	_show_race_selection()

func _back_from_race_selection() -> void:
	if selection_layer != null:
		selection_layer.queue_free()
		selection_layer = null
	_show_main_menu()

func _hide_lobby() -> void:
	for screen in [main_menu_overlay, selection_layer, help_overlay]:
		if is_instance_valid(screen):
			screen.hide()

func _restore_lobby() -> void:
	if help_overlay != null:
		help_overlay.show()
	elif selection_layer != null:
		selection_layer.show()
	elif main_menu_overlay != null:
		main_menu_overlay.show()

func _show_codex(entry_id: String = "runner") -> void:
	if codex_overlay != null:
		return
	_hide_lobby()
	codex_overlay = LobbyScreen.new()
	codex_overlay.name = "GameCodex"
	codex_overlay.game = self
	codex_overlay.mode = "codex"
	codex_overlay.focus_entry = entry_id
	codex_overlay.z_index = 96
	add_child(codex_overlay)

func _close_codex() -> void:
	if codex_overlay != null:
		codex_overlay.queue_free()
		codex_overlay = null
	_restore_lobby()

func _show_settings() -> void:
	if settings_overlay != null:
		return
	_hide_lobby()
	settings_overlay = LobbyScreen.new()
	settings_overlay.name = "MobileSettings"
	settings_overlay.game = self
	settings_overlay.mode = "settings"
	settings_overlay.z_index = 96
	add_child(settings_overlay)

func _close_settings() -> void:
	if settings_overlay != null:
		settings_overlay.queue_free()
		settings_overlay = null
	_restore_lobby()

func _change_language(code: String) -> void:
	if code not in L10n.LANGUAGES or code == presentation.language:
		return
	presentation.language = code
	presentation.save()
	L10n.set_language(code)
	_set_message(message_key, message_arguments)
	for screen in [main_menu_overlay, selection_layer, codex_overlay, settings_overlay, help_overlay]:
		if is_instance_valid(screen):
			screen.rebuild_language()
	_refresh()

func _set_message(key: String, arguments: Array = []) -> void:
	message_key = key
	message_arguments = arguments
	var localized_arguments: Array = []
	for argument in arguments:
		localized_arguments.append(L10n.t(argument) if argument is String else argument)
	message = L10n.t(key) if arguments.is_empty() else L10n.t(key) % localized_arguments

func _apply_presentation(persist: bool = false) -> void:
	presentation.apply_frame_limit()
	if is_instance_valid(performance_label):
		performance_label.visible = presentation.show_fps
	if is_instance_valid(menu_music):
		menu_music.stream_paused = not presentation.music_enabled
	# Hidden previews are paused too, so returning from settings preserves comfort.
	for screen in [main_menu_overlay, selection_layer]:
		if is_instance_valid(screen):
			var preview = screen.live_preview
			if is_instance_valid(preview):
				preview.playing = not presentation.reduced_motion
	if persist:
		presentation.save()

func _process(delta: float) -> void:
	if phase == "SELECT" or phase == "END":
		return
	visual_time += delta
	render_elapsed += delta
	if render_elapsed >= 1.0 / presentation.battlefield_fps():
		render_elapsed = 0.0
		arena.queue_redraw()
	presentation.observe_fps(delta, Engine.get_frames_per_second())

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_navigate_back()

func _show_how_to_play() -> void:
	if help_overlay != null:
		return
	_hide_lobby()
	help_overlay = LobbyScreen.new()
	help_overlay.name = "HowToPlayOverlay"
	help_overlay.game = self
	help_overlay.mode = "tutorial"
	help_overlay.z_index = 95
	add_child(help_overlay)

func _close_how_to_play() -> void:
	if help_overlay != null:
		help_overlay.queue_free()
		help_overlay = null
	_restore_lobby()

func _show_race_selection() -> void:
	if selection_layer != null:
		return
	phase = "SELECT"
	selection_layer = LobbyScreen.new()
	selection_layer.name = "RaceSelection"
	selection_layer.game = self
	selection_layer.mode = "race"
	selection_layer.z_index = 91
	add_child(selection_layer)

func _open_animation_gallery() -> void:
	# Add to the top-level scene, above the faction selection overlay.
	# The gallery can be closed without changing race or resetting a match.
	if get_node_or_null("AnimationStudio") != null:
		return
	_hide_lobby()
	var studio := AnimationGallery.new()
	studio.name = "AnimationStudio"
	studio.z_index = 98
	studio.tree_exited.connect(_restore_lobby)
	add_child(studio)

func _preview_faction(index: int) -> void:
	if selection_layer != null:
		selection_layer.select_race(index)
	elif account.race_unlocked(index):
		selected_race = index

func _confirm_faction() -> void:
	_choose_faction(selection_layer.focus_race if is_instance_valid(selection_layer) else selected_race)

func _set_battlefield(id: String, persist: bool = true) -> void:
	var chosen: String = Battlefields.IDS[Battlefields.index(id)]
	presentation.battlefield = chosen
	epic_battlefield_texture = Battlefields.texture(chosen)
	if persist:
		presentation.save()
	if is_instance_valid(arena):
		arena.queue_redraw()

func _choose_faction(index: int) -> void:
	if not account.race_unlocked(index):
		return
	selected_race = index
	account_match_id = Crypto.new().generate_random_bytes(16).hex_encode()
	account_battle_seconds = 0.0
	account_finished_waves = 0
	account_wave_active = false
	account_reward = {}
	phase = "PREP"
	remaining = PREP_TIME
	_set_message(RACE_DESCRIPTIONS[index])
	_refresh_unit_icons()
	if selection_layer != null:
		selection_layer.queue_free()
		selection_layer = null
	if main_menu_overlay != null:
		main_menu_overlay.queue_free()
		main_menu_overlay = null
	for overlay in [codex_overlay, settings_overlay, help_overlay]:
		if is_instance_valid(overlay):
			overlay.queue_free()
	codex_overlay = null
	settings_overlay = null
	help_overlay = null
	_refresh()

func _change_race() -> void:
	if phase != "PREP" or wave != 1:
		return
	for _step in RACE_NAMES.size():
		selected_race = (selected_race + 1) % RACE_NAMES.size()
		if account.race_unlocked(selected_race):
			break
	_set_message("Playing as %s", [RACE_NAMES[selected_race]])
	_refresh()

func _select_lane(index: int) -> void:
	lane = index
	_set_message("Selected lane %d", [(lane + 1)])
	_refresh()

func _use_race_ability() -> void:
	if phase != "PREP" or ability_used or gold[0] < ABILITY_COST:
		return
	gold[0] -= ABILITY_COST
	_check_vaults()
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
	_set_message("%s ACTIVATED", [ABILITY_NAMES[selected_race]])
	_refresh()

func _upgrade_bank() -> void:
	var cost: int = BANK_BASE_COST + bank_level * BANK_STEP_COST
	if phase != "PREP" or bank_level >= 5 or gold[0] < cost:
		return
	gold[0] -= cost
	_check_vaults()
	bank_level += 1
	_set_message("BANK LEVEL %d! The vault is upgraded; +4%% interest per wave.", [bank_level])
	arena.queue_redraw()
	_refresh()

func _buy_raid_boost() -> void:
	if phase != "PREP" or gold[0] < RAID_COST or raid_boost >= 3:
		return
	gold[0] -= RAID_COST
	_check_vaults()
	raid_boost += 1
	_set_message("Raid training %d/3: faster, stronger thieves.", [raid_boost])
	_refresh()

func _buy_guard() -> void:
	if phase != "PREP":
		return
	var count := 0
	for guard in guards:
		if int(guard["side"]) == 0 and int(guard["lane"]) == lane:
			count += 1
	if gold[0] < GUARD_COST or count >= 3:
		_set_message("Need 130 vault gold; max 3 defenders per lane.")
		_refresh()
		return
	gold[0] -= GUARD_COST
	guards.append({"side": 0, "lane": lane, "position": 0.19 + float(count) * 0.11, "health": GUARD_HP, "max_health": GUARD_HP, "cooldown": 0.0})
	_check_vaults()
	_set_message("Defender assigned to lane %d", [(lane + 1)])
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

func _draw_health_bar(p: Vector2, health: float, max_health: float, friendly: bool, width: float = 34.0, height: float = 122.0) -> void:
	var ratio: float = clampf(health / maxf(max_health, 1.0), 0.0, 1.0)
	var top_left := p + Vector2(-width * 0.5, -height)
	var pixel: float = 1.0 / maxf(camera_zoom, 0.01)
	arena.draw_rect(Rect2(top_left - Vector2.ONE * pixel, Vector2(width + 2 * pixel, 6 * pixel)), Color("08111c", 0.86))
	arena.draw_rect(Rect2(top_left, Vector2(width, 4 * pixel)), Color("542f37", 0.78))
	arena.draw_rect(Rect2(top_left, Vector2(width * ratio, 4 * pixel)), Color("55e98b") if friendly else Color("ff6976"))

func _buy_unit(kind: int) -> void:
	if phase != "PREP":
		return
	var lane_count := 0
	for order in orders[0]:
		if order["lane"] == lane:
			lane_count += 1
	if gold[0] < COSTS[kind] or orders[0].size() >= 6 or lane_count >= 4:
		_set_message("Not enough gold or unit limit reached.")
		_refresh()
		return
	gold[0] -= COSTS[kind]
	_check_vaults()
	orders[0].append({"kind": kind, "lane": lane})
	_set_message("Thief queued on lane %d", [(lane + 1)])
	_refresh()

func _buy_trap(kind: int) -> void:
	if phase != "PREP":
		return
	var lane_count := 0
	for trap in traps[0]:
		if trap["lane"] == lane:
			lane_count += 1
	if gold[0] < TRAP_COSTS[kind] or lane_count >= 5:
		_set_message("Not enough gold or trap limit reached.")
		_refresh()
		return
	gold[0] -= TRAP_COSTS[kind]
	_check_vaults()
	traps[0].append({"lane": lane, "kind": kind, "charges": TRAP_CHARGES[kind],
		"slot": lane_count, "cooldown": 0.0, "fire_time": 0.0})
	_set_message("Trap built on lane %d", [(lane + 1)])
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
	if phase != "PREP":
		return
	_bot_prepare()
	if phase == "END":
		return
	phase = "ATTACK"
	account_wave_active = true
	remaining = ATTACK_TIME
	units.clear()
	for side in 2:
		for path in 3:
			for n in (wave + 1 if wave < 5 else 7):
				_spawn(side, path, -1, -float(n) * 0.07)
		for order in orders[side]:
			_spawn(side, order["lane"], order["kind"], -rng.randf_range(0.0, 0.15))
	_set_message("Attack phase! Steal gold and return home.")
	_refresh()

func raider_stats(kind: int, race: int, with_ability: bool, training: int) -> Dictionary:
	var unit_health: float = 60.0 if kind == -1 else HP[kind]
	var unit_speed: float = 0.145 if kind == -1 else SPEED[kind]
	var unit_capacity: int = 25 if kind == -1 else LOOTS[kind]
	if with_ability:
		match race:
			1: unit_speed *= 1.35
			2: unit_capacity += 35
			3: unit_speed *= 1.18
	match race:
		0: unit_health *= 1.25
		1: unit_speed *= 1.2
		2:
			unit_health *= 1.1
			unit_capacity += 10
		3:
			unit_speed *= 1.1
			unit_capacity += 15
	unit_health *= 1.0 + float(training) * 0.12
	unit_speed *= 1.0 + float(training) * 0.08
	return {"health": unit_health, "speed": unit_speed, "capacity": unit_capacity}

func interest_rate(race: int, level: int) -> float:
	return (0.28 if race == 0 else 0.18) + float(level) * 0.04

func _spawn(side: int, path: int, kind: int, offset: float) -> void:
	# A negative race selects the unmodified bot stats. The guide calls this
	# same calculator without changing selection, gold or simulation state.
	var stats: Dictionary = raider_stats(kind, selected_race if side == 0 else -1, side == 0 and ability_used, raid_boost if side == 0 else 0)
	var unit_health: float = stats["health"]
	var unit_speed: float = stats["speed"]
	var unit_capacity: int = stats["capacity"]
	units.append({"side": side, "lane": path, "kind": kind, "position": offset, "returning": false, "steal_timer": 0.0, "health": unit_health, "max_health": unit_health, "speed": unit_speed, "capacity": unit_capacity, "carried": 0, "stunned": 0.0, "disarmed": false, "shadow_evasion": side == 0 and ability_used and selected_race == 3, "triggered": [], "action": "walk", "action_time": 0.0, "hit_time": 0.0, "attack_time": 0.0})

func _tick() -> void:
	performance_elapsed += 0.05
	if performance_elapsed >= 1.0:
		performance_elapsed = 0.0
		performance_label.text = "FPS %d  |  SCRIPT %.1f ms  |  UNITS %d" % [Engine.get_frames_per_second(), Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0, units.size() + guards.size()]
	if phase == "SELECT":
		return
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
	# Buttons and rich text are expensive to layout on older Android devices.
	# Update the clock and affordability 5×/sec rather than 20×/sec.
	ui_elapsed += 0.05
	if ui_elapsed >= 0.2 or phase == "END":
		ui_elapsed = 0.0
		_refresh()

func _simulate(dt: float) -> void:
	if phase == "ATTACK" and not account_match_id.is_empty():
		account_battle_seconds += maxf(0, dt)
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
						unit["health"] -= TRAP_DAMAGE[2]
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
						unit["health"] -= TRAP_DAMAGE[int(trap["kind"])]
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
	var rewarded_waves: int = account_finished_waves + (1 if account_wave_active else 0)
	account_reward = account.claim_match(account_match_id, gold[1] <= 0 and gold[0] > 0, rewarded_waves, account_battle_seconds)
	phase = "END"
	remaining = 0.0
	if gold[0] <= 0 and gold[1] <= 0:
		_set_message("DRAW! BOTH VAULTS ARE EMPTY")
	elif gold[1] <= 0:
		_set_message("VICTORY! ENEMY VAULT DESTROYED")
	else:
		_set_message("DEFEAT! YOUR VAULT IS EMPTY")
	victory_reason = message
	call_deferred("_show_cinematic_result")
	return true

func _show_cinematic_result() -> void:
	if phase != "END" or result_overlay != null or not is_inside_tree():
		return
	if menu_music != null:
		menu_music.stop()
	result_overlay = CinematicOutcome.new()
	result_overlay.reduced_motion = presentation.reduced_motion
	result_overlay.effect_count = 8 if presentation.effective_quality == "battery" else 46
	result_overlay.music_enabled = presentation.music_enabled
	result_overlay.account = account
	result_overlay.account_reward = account_reward
	add_child(result_overlay)
	result_overlay.play_again_requested.connect(_restart_match)
	result_overlay.main_menu_requested.connect(_return_to_main_menu)
	result_overlay.present(gold[1] <= 0 and gold[0] > 0,
		gold[0] <= 0 and gold[1] <= 0, victory_reason, wave, gold[0], gold[1])

func _restart_match() -> void:
	get_tree().reload_current_scene()

func _return_to_main_menu() -> void:
	# A fresh scene opens the existing four-race selection screen.
	get_tree().reload_current_scene()

func _request_main_menu() -> void:
	if phase == "SELECT":
		return
	if phase == "END":
		_return_to_main_menu()
		return
	if menu_confirmation != null:
		return
	menu_confirmation = ColorRect.new()
	menu_confirmation.name = "LeaveMatchConfirmation"
	menu_confirmation.color = Color(0.02, 0.02, 0.08, 0.90)
	menu_confirmation.mouse_filter = Control.MOUSE_FILTER_STOP
	menu_confirmation.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_confirmation.z_index = 110
	add_child(menu_confirmation)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_confirmation.add_child(center)
	var frame := PanelContainer.new()
	var skin := Epic.panel(22)
	frame.add_theme_stylebox_override("panel", skin)
	center.add_child(frame)
	var choices := VBoxContainer.new()
	choices.custom_minimum_size.x = 460
	choices.add_theme_constant_override("separation", 15)
	frame.add_child(choices)
	var warning := Label.new()
	warning.text = L10n.t("LEAVE THE BATTLE?")
	warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(warning, 29, Color("ffe2a2"))
	choices.add_child(warning)
	var detail := Label.new()
	detail.text = L10n.t("Current match progress will be lost.")
	detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(detail, 18, Color("ddd0ed"))
	choices.add_child(detail)
	var stay := Button.new()
	stay.name = "StayInBattle"
	stay.text = L10n.t("CONTINUE BATTLE")
	stay.custom_minimum_size.y = 65
	Epic.button(stay)
	choices.add_child(stay)
	stay.pressed.connect(_dismiss_menu_confirmation)
	var leave := Button.new()
	leave.name = "ConfirmMainMenu"
	leave.text = L10n.t("RETURN TO MAIN MENU")
	leave.custom_minimum_size.y = 65
	Epic.button(leave, true)
	choices.add_child(leave)
	leave.pressed.connect(_return_to_main_menu)

func _dismiss_menu_confirmation() -> void:
	if menu_confirmation != null:
		menu_confirmation.queue_free()
		menu_confirmation = null

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_navigate_back()
		get_viewport().set_input_as_handled()

func _navigate_back() -> void:
	var studio := get_node_or_null("AnimationStudio")
	if studio != null:
		studio.queue_free()
	elif codex_overlay != null:
		_close_codex()
	elif settings_overlay != null:
		_close_settings()
	elif help_overlay != null:
		_close_how_to_play()
	elif selection_layer != null:
		_back_from_race_selection()
	elif is_instance_valid(battle_shell) and battle_shell.landscape and battle_shell.drawer_open and phase in ["PREP", "ATTACK"]:
		battle_shell.set_drawer_open(false)
	elif menu_confirmation != null:
		_dismiss_menu_confirmation()
	else:
		_request_main_menu()

func _end_wave() -> void:
	if phase != "ATTACK":
		return
	account_finished_waves += 1
	account_wave_active = false
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
			rate = interest_rate(selected_race, bank_level)
		var payout: int = maxi(20, int(floor(float(gold[side]) * rate)))
		interest_last[side] = payout
		gold[side] += payout
	wave += 1
	ability_used = false
	phase = "PREP"
	remaining = PREP_TIME
	_set_message("INTEREST +%d GOLD! Protect savings or invest in your army.", [interest_last[0]])

func _refresh() -> void:
	race_button.text = L10n.t("RACE: %s") % L10n.t(RACE_NAMES[selected_race])
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
	info.text = L10n.t("◆ LANE %d  •  %s  •  UNITS %d  •  TRAPS %d") % [
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
	ability_button.text = L10n.t("✦ %s  •  120 GOLD") % L10n.t(ABILITY_NAMES[selected_race]) if not ability_used else L10n.t("✓ %s ACTIVE") % L10n.t(ABILITY_NAMES[selected_race])
	if original_png_ui and _race_has_illustrated_asset("ability"):
		ability_button.text = ""
	invest_button.disabled = phase != "PREP" or bank_level >= 5 or gold[0] < 180 + bank_level * 110
	raid_button.disabled = phase != "PREP" or raid_boost >= 3 or gold[0] < 120
	invest_button.text = L10n.t("🏛 BANK LV%d  •  %d") % [bank_level, 180 + bank_level * 110] if bank_level < 5 else L10n.t("🏛 BANK LV5 • MAX")
	raid_button.text = L10n.t("⚔ RAID LV%d  •  120") % raid_boost if raid_boost < 3 else L10n.t("⚔ RAID MAX")
	if original_png_ui:
		var bank_text := invest_button.get_node_or_null("OriginalDynamicText") as Label
		var raid_text := raid_button.get_node_or_null("OriginalDynamicText") as Label
		if bank_text != null:
			bank_text.text = invest_button.text
		if raid_text != null:
			raid_text.text = raid_button.text
		invest_button.text = ""
		raid_button.text = ""
	controls[9].disabled = phase == "ATTACK"
	controls[9].text = L10n.t("↻  PLAY AGAIN") if phase == "END" else "⚔  UNLEASH THE RAID  ⚔" if phase == "PREP" else "⚔  BATTLE IN PROGRESS  ⚔"
	if original_png_ui:
		_update_original_raid_skin()
	for i in 3:
		controls[i].text = ("◆  " if i == lane else "") + L10n.t("LANE %d") % (i + 1)
		controls[i].modulate = Color.WHITE
	for lane_index in 3:
		Epic.button(controls[lane_index], lane_index == lane, 18)
	_refresh_localized_cards()
	if is_instance_valid(battle_shell):
		battle_shell.sync()
	arena.queue_redraw()

func _refresh_localized_cards() -> void:
	if not original_png_ui:
		return
	for index in 6:
		var item: String = ["runner", "carrier", "saboteur", "spikes", "snare", "turret"][index]
		var title: String = ["RUNNER", "CARRIER", "SABOTEUR", "SPIKES", "SNARE", "TURRET"][index]
		var card: Button = controls[3 + index]
		LocalizedCard.apply(card, ornate_ui.original_texture(_race_art_name(item)), L10n.t(title), "✦ %d" % (COSTS[index] if index < 3 else TRAP_COSTS[index - 3]))
	LocalizedCard.apply(guard_button, ornate_ui.original_texture(_race_art_name("defender")), L10n.t("DEFENDER"), "✦ %d" % GUARD_COST, true)
	LocalizedCard.apply(ability_button, ornate_ui.original_texture(_race_art_name("ability")), L10n.t(ABILITY_NAMES[selected_race]), L10n.t("AKTYWNA") if ability_used else "✦ %d" % ABILITY_COST, true)
	LocalizedCard.apply(invest_button, ornate_ui.original_texture(_race_art_name("bank")), L10n.t("SKARBIEC %d/5") % bank_level, "MAX" if bank_level >= 5 else "✦ %d" % (BANK_BASE_COST + bank_level * BANK_STEP_COST), true)
	LocalizedCard.apply(raid_button, ornate_ui.original_texture(_race_art_name("raid")), L10n.t("TRENING %d/3") % raid_boost, "MAX" if raid_boost >= 3 else "✦ %d" % RAID_COST, true)

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
	var c := cos(rotation) * camera_zoom
	var s := sin(rotation) * camera_zoom
	return Transform2D(Vector2(c, s), Vector2(-s, c), arena.size * 0.5 + camera_offset + _iso_project(p) * camera_zoom)

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
	if font_size >= 25:
		Epic.heading(label, font_size)

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
	var frame_name: String = "card_hero" if caption in [L10n.t("RUNNER"), L10n.t("CARRIER"), L10n.t("SABOTEUR")] else "card_trap"
	ornate_ui.button(button, frame_name, frame_name)
	var glow := TextureRect.new()
	glow.name = "ArtGlow"
	glow.texture = ornate_ui.image("portrait_aura")
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	glow.stretch_mode = TextureRect.STRETCH_SCALE
	button.add_child(glow)
	glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	glow.offset_left = 12
	glow.offset_right = -12
	glow.offset_top = 8
	glow.offset_bottom = -37
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
	label.text = L10n.t(caption)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_style_label(label, 17, Color("fff0c7"))
	button.add_child(label)
	label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	label.offset_left = 4
	label.offset_right = -83
	label.offset_top = -36
	label.offset_bottom = -4
	var price_text := Label.new()
	price_text.name = "Price"
	price_text.text = str(price)
	price_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	price_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	price_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_style_label(price_text, 17, Color("ffe7aa"))
	button.add_child(price_text)
	price_text.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	price_text.offset_left = -58
	price_text.offset_right = -7
	price_text.offset_top = -37
	price_text.offset_bottom = -4
	var coin := TextureRect.new()
	coin.name = "GoldCoin"
	coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coin.texture = ornate_ui.image("coin")
	coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	button.add_child(coin)
	coin.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	coin.offset_left = -88
	coin.offset_right = -59
	coin.offset_top = -35
	coin.offset_bottom = -5
	return button

func _set_premium_card_overlay(button_node: Button, show_legacy_art: bool) -> void:
	for name in ["ArtGlow", "Artwork", "Caption", "Price", "GoldCoin"]:
		var child := button_node.get_node_or_null(name) as CanvasItem
		if child != null:
			child.visible = show_legacy_art

func _original_economy_label(button_node: Button) -> Label:
	# Covers old baked LV0 lettering in the image so it never overlaps the
	# live bank/raid level and price.
	var mask := ColorRect.new()
	mask.name = "DynamicPriceMask"
	mask.color = Color("091529", 0.97)
	mask.anchor_left = 0.40
	mask.anchor_right = 0.985
	mask.anchor_top = 0.16
	mask.anchor_bottom = 0.86
	mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button_node.add_child(mask)
	var overlay := Label.new()
	overlay.name = "OriginalDynamicText"
	overlay.anchor_left = 0.41
	overlay.anchor_right = 0.97
	overlay.anchor_top = 0.19
	overlay.anchor_bottom = 0.83
	overlay.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	overlay.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_style_label(overlay, 18, Color("ffe7a7"))
	button_node.add_child(overlay)
	return overlay

func _race_art_name(name: String) -> String:
	# Voidborn uses the previously imported original cards. The other three
	# races use the exact generated high-detail cards in the optional PNG pack.
	if selected_race == 3:
		return "ability_void" if name == "ability" else name
	return RACE_ART_PREFIX[selected_race] + "_" + name

func _race_has_illustrated_asset(name: String) -> bool:
	return ornate_ui.original_texture(_race_art_name(name)) != null

func _install_original_png_buttons() -> void:
	# One consistent, fully clickable, premium UI system for all four factions.
	# Faction art changes with selected_race; Godot buttons remain wired to
	# game logic, real prices, and touch hitboxes.
	_original_economy_label(invest_button)
	_original_economy_label(raid_button)
	_update_original_faction_art()
	_update_original_raid_skin(true)

func _update_original_faction_art() -> void:
	_update_original_character_art()
	_update_original_ability_skin()
	for i in 3:
		var trap_name: String = ["spikes", "snare", "turret"][i]
		var premium_name: String = _race_art_name(trap_name)
		ornate_ui.original_button(controls[6 + i],
			premium_name if ornate_ui.original_texture(premium_name) != null else trap_name)
		_set_premium_card_overlay(controls[6 + i], false)
	var defender_key: String = _race_art_name("defender")
	ornate_ui.original_button(guard_button,
		defender_key if ornate_ui.original_texture(defender_key) != null else "defender")
	guard_button.text = ""
	for node_info in [[invest_button, "bank"], [raid_button, "raid"]]:
		var node: Button = node_info[0] as Button
		var name: String = node_info[1]
		var proposed: String = _race_art_name(name)
		ornate_ui.original_button(node,
			proposed if ornate_ui.original_texture(proposed) != null else name)
	invest_button.text = ""
	raid_button.text = ""

func _update_original_character_art() -> void:
	for i in 3:
		var card_name: String = ["runner", "carrier", "saboteur"][i]
		var premium_name: String = _race_art_name(card_name)
		var button_node: Button = controls[3 + i]
		if ornate_ui.original_texture(premium_name) != null:
			ornate_ui.original_button(button_node, premium_name)
			_set_premium_card_overlay(button_node, false)
		else:
			# Only until the next PNG package is imported. Never show a
			# Voidborn illustration for a goblin, dwarf or elf.
			ornate_ui.button(button_node, "card_hero", "card_hero")
			_set_premium_card_overlay(button_node, true)

func _update_original_ability_skin() -> void:
	var premium_name: String = _race_art_name("ability")
	if ornate_ui.original_texture(premium_name) != null:
		ornate_ui.original_button(ability_button, premium_name)
		ability_button.text = ""
	else:
		ornate_ui.button(ability_button, "banner_purple", "banner_gold")

func _update_original_raid_skin(force: bool = false) -> void:
	if is_instance_valid(battle_shell):
		return
	var name: String = "attack_again" if phase == "END" else "attack_prep" if phase == "PREP" else "attack_busy"
	if name != last_original_raid_skin or force:
		last_original_raid_skin = name
		ornate_ui.original_button(controls[9], name)
	controls[9].text = ""

func _refresh_unit_icons() -> void:
	if last_icon_race == selected_race:
		return
	last_icon_race = selected_race
	if original_png_ui:
		_update_original_faction_art()
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
	if is_instance_valid(battle_shell):
		battle_shell.fit_camera()
		return
	# Fixed camera: fit the complete painted map, including both castles.
	camera_zoom = maxf(0.01, minf(arena.size.x / 2400.0, arena.size.y / 1060.0))
	camera_offset = Vector2.ZERO
	overview_mode = true
	arena.queue_redraw()

func _center_camera() -> void:
	_fit_map()

func _toggle_map_expanded() -> void:
	if is_instance_valid(battle_shell):
		battle_shell.toggle_view()
		return
	expanded_map = not expanded_map
	command_frame.visible = not expanded_map
	battlefield_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL if expanded_map else Control.SIZE_SHRINK_CENTER
	map_mode_button.text = "▤ CONTROLS" if expanded_map else "⛶ MAP"
	# Keep the entire world visible in tactical overview.
	call_deferred("_fit_map")

func _change_zoom(delta: float) -> void:
	camera_zoom = clampf(camera_zoom + delta, 0.12, 2.25)
	overview_mode = false
	arena.queue_redraw()

func _arena_input(event: InputEvent) -> void:
	if is_instance_valid(battle_shell):
		battle_shell.handle_input(event)
		return
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
	return _character_key_for_race(selected_race, kind, is_guard)

func _character_key_for_race(race: int, kind: int, is_guard: bool = false) -> String:
	var role: int = clampi(kind, 0, 2)
	match race:
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

func _unit_art_size() -> Vector2:
	# Square source cells keep their anatomy. Enlarge gently with the map rather
	# than suddenly shrinking when a unit dies, deposits or the phone rotates.
	var logical_height: float = clampf(64.0 * sqrt(maxf(camera_zoom, 0.01) / 0.30), 58.0, 86.0)
	return Vector2.ONE * logical_height / maxf(camera_zoom, 0.01)

func _unit_art_rect(art_size: Vector2, bob: float = 0.0) -> Rect2:
	return Rect2(Vector2(-art_size.x * 0.5, -art_size.y * 0.88 + bob), art_size)

func _draw_arena() -> void:
	var center := arena.size * 0.5
	var w: float = arena.size.x * 0.85
	var h: float = arena.size.y * 0.68
	# Fill the tall phone viewport with a dimmed scenic continuation.
	# The crisp, fully visible battlefield is drawn above in world coordinates.
	arena.draw_rect(Rect2(Vector2.ZERO, arena.size), Color("071421"))
	if is_instance_valid(battle_shell) and battle_shell.overview:
		arena.draw_texture_rect(BATTLE_SCENERY, Rect2(Vector2.ZERO, arena.size), false, Color(0.23, 0.24, 0.32))
	# The focused view fills the viewport; overview keeps both vaults in view.
	arena.draw_set_transform_matrix(_iso_transform())
	center = Vector2.ZERO
	# The battlefield is now one high-detail painting. Never draw the old
	# geometric river, bridges, trees, roads or duplicate castles over it.
	arena.draw_texture_rect(epic_battlefield_texture, Rect2(Vector2(-1200, -530), Vector2(2400, 1060)), false)
	# Mobile: use a few inexpensive ambient highlights instead of dozens of
	# per-frame animated primitives across the entire battlefield.
	for i in presentation.ambient_count():
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
		if side == 0 and bank_level > 0:
			# These five genuinely different architectural drawings replace
			# the static LV0 castle as the player upgrades the vault.
			var bank_art: Texture2D = VAULT_TIER_ART[clampi(bank_level - 1, 0, 4)]
			var bank_pulse: float = 0.82 + 0.10 * sin(visual_time * 2.5)
			arena.draw_circle(fort + Vector2(0, -67), 108.0, Color("5ce2ff", 0.18 * bank_pulse))
			arena.draw_texture_rect(bank_art,
				Rect2(fort + Vector2(-105, -208), Vector2(210, 210)),
				false, Color(1, 1, 1, 0.98))
			for crystal in bank_level:
				var angle: float = float(crystal) * TAU / float(bank_level) + visual_time * 0.25
				var shard: Vector2 = fort + Vector2(cos(angle) * 93.0, -93.0 + sin(angle) * 30.0)
				arena.draw_circle(shard, 5.0, Color("bff9ff", bank_pulse))
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
		var art_size: Vector2 = _unit_art_size()
		var scale_factor: float = art_size.y / 112.0
		var tilt: float = 0.0
		var facing: float = _travel_facing(int(actor["side"]), not bool(actor["guard"]) and bool(data.get("returning", false)))
		var staggered: bool = not actor["guard"] and float(data.get("stunned", 0.0)) > 0.0
		if staggered:
			tilt = 0.16 * sin(visual_time * 17.0)
			bob = 1.5
		var shadow_scale: float = 1.0 - lift * 0.024
		arena.draw_set_transform_matrix(_sprite_transform(p + Vector2(0, 2)).scaled_local(Vector2(1, 0.32)))
		arena.draw_circle(Vector2.ZERO, 26.0 * scale_factor * shadow_scale, Color("030713", 0.42))
		arena.draw_arc(Vector2.ZERO, 26.0 * scale_factor, 0, TAU, 24, Color("64eab8", 0.82) if friendly else Color("ff667b", 0.82), 2.5 / camera_zoom)
		arena.draw_set_transform_matrix(_iso_transform())
		if moving and stride > 0.82 and goblin_walk_prototype == null:
			var dust: float = (stride - 0.82) / 0.18
			arena.draw_circle(p + Vector2(-facing * 15.0, 5.0), 3.0 + dust * 4.0, Color(0.85, 0.77, 0.58, dust * 0.28))
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
			arena.draw_texture_rect_region(special_sheet, _unit_art_rect(art_size, bob),
				Rect2(Vector2(float(special_frame * 128), float(special_row * 128)), Vector2(128, 128)))
		elif character_key == "goblin_raider" and goblin_action_strips.has(goblin_action):
			var strip: Texture2D = goblin_action_strips[goblin_action]
			var count: int = strip.get_width() / 192
			var strip_frame: int = int(floor(float(data.get("action_time", visual_time)) * GOBLIN_ACTION_FPS[animation_row] + frame_offset)) % count
			if animation_row == 2:
				strip_frame = clampi(int((0.45 - float(data.get("attack_time", 0.0))) * float(count) / 0.45), 0, count - 1)
			elif animation_row == 3:
				strip_frame = clampi(int((0.28 - float(data.get("hit_time", 0.0))) * float(count) / 0.28), 0, count - 1)
			arena.draw_texture_rect_region(strip, _unit_art_rect(art_size, bob), Rect2(Vector2(float(strip_frame * 192), 0.0), Vector2(192, 192)))
		elif goblin_walk_prototype != null and not special_animation_atlases.has("goblin_raider") and character_key == "goblin_raider" and (animation_row == 1 or (actor["guard"] and animation_row == 0)):
			var walk_frame: int = int(floor(float(data.get("action_time", visual_time)) * 11.0 + frame_offset)) % 12 if animation_row == 1 else 0
			arena.draw_texture_rect_region(goblin_walk_prototype, _unit_art_rect(art_size, bob), Rect2(Vector2(float(walk_frame * 192), 0.0), Vector2(192, 192)))
		else:
			arena.draw_texture_rect_region(atlas, _unit_art_rect(art_size, bob), Rect2(Vector2(float(animation_frame * 128), float(animation_row * 128)), Vector2(128, 128)))
		arena.draw_set_transform_matrix(_iso_transform())
		if actor["guard"]:
			arena.draw_arc(p + Vector2(0, 6), 22.0, 0.0, TAU, 24, Color("e6c47b", 0.55) if friendly else Color("ee6678", 0.55), 2.5)
		_draw_health_bar(p + Vector2(0, bob), float(data["health"]), float(data["max_health"]), friendly, (52.0 if actor["guard"] else 46.0) * scale_factor, art_size.y * 0.88 + 8.0 / camera_zoom)
		# All seven character sheets now have their own attack visual language.
		if phase == "ATTACK" and animation_row == 2:
			arena.draw_set_transform_matrix(_sprite_transform(p).scaled_local(Vector2.ONE * scale_factor))
			_draw_attack_effect(Vector2.ZERO, character_key, facing, friendly, float(data.get("attack_time", 0.0)))
		if not actor["guard"] and int(data.get("carried", 0)) > 0:
			arena.draw_set_transform_matrix(_sprite_transform(p).scaled_local(Vector2.ONE * scale_factor))
			_draw_carried_gold(Vector2.ZERO, facing, int(data["carried"]))
		arena.draw_set_transform_matrix(_iso_transform())
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
			arena.draw_texture_rect_region(deposit_strip, _unit_art_rect(_unit_art_size()), Rect2(Vector2(float(df * 192), 0), Vector2(192, 192)))
		else:
			arena.draw_texture_rect_region(da, _unit_art_rect(_unit_art_size()), Rect2(Vector2(float(deposit_frame * 128), 640.0), Vector2(128, 128)))
		arena.draw_set_transform_matrix(_iso_transform())
		arena.draw_set_transform_matrix(_sprite_transform(dp).scaled_local(Vector2.ONE * (_unit_art_size().y / 112.0)))
		_draw_deposit_effect(Vector2.ZERO, float(deposit["age"]), int(deposit["amount"]))
		arena.draw_set_transform_matrix(_iso_transform())
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
			arena.draw_texture_rect_region(death_strip, _unit_art_rect(_unit_art_size()), Rect2(Vector2(float(f * 192), 0), Vector2(192, 192)))
		else:
			arena.draw_texture_rect_region(death_atlas, _unit_art_rect(_unit_art_size()), Rect2(Vector2(float(death_frame * 128), 512.0), Vector2(128, 128)))
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
	for i in presentation.ambient_count():
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
