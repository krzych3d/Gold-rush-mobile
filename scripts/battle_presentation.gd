extends Control
const L10n = preload("res://scripts/localization.gd")
## Presentation only: permanent gold HUD, camera views and a sliding arsenal.
const Epic = preload("res://scripts/epic_theme.gd")
var game
var legacy_root: Control
var drawer: ScrollContainer
var dock: PanelContainer
var drawer_button: Button
var enemy_gold: Label
var overview := false
var drawer_open := false
var follow_action := true
var drawer_tween: Tween
var camera_tween: Tween
var pointer_down := false
var travel := 0.0
var phase_seen := ""
var last_language := ""

func _ready() -> void:
	name = "FullScreenBattle"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	legacy_root.hide()
	game.battlefield_frame.reparent(self)
	game.battlefield_frame.custom_minimum_size = Vector2.ZERO
	game.arena.custom_minimum_size = Vector2.ZERO
	game.battlefield_frame.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	game.battlefield_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_header()
	drawer = ScrollContainer.new()
	drawer.name = "SlidingArsenal"
	drawer.z_index = 12
	drawer.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(drawer)
	game.command_frame.reparent(drawer)
	game.command_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	game.command_frame.add_theme_stylebox_override("panel", Epic.panel(12))
	dock = PanelContainer.new()
	dock.name = "BattleDock"
	dock.z_index = 25
	dock.add_theme_stylebox_override("panel", Epic.panel(10))
	add_child(dock)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	dock.add_child(row)
	drawer_button = _button(row, L10n.t("ARSENAŁ ↑"), set_drawer_open.bind(true), 220)
	drawer_button.name = "ArsenalToggle"
	# Toggle the same panel; do not stack drawers after repeated taps.
	drawer_button.pressed.disconnect(set_drawer_open.bind(true))
	drawer_button.pressed.connect(func() -> void: set_drawer_open(not drawer_open))
	game.controls[9].reparent(row)
	game.controls[9].custom_minimum_size.y = 68
	Epic.button(game.controls[9], true, 21)
	resized.connect(_layout)
	call_deferred("_layout")
	sync()

func _button(parent: Node, caption: String, handler: Callable, width: float = 0) -> Button:
	var button := Button.new()
	button.text = L10n.t(caption)
	button.set_meta("caption_key", caption)
	button.custom_minimum_size = Vector2(width, 60)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL if width == 0 else Control.SIZE_FILL
	parent.add_child(button)
	Epic.button(button, false, 18)
	button.pressed.connect(handler)
	return button

func _build_header() -> void:
	var margin := MarginContainer.new()
	margin.name = "PermanentBattleHUD"
	margin.z_index = 24
	margin.anchor_right = 1.0
	margin.offset_left = 12
	margin.offset_right = -12
	margin.offset_top = 12
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 5)
	margin.add_child(column)
	var gold_panel := PanelContainer.new()
	gold_panel.name = "VisibleGoldCounter"
	gold_panel.add_theme_stylebox_override("panel", Epic.panel(14))
	column.add_child(gold_panel)
	var gold_row := HBoxContainer.new()
	gold_row.custom_minimum_size.y = 42
	gold_row.add_theme_constant_override("separation", 12)
	gold_panel.add_child(gold_row)
	var coin := TextureRect.new()
	coin.texture = load("res://assets/ui/ornate/coin.svg") as Texture2D
	coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coin.custom_minimum_size = Vector2(38, 38)
	gold_row.add_child(coin)
	game.hud.reparent(gold_row)
	game.hud.name = "PlayerGold"
	game.hud.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	game.hud.add_theme_font_size_override("font_size", 30)
	game.hud.add_theme_color_override("font_color", Color("fff0b5"))
	enemy_gold = Label.new()
	enemy_gold.name = "EnemyGold"
	enemy_gold.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	enemy_gold.add_theme_font_size_override("font_size", 26)
	enemy_gold.add_theme_color_override("font_color", Color("ffb7bb"))
	gold_row.add_child(enemy_gold)
	var navigation := HBoxContainer.new()
	navigation.add_theme_constant_override("separation", 8)
	column.add_child(navigation)
	game.main_menu_button.reparent(navigation)
	game.main_menu_button.text = L10n.t("MENU")
	game.main_menu_button.custom_minimum_size = Vector2(132, 60)
	Epic.button(game.main_menu_button, false, 18)
	game.timer_label.reparent(navigation)
	game.timer_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	game.timer_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	game.timer_label.add_theme_color_override("font_color", Color.WHITE)
	game.map_mode_button.reparent(navigation)
	game.map_mode_button.custom_minimum_size = Vector2(188, 60)
	Epic.button(game.map_mode_button, false, 17)
	var locations := HBoxContainer.new()
	locations.add_theme_constant_override("separation", 8)
	column.add_child(locations)
	_button(locations, "BAZA", focus_location.bind(-1000.0))
	_button(locations, "AKCJA", _follow)
	_button(locations, "WRÓG", focus_location.bind(1000.0))
	game.performance_label.reparent(column)

func _layout() -> void:
	if drawer == null:
		return
	dock.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	dock.offset_left = 10
	dock.offset_right = -10
	dock.offset_top = -104
	dock.offset_bottom = -10
	drawer.size = Vector2(maxf(0, size.x - 20), minf(size.y * 0.61, 760))
	drawer.position = Vector2(10, size.y - 112 - drawer.size.y if drawer_open else size.y + 8)
	fit_camera()

