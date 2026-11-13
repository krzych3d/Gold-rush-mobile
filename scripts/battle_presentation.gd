extends Control
## Fixed complete map. Portrait has commands below; landscape has a sliding arsenal.
const L10n = preload("res://scripts/localization.gd")
const Epic = preload("res://scripts/epic_theme.gd")
const MobileLayout = preload("res://scripts/mobile_layout.gd")
var game
var legacy_root: Control
var drawer: ScrollContainer
var dock: PanelContainer
var drawer_button: Button
var enemy_gold: Label
var header: MarginContainer
var overview := true
var drawer_open := false
var follow_action := false
var landscape := false
var drawer_tween: Tween
var pointer_down := false
var travel := 0.0
var phase_seen := ""
var last_language := ""
var command_top := 0.0
var usable := Rect2()

func _ready() -> void:
	name = "FullScreenBattle"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	legacy_root.hide()
	game.battlefield_frame.reparent(self)
	game.battlefield_frame.custom_minimum_size = Vector2.ZERO
	game.arena.custom_minimum_size = Vector2.ZERO
	game.battlefield_frame.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
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
	dock.add_theme_stylebox_override("panel", Epic.panel(8))
	add_child(dock)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	dock.add_child(row)
	drawer_button = _button(row, "ARSENAŁ ↑", set_drawer_open.bind(true), 210)
	drawer_button.name = "ArsenalToggle"
	drawer_button.pressed.disconnect(set_drawer_open.bind(true))
	drawer_button.pressed.connect(func() -> void: set_drawer_open(not drawer_open))
	game.controls[9].reparent(row)
	game.controls[9].custom_minimum_size.y = 66
	Epic.button(game.controls[9], true, 21)
	resized.connect(_layout)
	call_deferred("_layout")
	sync()

func _button(parent: Node, caption: String, handler: Callable, width: float = 0) -> Button:
	var button := Button.new()
	button.text = L10n.t(caption)
	button.set_meta("caption_key", caption)
	button.custom_minimum_size = Vector2(width, 58)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL if width == 0 else Control.SIZE_FILL
	parent.add_child(button)
	Epic.button(button, false, 18)
	button.pressed.connect(handler)
	return button

func _build_header() -> void:
	header = MarginContainer.new()
	header.name = "PermanentBattleHUD"
	header.z_index = 24
	add_child(header)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	header.add_child(column)
	var gold_panel := PanelContainer.new()
	gold_panel.name = "VisibleGoldCounter"
	gold_panel.add_theme_stylebox_override("panel", Epic.panel(8))
	column.add_child(gold_panel)
	var gold_row := HBoxContainer.new()
	gold_row.add_theme_constant_override("separation", 10)
	gold_panel.add_child(gold_row)
	var coin := TextureRect.new()
	coin.texture = load("res://assets/ui/ornate/coin.svg") as Texture2D
	coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coin.custom_minimum_size = Vector2(32, 32)
	gold_row.add_child(coin)
	game.hud.reparent(gold_row)
	game.hud.name = "PlayerGold"
	game.hud.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	Epic.heading(game.hud, 28)
	enemy_gold = Label.new()
	enemy_gold.name = "EnemyGold"
	enemy_gold.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	enemy_gold.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	enemy_gold.add_theme_font_size_override("font_size", 25)
	enemy_gold.add_theme_color_override("font_color", Color("ffb7a8"))
	gold_row.add_child(enemy_gold)
	var navigation := HBoxContainer.new()
	navigation.add_theme_constant_override("separation", 8)
	column.add_child(navigation)
	game.main_menu_button.reparent(navigation)
	game.main_menu_button.text = L10n.t("MENU")
	game.main_menu_button.custom_minimum_size = Vector2(138, 58)
	Epic.button(game.main_menu_button, false, 18)
	game.timer_label.reparent(navigation)
	game.timer_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	game.timer_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	game.timer_label.add_theme_font_size_override("font_size", 19)
	game.timer_label.add_theme_color_override("font_color", Color.WHITE)
	# Rotation chooses the layout; zoom/follow controls would crop the map.
	game.map_mode_button.reparent(navigation)
	game.map_mode_button.hide()
	game.performance_label.reparent(column)

