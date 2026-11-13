extends Control
const L10n = preload("res://scripts/localization.gd")
## Premium full-screen in-match result presentation.
## Animated stardust, illuminated title, buttons and original victory/defeat
## instrumental cues are real Godot controls, not a flattened poster.
signal play_again_requested
signal main_menu_requested

const OutcomeMusic = preload("res://scripts/outcome_music.gd")
const Epic = preload("res://scripts/epic_theme.gd")
const AccountPanel = preload("res://scripts/account_progress_panel.gd")
const MobileLayout = preload("res://scripts/mobile_layout.gd")
var confetti: CPUParticles2D
var backdrop: ColorRect
var centerpiece: VBoxContainer
var score_player: AudioStreamPlayer
var is_victory := false
var reduced_motion := false
var effect_count := 46
var music_enabled := true
var account
var account_reward: Dictionary = {}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 100
	Epic.backdrop(self, 0.28)
	backdrop = ColorRect.new()
	backdrop.color = Color(0.02, 0.02, 0.08, 0.0)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	confetti = CPUParticles2D.new()
	confetti.amount = effect_count
	confetti.lifetime = 2.3
	confetti.one_shot = false
	confetti.explosiveness = 0.0
	confetti.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	confetti.emission_rect_extents = Vector2(265, 140)
	confetti.direction = Vector2(0, -1)
	confetti.spread = 165.0
	confetti.gravity = Vector2(0, 30)
	confetti.initial_velocity_min = 48.0
	confetti.initial_velocity_max = 135.0
	confetti.scale_amount_min = 0.45
	confetti.scale_amount_max = 1.5
	add_child(confetti)
	resized.connect(_recenter_particles)
	_recenter_particles()
	score_player = AudioStreamPlayer.new()
	score_player.name = "CinematicResultScore"
	score_player.volume_db = -8.0
	add_child(score_player)

func _recenter_particles() -> void:
	if confetti != null:
		confetti.position = size * 0.5
	var margin := get_node_or_null("ResultSafeMargin") as MarginContainer
	if margin != null:
		var safe: Rect2 = MobileLayout.safe_rect(self)
		margin.offset_left = safe.position.x + 16
		margin.offset_top = safe.position.y + 16
		margin.offset_right = safe.end.x - size.x - 16
		margin.offset_bottom = safe.end.y - size.y - 16
		if is_instance_valid(centerpiece):
			centerpiece.custom_minimum_size.x = minf(590, maxf(300, safe.size.x - 40))

func _new_title(title_text: String, font_size: int, tint: Color) -> Label:
	var label := Label.new()
	label.text = L10n.t(title_text)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	label.add_theme_color_override("font_shadow_color", Color(0.04, 0.02, 0.12, 0.97))
	label.add_theme_constant_override("shadow_offset_x", 3)
	label.add_theme_constant_override("shadow_offset_y", 4)
	if font_size >= 28:
		Epic.heading(label, font_size)
		label.clip_text = true
		label.resized.connect(_fit_title.bind(label, font_size))
	else:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", tint)
	return label

func _fit_title(label: Label, maximum: int) -> void:
	var font_size: int = maximum
	while font_size > 23 and Epic.DISPLAY_FONT.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > label.size.x - 8:
		font_size -= 1
	label.add_theme_font_size_override("font_size", font_size)

