extends Control
## An accessible, localized report overlay. Never modifies simulation state.
signal dismissed
const L10n = preload("res://scripts/localization.gd")
const Epic = preload("res://scripts/epic_theme.gd")
var summary: Dictionary = {}
var card: PanelContainer
var report_scroll: ScrollContainer
var continue_button: Button

func _ready() -> void:
	name = "WaveSummaryOverlay"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 112
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.015, 0.025, 0.07, 0.92)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var margins := MarginContainer.new()
	margins.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margins.add_theme_constant_override("margin_" + side, 16)
	add_child(margins)
	var centered := CenterContainer.new()
	margins.add_child(centered)
	card = PanelContainer.new()
	card.name = "WaveSummaryCard"
	card.add_theme_stylebox_override("panel", Epic.panel(17))
	centered.add_child(card)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	card.add_child(content)
	var title := Label.new()
	title.name = "WaveSummaryTitle"
	title.text = L10n.t("FALA %d — PODSUMOWANIE") % int(summary.get("wave", 0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Epic.heading(title, 26)
	content.add_child(title)
	var subtitle := Label.new()
	subtitle.text = L10n.t("Twoja armia • skarbiec • straty")
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 17)
	subtitle.add_theme_color_override("font_color", Color("c9ddeb"))
	content.add_child(subtitle)
	report_scroll = ScrollContainer.new()
	report_scroll.name = "WaveSummaryScroll"
	report_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(report_scroll)
	var details := VBoxContainer.new()
	details.add_theme_constant_override("separation", 9)
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	report_scroll.add_child(details)
	_section(details, "ZŁOTO I SKARBIEC")
	_line(details, "Dostarczone złoto", int(summary["delivered"][0]), Color("86edab"), true)
	_line(details, "Złoto wyniesione przez wroga", -int(summary["delivered"][1]), Color("ff9c9c"))
	_line(details, "Odsetki", int(summary["interest"][0]), Color("86edab"), true)
	_line(details, "Presja skarbców", -int(summary["pressure"]), Color("ffc38c"))
	_line(details, "Bilans złota od rozpoczęcia ataku", int(summary["net"][0]), Color("86edab") if int(summary["net"][0]) >= 0 else Color("ff9c9c"), true)
	_section(details, "STRATY W BITWIE")
	_line(details, "Twoi polegli najeźdźcy", int(summary["raiders_lost"][0]), Color("ffbd9d"))
	_line(details, "Pokonani najeźdźcy wroga", int(summary["raiders_lost"][1]), Color("a7e6bd"))
	_line(details, "Twoi polegli obrońcy", int(summary["defenders_lost"][0]), Color("ffbd9d"))
	_line(details, "Pokonani obrońcy wroga", int(summary["defenders_lost"][1]), Color("a7e6bd"))
	_section(details, "STAN SKARBCÓW")
	_line(details, "Twój skarbiec", int(summary["ending"][0]), Color("f5d68c"))
	_line(details, "Skarbiec wroga", int(summary["ending"][1]), Color("d7cade"))
	var note := Label.new()
	note.text = L10n.t("Bilans obejmuje dostawy, odsetki i presję. Zakupy wykonane przed atakiem nie są liczone ponownie.")
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", 15)
	note.add_theme_color_override("font_color", Color("aebdd3"))
	details.add_child(note)
	continue_button = Button.new()
	continue_button.name = "ResumeAfterSummary"
	continue_button.text = L10n.t("WZNÓW PRZYGOTOWANIE")
	continue_button.custom_minimum_size.y = 64
	Epic.button(continue_button, true, 18)
	content.add_child(continue_button)
	continue_button.pressed.connect(func() -> void: dismissed.emit())
	resized.connect(_layout)
	call_deferred("_layout")

func _section(parent: VBoxContainer, heading: String) -> void:
	var label := Label.new()
	label.text = L10n.t(heading)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color("f9d99b"))
	parent.add_child(label)

func _line(parent: VBoxContainer, caption: String, value: int, ink: Color, positive_sign: bool = false) -> void:
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 9)
	parent.add_child(line)
	var label := Label.new()
	label.text = L10n.t(caption)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color("d9e1ed"))
	line.add_child(label)
	var number := Label.new()
	number.text = ("+" if positive_sign and value >= 0 else "") + str(value)
	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	number.add_theme_font_size_override("font_size", 18)
	number.add_theme_color_override("font_color", ink)
	line.add_child(number)

func _layout() -> void:
	if not is_instance_valid(card) or size.x <= 0.0 or size.y <= 0.0:
		return
	card.custom_minimum_size.x = minf(600.0, maxf(260.0, size.x - 52.0))
	report_scroll.custom_minimum_size.y = minf(390.0, maxf(140.0, size.y - 230.0))