func _layout() -> void:
	if drawer == null or size.x < 1 or size.y < 1:
		return
	var rotated: bool = landscape != (size.x > size.y)
	landscape = size.x > size.y
	usable = MobileLayout.safe_rect(self)
	if drawer_tween != null:
		drawer_tween.kill()
	if rotated:
		drawer_open = false if landscape else true
		pointer_down = false
		travel = INF
	drawer_button.visible = landscape
	var hud_width: float = minf(usable.size.x - 24, 750.0) if landscape else usable.size.x - 24
	header.position = usable.position + Vector2(12, 10)
	header.size = Vector2(hud_width, 0)
	dock.position = Vector2(usable.position.x + 10, usable.end.y - 92)
	dock.size = Vector2(usable.size.x - 20, 82)
	var map_top: float = usable.position.y + (144.0 if landscape else 156.0)
	var map_bottom: float = usable.end.y - 104.0
	if landscape:
		game.battlefield_frame.position = Vector2(usable.position.x + 10, map_top)
		game.battlefield_frame.size = Vector2(usable.size.x - 20, maxf(100, map_bottom - map_top))
		var command_bottom: float = usable.end.y - 100
		command_top = map_top + 6
		drawer.size = Vector2(minf(710, usable.size.x - 20), maxf(120, command_bottom - command_top))
		drawer.position.x = usable.end.x - drawer.size.x - 10
	else:
		var map_height: float = (usable.size.x - 20) * 1060.0 / 2400.0 + 24.0
		game.battlefield_frame.position = Vector2(usable.position.x + 10, map_top)
		game.battlefield_frame.size = Vector2(usable.size.x - 20, map_height)
		command_top = map_top + map_height + 10
		drawer.size = Vector2(usable.size.x - 20, maxf(100, usable.end.y - 100 - command_top))
		drawer.position.x = usable.position.x + 10
		drawer_open = true
	set_drawer_open(drawer_open, false)
	call_deferred("fit_camera")

func set_drawer_open(value: bool, animate: bool = true) -> void:
	drawer_open = value if landscape else true
	drawer_button.text = L10n.t("SCHOWAJ ↓") if drawer_open else L10n.t("ARSENAŁ ↑")
	if drawer_tween != null:
		drawer_tween.kill()
	drawer.show()
	var destination: float = command_top if drawer_open else usable.end.y + 8
	if animate and landscape and not game.presentation.reduced_motion:
		drawer_tween = create_tween()
		drawer_tween.tween_property(drawer, "position:y", destination, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		if not drawer_open:
			drawer_tween.tween_callback(drawer.hide)
	else:
		drawer.position.y = destination
		drawer.visible = drawer_open

func toggle_view() -> void:
	fit_camera()

func fit_camera() -> void:
	if game.arena.size.x <= 0 or game.arena.size.y <= 0:
		return
	overview = true
	follow_action = false
	game.overview_mode = true
	game.expanded_map = landscape
	game.camera_zoom = maxf(0.01, minf(game.arena.size.x / 2400.0, game.arena.size.y / 1060.0))
	game.camera_offset = Vector2.ZERO
	game.arena.queue_redraw()

func focus_location(_world_x: float) -> void:
	fit_camera()

func _follow() -> void:
	fit_camera()

func handle_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event is InputEventMouseButton and event.button_index != MOUSE_BUTTON_LEFT:
			return
		var was_down: bool = pointer_down
		pointer_down = event.pressed
		if event.pressed:
			travel = 0
		elif was_down and travel < 18:
			game._select_lane(game._nearest_lane(event.position))
	elif event is InputEventScreenDrag or (event is InputEventMouseMotion and pointer_down):
		travel += event.relative.length()
		# A swipe never pans this map or selects a different lane.

func sync() -> void:
	if enemy_gold == null:
		return
	if last_language != L10n.language:
		last_language = L10n.language
		_refresh_navigation(self)
	game.hud.text = L10n.t("ZŁOTO %d") % game.gold[0]
	enemy_gold.text = L10n.t("WRÓG %d") % game.gold[1]
	game.timer_label.text = L10n.t("FALA %d • %s\n%d s • odsetki %d%%") % [game.wave, L10n.t("PRZYGOTOWANIE") if game.phase == "PREP" else L10n.t("BITWA"), int(maxf(0, ceilf(game.remaining))), int(game.interest_rate(game.selected_race, game.bank_level) * 100)]
	drawer_button.text = L10n.t("SCHOWAJ ↓") if drawer_open else L10n.t("ARSENAŁ ↑")
	game.controls[9].text = L10n.t("GRAJ PONOWNIE") if game.phase == "END" else L10n.t("ROZPOCZNIJ ATAK") if game.phase == "PREP" else L10n.t("BITWA TRWA")
	for node in [drawer_button, game.controls[9]]:
		Epic._fit_button(node)
	if phase_seen != game.phase:
		phase_seen = game.phase
		if game.phase == "ATTACK" and landscape:
			set_drawer_open(false)
		elif game.phase == "PREP" and not landscape:
			set_drawer_open(true, false)

func _refresh_navigation(node: Node) -> void:
	if node is Button and node.has_meta("caption_key"):
		node.text = L10n.t(str(node.get_meta("caption_key")))
	for child in node.get_children():
		_refresh_navigation(child)
