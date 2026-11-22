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
var summary_button: Button
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
var last_player_gold_risk := -1
var last_enemy_gold_risk := -1
var command_top := 0.0
var usable := Rect2()
# Visual-only events; currency and combat state are always committed in game.gd.
const GOLD_FLIGHT_SECONDS := 0.85
const VAULT_FLASH_SECONDS := 0.45
var gold_flights: Array[Dictionary] = []
var vault_flashes: Array[float] = [0.0, 0.0]
var effects_canvas: Control

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
	# One small overlay for all coin trails. It never captures taps.
	effects_canvas = Control.new()
	effects_canvas.name = "BattleGoldFeedback"
	effects_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effects_canvas.z_index = 30
	add_child(effects_canvas)
	effects_canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	effects_canvas.draw.connect(_draw_gold_feedback)
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
	summary_button = _button(navigation, L10n.t("WYNIK"), game._show_wave_summary, 92)
	summary_button.name = "ViewWaveSummary"
	summary_button.custom_minimum_size.y = 56
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
	if game.tutorial_mode:
		return # Guided lane buttons remain the only active training input.
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
	# Only mutate real controls when values actually change. Theme mutations and
	# repeated font measurements were expensive on entry-level Android devices.
	var player_caption: String = L10n.t("ZŁOTO %d") % game.gold[0]
	if game.hud.text != player_caption:
		game.hud.text = player_caption
	var enemy_caption: String = "%s %d" % [L10n.t(game.RACE_NAMES[game.bot_race]), game.gold[1]]
	if enemy_gold.text != enemy_caption:
		enemy_gold.text = enemy_caption
	var player_risk: int = 1 if game.gold[0] <= 250 else 0
	var enemy_risk: int = 1 if game.gold[1] <= 250 else 0
	if player_risk != last_player_gold_risk:
		last_player_gold_risk = player_risk
		game.hud.add_theme_color_override("font_color", Color("ff8d84") if player_risk == 1 else Color("f6d68c"))
	if enemy_risk != last_enemy_gold_risk:
		last_enemy_gold_risk = enemy_risk
		enemy_gold.add_theme_color_override("font_color", Color("ffe1a4") if enemy_risk == 1 else Color("ffb7a8"))
	var timer_caption: String = L10n.t("FALA %d • %s\n%d s • odsetki %d%%") % [
		game.wave, L10n.t("PRZYGOTOWANIE") if game.phase == "PREP" else L10n.t("BITWA"),
		int(maxf(0, ceilf(game.remaining))), int(game.interest_rate(game.selected_race, game.bank_level) * 100)]
	if game.wave >= game.Rules.PRESSURE_START:
		timer_caption += L10n.t(" • presja %d") % game.Rules.vault_pressure(game.wave)
	if game.tutorial_mode:
		timer_caption = L10n.t("SAMOUCZEK • BEZ LIMITU CZASU")
	if game.timer_label.text != timer_caption:
		game.timer_label.text = timer_caption
	var report_caption: String = L10n.t("WYNIK")
	if summary_button.text != report_caption:
		summary_button.text = report_caption
	summary_button.disabled = game.last_wave_summary.is_empty() or game.tutorial_mode or game.phase != "PREP"
	var drawer_caption: String = L10n.t("SCHOWAJ ↓") if drawer_open else L10n.t("ARSENAŁ ↑")
	if drawer_button.text != drawer_caption:
		drawer_button.text = drawer_caption
		Epic._fit_button(drawer_button)
	var action_caption: String = L10n.t("GRAJ PONOWNIE") if game.phase == "END" else L10n.t("ROZPOCZNIJ ATAK") if game.phase == "PREP" else L10n.t("BITWA TRWA")
	if game.tutorial_mode:
		action_caption = L10n.t("POKAŻ PRZYKŁAD")
	if game.controls[9].text != action_caption:
		game.controls[9].text = action_caption
		Epic._fit_button(game.controls[9])
	if phase_seen != game.phase:
		phase_seen = game.phase
		if game.phase == "ATTACK" and landscape:
			set_drawer_open(false)
		elif game.phase == "PREP" and not landscape:
			set_drawer_open(true, false)


