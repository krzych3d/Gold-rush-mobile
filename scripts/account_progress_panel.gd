extends PanelContainer
## Shared ornate account badge. Reward animation changes presentation only.
signal reward_animation_finished
const L10n = preload("res://scripts/localization.gd")
const Epic = preload("res://scripts/epic_theme.gd")
const Catalog = preload("res://scripts/game_catalog.gd")
const XPBar = preload("res://scripts/epic_xp_bar.gd")
const GoldFlight = preload("res://scripts/xp_reward_flight.gd")
var profile
var reward: Dictionary = {}
var allow_motion := true
var coin_budget := 12
var show_reward_summary := true
var reward_origin: Control
var visual_done := true
var displayed_xp := 0
var level_label: Label
var level_number: Label
var xp_label: Label
var next_unlock: Label
var bar: ProgressBar
var flight: Control
var flight_layer: CanvasLayer
var notices: Array[Label] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_stylebox_override("panel", Epic.panel(14))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	add_child(column)
	if show_reward_summary and not reward.is_empty():
		var summary := Label.new()
		summary.name = "MatchXPSummary"
		summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		summary.add_theme_font_size_override("font_size", 18)
		summary.add_theme_color_override("font_color", Color("b6f5ba"))
		summary.text = L10n.t("+%d EXP za mecz") % int(reward.get("gained", 0))
		if reward.get("status") == "ineligible":
			summary.text = L10n.t("EXP po ukończeniu rozgrywki")
		elif reward.get("status") == "save_failed":
			summary.text = L10n.t("Nie udało się zapisać EXP. Postęp konta zachowany.")
		elif profile.level() == profile.MAX_LEVEL and int(reward.get("gained", 0)) == 0:
			summary.text = L10n.t("Maksymalny poziom konta")
		elif int(reward.get("level", 1)) > int(reward.get("before_level", 1)):
			summary.text += " • " + L10n.t("AWANS NA POZIOM %d") % int(reward["level"])
		column.add_child(summary)
		if reward_origin == null:
			reward_origin = summary
		for race in reward.get("unlocked", []):
			var unlocked := Label.new()
			unlocked.name = "UnlockedRace%d" % int(race)
			unlocked.text = L10n.t("ODBLOKOWANO: %s") % L10n.t(Catalog.RACE_TITLES[int(race)])
			unlocked.add_theme_color_override("font_color", Epic.GOLD)
			unlocked.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			unlocked.set_meta("unlock_level", profile.UNLOCK_LEVELS[int(race)])
			column.add_child(unlocked)
			notices.append(unlocked)
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 10)
	column.add_child(body)
	var crest := Control.new()
	crest.name = "AccountLevelCrest"
	crest.custom_minimum_size = Vector2(58, 58)
	crest.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	body.add_child(crest)
	var art := TextureRect.new()
	art.texture = load("res://assets/ui/lobby/level_crest.svg") as Texture2D
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	crest.add_child(art)
	level_number = Label.new()
	level_number.name = "AccountLevelNumber"
	level_number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	Epic.heading(level_number, 25)
	level_number.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	crest.add_child(level_number)
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation", 3)
	body.add_child(details)
	var row := HBoxContainer.new()
	details.add_child(row)
	level_label = Label.new()
	level_label.name = "AccountLevel"
	level_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	Epic.heading(level_label, 18)
	row.add_child(level_label)
	xp_label = Label.new()
	xp_label.add_theme_font_size_override("font_size", 16)
	xp_label.add_theme_color_override("font_color", Epic.COPY)
	row.add_child(xp_label)
	bar = XPBar.new()
	bar.name = "AccountXPBar"
	details.add_child(bar)
	next_unlock = Label.new()
	next_unlock.name = "NextRaceUnlock"
	next_unlock.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	next_unlock.add_theme_font_size_override("font_size", 15)
	next_unlock.add_theme_color_override("font_color", Epic.COPY)
	details.add_child(next_unlock)
	visual_done = not (reward.get("status") == "saved" and int(reward.get("gained", 0)) > 0)
	displayed_xp = profile.total_xp if visual_done else int(reward.get("before_xp", profile.total_xp - int(reward["gained"])))
	profile.changed.connect(refresh)
	_update_display()
	if not visual_done:
		call_deferred("_begin_reward_visual")

func refresh() -> void:
	if not visual_done and int(reward.get("after_xp", profile.total_xp)) != profile.total_xp:
		_finish_visual()
		return
	if visual_done:
		displayed_xp = profile.total_xp
	_update_display()

func _update_display() -> void:
	var shown_level: int = profile.level_for_xp(displayed_xp)
	level_label.text = L10n.t("POZIOM KONTA %d / 20") % shown_level
	level_number.text = str(shown_level)
	var maximum: bool = shown_level == profile.MAX_LEVEL
	var into: int = displayed_xp - profile.xp_for_level(shown_level)
	var needed: int = 1 if maximum else profile.xp_for_level(shown_level + 1) - profile.xp_for_level(shown_level)
	xp_label.text = "MAX" if maximum else "%d / %d EXP" % [into, needed]
	bar.max_value = needed
	bar.value = 1 if maximum else into
	next_unlock.text = L10n.t("Elfy: poziom 5 • Pustka: poziom 10") if shown_level < 5 else L10n.t("Następne odblokowanie: Pustka — poziom 10") if shown_level < 10 else L10n.t("Wszystkie rasy odblokowane")
	for label in notices:
		label.visible = shown_level >= int(label.get_meta("unlock_level"))
	if profile.load_failed:
		next_unlock.text = L10n.t("Nie można odczytać postępu. Zapis konta nie zostanie nadpisany.")

func _begin_reward_visual() -> void:
	if visual_done:
		return
	if not allow_motion:
		_finish_visual()
		return
	flight_layer = CanvasLayer.new()
	flight_layer.name = "XPRewardLayer"
	flight_layer.layer = 120
	add_child(flight_layer)
	flight = GoldFlight.new()
	flight.name = "GoldToAccountXP"
	flight.target = bar
	flight.origin = reward_origin
	flight.budget = coin_budget
	flight.delay = 0.85 if show_reward_summary else 0.2
	flight.delivered.connect(_on_delivery)
	flight.finished.connect(_finish_visual)
	flight_layer.add_child(flight)
	bar.set_energized(true)

func _on_delivery(fraction: float) -> void:
	var previous_level: int = profile.level_for_xp(displayed_xp)
	var initial: int = int(reward.get("before_xp", profile.total_xp - int(reward.get("gained", 0))))
	var final: int = int(reward.get("after_xp", profile.total_xp))
	displayed_xp = clampi(int(round(lerpf(initial, final, fraction))), initial, final)
	_update_display()
	if profile.level_for_xp(displayed_xp) > previous_level:
		bar.level_flash()
		level_number.modulate = Color("fff4ae")
		create_tween().tween_property(level_number, "modulate", Color.WHITE, 0.45)

func _finish_visual() -> void:
	if visual_done:
		return
	visual_done = true
	displayed_xp = profile.total_xp
	bar.set_energized(false)
	_update_display()
	if is_instance_valid(flight_layer):
		flight_layer.queue_free()
	flight = null
	reward_animation_finished.emit()
