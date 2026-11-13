extends PanelContainer
## Shared account badge for home and the actual match result.
const L10n = preload("res://scripts/localization.gd")
const Epic = preload("res://scripts/epic_theme.gd")
const Catalog = preload("res://scripts/game_catalog.gd")
var profile
var reward: Dictionary = {}
var level_label: Label
var xp_label: Label
var next_unlock: Label
var bar: ProgressBar

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_stylebox_override("panel", Epic.panel(14))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	add_child(column)
	if not reward.is_empty():
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
		for race in reward.get("unlocked", []):
			var unlocked := Label.new()
			unlocked.name = "UnlockedRace%d" % int(race)
			unlocked.text = L10n.t("ODBLOKOWANO: %s") % L10n.t(Catalog.RACE_TITLES[int(race)])
			unlocked.add_theme_color_override("font_color", Epic.GOLD)
			unlocked.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			column.add_child(unlocked)
	var row := HBoxContainer.new()
	column.add_child(row)
	level_label = Label.new()
	level_label.name = "AccountLevel"
	level_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	Epic.heading(level_label, 18)
	row.add_child(level_label)
	xp_label = Label.new()
	xp_label.add_theme_font_size_override("font_size", 16)
	xp_label.add_theme_color_override("font_color", Epic.COPY)
	row.add_child(xp_label)
	bar = ProgressBar.new()
	bar.name = "AccountXPBar"
	bar.custom_minimum_size.y = 7
	bar.show_percentage = false
	var background := StyleBoxFlat.new()
	background.bg_color = Color("171428")
	background.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("background", background)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("d9ac51")
	fill.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("fill", fill)
	column.add_child(bar)
	next_unlock = Label.new()
	next_unlock.name = "NextRaceUnlock"
	next_unlock.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	next_unlock.add_theme_font_size_override("font_size", 15)
	next_unlock.add_theme_color_override("font_color", Epic.COPY)
	column.add_child(next_unlock)
	profile.changed.connect(refresh)
	refresh()

func refresh() -> void:
	level_label.text = L10n.t("POZIOM KONTA %d / 20") % profile.level()
	var maximum: bool = profile.level() == profile.MAX_LEVEL
	xp_label.text = "MAX" if maximum else "%d / %d EXP" % [profile.xp_in_level(), profile.xp_needed()]
	bar.max_value = 1 if maximum else profile.xp_needed()
	bar.value = 1 if maximum else profile.xp_in_level()
	next_unlock.text = L10n.t("Elfy: poziom 5 • Pustka: poziom 10") if profile.level() < 5 else L10n.t("Następne odblokowanie: Pustka — poziom 10") if profile.level() < 10 else L10n.t("Wszystkie rasy odblokowane")
	if profile.load_failed:
		next_unlock.text = L10n.t("Nie można odczytać postępu. Zapis konta nie zostanie nadpisany.")