func present(victory: bool, draw: bool, reason: String, wave: int, our_gold: int, enemy_gold: int) -> void:
	is_victory = victory
	var gold: Color = Color("ffd47e") if victory else Color("e7a1bb")
	var highlight: Color = Color("b57bff") if victory else Color("a04065")
	confetti.color = Color("ffe190") if victory else Color("aa92df")
	confetti.emitting = not reduced_motion
	var shadow_frame := PanelContainer.new()
	shadow_frame.add_theme_stylebox_override("panel", Epic.panel(26))
	var margin := MarginContainer.new()
	margin.name = "ResultSafeMargin"
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(margin)
	var scroll := ScrollContainer.new()
	scroll.name = "ResultScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scroll.add_child(center)
	centerpiece = VBoxContainer.new()
	centerpiece.custom_minimum_size = Vector2(minf(size.x - 40.0, 590.0), 0)
	centerpiece.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	centerpiece.add_theme_constant_override("separation", 13)
	center.add_child(centerpiece)
	centerpiece.add_child(shadow_frame)
	var inside := VBoxContainer.new()
	inside.add_theme_constant_override("separation", 12)
	shadow_frame.add_child(inside)
	var crest := TextureRect.new()
	crest.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	crest.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	crest.custom_minimum_size.y = 95
	crest.texture = load(Epic.WORDMARK) as Texture2D
	inside.add_child(crest)
	var ornament := _new_title("✦   ✦   ✦", 28, highlight)
	inside.add_child(ornament)
	var headline := _new_title(L10n.t("VICTORY") if victory else L10n.t("DRAW") if draw else L10n.t("DEFEAT"),
		75 if victory else 71, gold)
	headline.name = "OutcomeHeadline"
	inside.add_child(headline)
	var verdict := L10n.t("THE ENEMY VAULT HAS FALLEN") if victory else L10n.t("BOTH VAULTS STAND EMPTY") if draw else L10n.t("YOUR VAULT HAS FALLEN")
	inside.add_child(_new_title(verdict, 21, Color("e4d8eb")))
	var flourish := ColorRect.new()
	flourish.custom_minimum_size = Vector2(10, 3)
	flourish.color = highlight
	inside.add_child(flourish)
	var stats := _new_title(L10n.t("WAVE %d   ✦   YOUR GOLD %d   ✦   ENEMY GOLD %d") % [wave, our_gold, enemy_gold],
		17, Color("d5c5e8"))
	stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inside.add_child(stats)
	inside.add_child(_new_title(reason, 16, Color("b9a9d3")))
	if account != null:
		var account_panel := AccountPanel.new()
		account_panel.name = "OutcomeAccountProgress"
		account_panel.profile = account
		account_panel.reward = account_reward
		inside.add_child(account_panel)
	var replay := Button.new()
	replay.name = "PlayAgain"
	replay.custom_minimum_size = Vector2(0, 77)
	replay.text = L10n.t("GRAJ PONOWNIE")
	replay.focus_mode = Control.FOCUS_NONE
	Epic.button(replay, true, 23)
	inside.add_child(replay)
	replay.pressed.connect(func() -> void: play_again_requested.emit())
	var menu := Button.new()
	menu.name = "MainMenu"
	menu.text = L10n.t("WRÓĆ DO MENU")
	menu.custom_minimum_size = Vector2(0, 66)
	menu.focus_mode = Control.FOCUS_NONE
	Epic.button(menu, false, 20)
	inside.add_child(menu)
	menu.pressed.connect(func() -> void: main_menu_requested.emit())
	call_deferred("_recenter_particles")
	centerpiece.pivot_offset = Vector2(centerpiece.size.x * 0.5, centerpiece.size.y * 0.5)
	centerpiece.scale = Vector2.ONE if reduced_motion else Vector2(0.70, 0.70)
	centerpiece.modulate.a = 0.0
	var entrance := create_tween()
	entrance.set_parallel(true)
	entrance.tween_property(backdrop, "color", Color(0.02, 0.01, 0.08, 0.30), 0.7)
	entrance.tween_property(centerpiece, "modulate:a", 1.0, 0.85)
	if not reduced_motion:
		entrance.tween_property(centerpiece, "scale", Vector2.ONE, 0.75).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		var pulse := create_tween().set_loops()
		pulse.tween_property(headline, "modulate", Color(1.0, 0.90, 0.68), 1.35)
		pulse.tween_property(headline, "modulate", Color.WHITE, 1.35)
	if music_enabled:
		score_player.stream = OutcomeMusic.render(victory, draw)
		score_player.play()