func queue_gold_flight(side: int, path: int, amount: int) -> void:
	# Only a completed return can create this effect; no duplicate currency.
	if amount <= 0 or side < 0 or side > 1 or path < 0 or path >= 3:
		return
	if effects_canvas == null or game.presentation.reduced_motion:
		return
	gold_flights.append({"side": side, "lane": path, "amount": amount, "age": 0.0})
	var budget: int = 6 if game.presentation.effective_quality == "battery" else 12
	while gold_flights.size() > budget:
		gold_flights.pop_front()
	effects_canvas.queue_redraw()

func flash_vault(side: int, amount: int) -> void:
	# Highlight lost coins at the existing gold HUD, without changing combat.
	if amount <= 0 or side < 0 or side > 1 or effects_canvas == null:
		return
	if game.presentation.reduced_motion:
		return
	vault_flashes[side] = VAULT_FLASH_SECONDS
	effects_canvas.queue_redraw()

func _process(delta: float) -> void:
	if effects_canvas == null:
		return
	if game.presentation.reduced_motion:
		if not gold_flights.is_empty() or vault_flashes[0] > 0.0 or vault_flashes[1] > 0.0:
			gold_flights.clear()
			vault_flashes = [0.0, 0.0]
			effects_canvas.queue_redraw()
		return
	if gold_flights.is_empty() and vault_flashes[0] <= 0.0 and vault_flashes[1] <= 0.0:
		return
	for index in range(gold_flights.size() - 1, -1, -1):
		var flight: Dictionary = gold_flights[index]
		flight["age"] = float(flight["age"]) + delta
		if float(flight["age"]) >= GOLD_FLIGHT_SECONDS:
			gold_flights.remove_at(index)
	for side in 2:
		vault_flashes[side] = maxf(0.0, vault_flashes[side] - delta)
	effects_canvas.queue_redraw()

func _gold_source(side: int, path: int) -> Vector2:
	var world: Vector2 = game._point(path, 0.0, side)
	var arena_local: Vector2 = game._sprite_transform(world).origin
	return effects_canvas.get_global_transform().affine_inverse() * (game.arena.get_global_transform() * arena_local)

func _gold_target(side: int) -> Vector2:
	var target: Label = game.hud if side == 0 else enemy_gold
	return effects_canvas.get_global_transform().affine_inverse() * target.get_global_rect().get_center()

func _draw_gold_feedback() -> void:
	if game.presentation.reduced_motion:
		return
	for side in 2:
		if vault_flashes[side] > 0.0:
			var progress: float = 1.0 - vault_flashes[side] / VAULT_FLASH_SECONDS
			var center: Vector2 = _gold_target(side)
			var color: Color = Color("ff796c") if side == 0 else Color("ffcc80")
			effects_canvas.draw_arc(center, 20.0 + 28.0 * progress,
				0.0, TAU, 24, Color(color.r, color.g, color.b, 0.78 * (1.0 - progress)), 3.0)
	for flight in gold_flights:
		var source: Vector2 = _gold_source(int(flight["side"]), int(flight["lane"]))
		var target: Vector2 = _gold_target(int(flight["side"]))
		var progress: float = clampf(float(flight["age"]) / GOLD_FLIGHT_SECONDS, 0.0, 1.0)
		var arc_height: float = 30.0 + minf(25.0, float(flight["amount"]) * 0.05)
		var motes: int = 3 if game.presentation.effective_quality == "battery" else 5
		for mote in motes:
			var delayed: float = clampf((progress - 0.035 * float(mote)) / (1.0 - 0.035 * float(mote)), 0.0, 1.0)
			var eased: float = delayed * delayed * (3.0 - 2.0 * delayed)
			var offset: Vector2 = Vector2(sin(float(mote) * 2.399) * 10.0, -arc_height * sin(eased * PI))
			var point: Vector2 = source.lerp(target, eased) + offset * (1.0 - eased * 0.5)
			var alpha: float = minf(1.0, delayed * 8.0) * (1.0 - 0.55 * eased)
			effects_canvas.draw_circle(point, 3.6 - 1.4 * eased, Color(1.0, 0.77, 0.25, alpha))
			effects_canvas.draw_circle(point + Vector2(-0.9, -1.0), 1.1, Color(1.0, 0.98, 0.72, alpha))

func _refresh_navigation(node: Node) -> void:
	if node is Button and node.has_meta("caption_key"):
		node.text = L10n.t(str(node.get_meta("caption_key")))
	for child in node.get_children():
		_refresh_navigation(child)