func set_drawer_open(value: bool, animate: bool = true) -> void:
	drawer_open = value
	drawer_button.text = L10n.t("SCHOWAJ ↓") if value else L10n.t("ARSENAŁ ↑")
	if drawer_tween != null:
		drawer_tween.kill()
	drawer.show()
	var destination: float = size.y - 112 - drawer.size.y if value else size.y + 8
	if animate and not game.presentation.reduced_motion:
		drawer_tween = create_tween()
		drawer_tween.tween_property(drawer, "position:y", destination, 0.28).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		if not value:
			drawer_tween.tween_callback(drawer.hide)
	else:
		drawer.position.y = destination
		drawer.visible = value

func toggle_view() -> void:
	var previous_zoom: float = game.camera_zoom
	var previous_offset: Vector2 = game.camera_offset
	overview = not overview
	follow_action = not overview
	fit_camera()
	if not game.presentation.reduced_motion:
		var target_zoom: float = game.camera_zoom
		var target_offset: Vector2 = game.camera_offset
		game.camera_zoom = previous_zoom
		game.camera_offset = previous_offset
		if camera_tween != null:
			camera_tween.kill()
		camera_tween = create_tween().set_parallel(true)
		camera_tween.tween_property(game, "camera_zoom", target_zoom, 0.34).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		camera_tween.tween_property(game, "camera_offset", target_offset, 0.34).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	sync()

func fit_camera() -> void:
	if game.arena.size.x <= 0 or game.arena.size.y <= 0:
		return
	var zoom: float = minf(game.arena.size.x / 2400.0, game.arena.size.y / 1060.0) if overview else maxf(game.arena.size.x / 2400.0, game.arena.size.y / 1060.0)
	game.overview_mode = overview
	game.expanded_map = not overview
	game.camera_zoom = maxf(0.01, zoom)
	game.camera_offset.y = 0
	game.camera_offset.x = 0 if overview else _clamp_offset(game.camera_offset.x)
	game.arena.queue_redraw()

func _clamp_offset(value: float) -> float:
	var extent: float = maxf(0, 1200.0 * game.camera_zoom - game.arena.size.x * 0.5)
	return clampf(value, -extent, extent)

func focus_location(world_x: float) -> void:
	if overview:
		overview = false
		fit_camera()
	follow_action = false
	if camera_tween != null:
		camera_tween.kill()
	var target := Vector2(_clamp_offset(-world_x * game.camera_zoom), 0)
	if game.presentation.reduced_motion:
		game.camera_offset = target
	else:
		camera_tween = create_tween()
		camera_tween.tween_property(game, "camera_offset", target, 0.32).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	sync()

func _follow() -> void:
	if overview:
		overview = false
		fit_camera()
	follow_action = true
	sync()

func handle_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event is InputEventMouseButton and event.button_index != MOUSE_BUTTON_LEFT:
			return
		pointer_down = event.pressed
		if event.pressed:
			travel = 0
		elif travel < 18:
			game._select_lane(game._nearest_lane(event.position))
	elif event is InputEventScreenDrag or (event is InputEventMouseMotion and pointer_down):
		travel += event.relative.length()
		if not overview and travel > 12:
			follow_action = false
			if camera_tween != null:
				camera_tween.kill()
			game.camera_offset.x = _clamp_offset(game.camera_offset.x + event.relative.x)
			game.arena.queue_redraw()

func sync() -> void:
	if enemy_gold == null:
		return
	if last_language != L10n.language:
		last_language = L10n.language
		_refresh_navigation(self)
	game.hud.text = L10n.t("ZŁOTO %d") % game.gold[0]
	enemy_gold.text = L10n.t("WRÓG %d") % game.gold[1]
	game.timer_label.text = L10n.t("FALA %d • %s\n%d s • odsetki %d%%") % [game.wave, L10n.t("PRZYGOTOWANIE") if game.phase == "PREP" else L10n.t("BITWA"), int(maxf(0, ceilf(game.remaining))), int(game.interest_rate(game.selected_race, game.bank_level) * 100)]
	game.map_mode_button.text = L10n.t("ZBLIŻENIE") if overview else L10n.t("CAŁA MAPA")
	drawer_button.text = L10n.t("SCHOWAJ ↓") if drawer_open else L10n.t("ARSENAŁ ↑")
	for node in [game.map_mode_button, drawer_button, game.controls[9]]:
		Epic._fit_button(node)
	game.controls[9].text = L10n.t("GRAJ PONOWNIE") if game.phase == "END" else L10n.t("ROZPOCZNIJ ATAK") if game.phase == "PREP" else L10n.t("BITWA TRWA")
	if phase_seen != game.phase:
		phase_seen = game.phase
		if game.phase == "ATTACK":
			set_drawer_open(false)
			follow_action = true
		elif game.phase == "PREP":
			set_drawer_open(true)
			focus_location(-950.0)

func _process(delta: float) -> void:
	if camera_tween != null and camera_tween.is_running():
		game.arena.queue_redraw()
		return
	if game.phase != "ATTACK" or overview or not follow_action or pointer_down:
		return
	var total := 0.0
	var count := 0
	for unit in game.units:
		if int(unit["side"]) == 0 and int(unit["lane"]) == game.lane and float(unit["position"]) >= 0:
			total += game._point(game.lane, float(unit["position"]), 0).x
			count += 1
	if count > 0:
		var target: float = _clamp_offset(-total / float(count) * game.camera_zoom)
		game.camera_offset.x = lerpf(game.camera_offset.x, target, minf(1, delta * 4.0))

func _refresh_navigation(node: Node) -> void:
	if node is Button and node.has_meta("caption_key"):
		node.text = L10n.t(str(node.get_meta("caption_key")))
	for child in node.get_children():
		_refresh_navigation(child)
