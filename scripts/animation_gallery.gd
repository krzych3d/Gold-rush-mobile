extends Control
const L10n = preload("res://scripts/localization.gd")
const Epic = preload("res://scripts/epic_theme.gd")
## In-game QA viewer for the actual animation atlases used by the battlefield.
## No additional image generation, network requests, or paid APIs.

const UNIT_NAMES := [
	"DWARF DEFENDER", "DWARF CARRIER", "ELF RANGER", "ARCANE MAGE",
	"GOBLIN RAIDER", "GOBLIN SABOTEUR", "SHADOW WOLF",
	"VOID SENTINEL", "VOID STALKER", "VOID COLLECTOR", "VOID WEAVER"
]
const SHEET_PATHS := [
	"res://assets/epic/animations/dwarf_defender_sheet.png",
	"res://assets/epic/animations/dwarf_carrier_sheet.png",
	"res://assets/epic/animations/elf_ranger_sheet.png",
	"res://assets/epic/animations/arcane_mage_sheet.png",
	"res://assets/epic/animations/goblin_raider_sheet.png",
	"res://assets/epic/animations/goblin_saboteur_sheet.png",
	"res://assets/epic/animations/shadow_wolf_sheet.png",
	"res://assets/epic/animations/void_sentinel_sheet.png",
	"res://assets/epic/animations/void_stalker_sheet.png",
	"res://assets/epic/animations/void_collector_sheet.png",
	"res://assets/epic/animations/void_weaver_sheet.png"
]
const ACTION_NAMES := ["IDLE", "WALK", "ATTACK", "HIT", "DEATH", "DEPOSIT", "CARRY"]
const ACTION_ROWS := [0, 1, 2, 3, 4, 5, 1]
const ACTION_FPS := [5.0, 10.0, 11.0, 10.0, 11.0, 10.0, 10.0]
const GOBLIN_FRAMES := [8, 12, 12, 8, 16, 12, 12]
# Supplemental action atlases are optional; they appear after importing the PNG ZIP.
const SPECIAL_PATHS := {
	0: "res://assets/epic/animations/dwarf_defender_special_sheet.png",
	1: "res://assets/epic/animations/dwarf_carrier_special_sheet.png",
	2: "res://assets/epic/animations/elf_ranger_special_sheet.png",
	3: "res://assets/epic/animations/arcane_mage_special_sheet.png",
	4: "res://assets/epic/animations/goblin_raider_special_sheet.png",
	5: "res://assets/epic/animations/goblin_saboteur_special_sheet.png",
	6: "res://assets/epic/animations/shadow_wolf_special_sheet.png"
}
const SPECIAL_NAMES := {
	0: ["RUN", "SHIELD CHARGE", "HAMMER STRIKE", "BLOCK", "EARTHQUAKE", "BATTLE CRY"],
	1: ["RUN", "PICK UP GOLD", "CARRY GOLD", "ROLL", "GOLD THROW", "CELEBRATE"],
	2: ["RUN", "LEAP", "POWER SHOT", "DODGE", "ARROW VOLLEY", "BLOOM"],
	3: ["RUN", "TELEPORT", "SHIELD", "BEAM", "RUNE", "VICTORY"],
	4: ["SPRINT", "LEAP", "COMBO", "DODGE", "TAUNT", "STEALTH"],
	5: ["SNEAK", "BOMB", "EXPLOSION", "ROLL", "SMOKE", "TAUNT"],
	6: ["SPRINT", "POUNCE", "FRENZY", "SHADOW DASH", "HOWL", "SPAWN"]
}


var selected_unit := 4
var selected_action := 0
var facing_right := true
var elapsed := 0.0
var preview: Control
var unit_label: Label
var action_label: Label
var frame_label: Label
var atlases: Array[Texture2D] = []
var goblin_strips: Dictionary = {}
var special_atlases: Dictionary = {}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	for index in SHEET_PATHS.size():
		var source_path: String = SHEET_PATHS[index]
		if ResourceLoader.exists(source_path):
			atlases.append(load(source_path) as Texture2D)
		else:
			# Temporary playable fallbacks until the owner's PNG ZIP is imported.
			var fallback_index: int = {7: 0, 8: 5, 9: 1, 10: 3}.get(index, 0)
			atlases.append(load(SHEET_PATHS[fallback_index]) as Texture2D)
	for hero_index in SPECIAL_PATHS.keys():
		var special_path: String = SPECIAL_PATHS[hero_index]
		if ResourceLoader.exists(special_path):
			var special_tex := load(special_path) as Texture2D
			if special_tex != null and special_tex.get_size() == Vector2(1024, 768):
				special_atlases[hero_index] = special_tex
	for i in ACTION_NAMES.size():
		var path: String = "res://assets/epic/animations/goblin_raider_%s.png" % ACTION_NAMES[i].to_lower()
		if ResourceLoader.exists(path):
			var strip := load(path) as Texture2D
			if strip != null and strip.get_height() == 192 and strip.get_width() == GOBLIN_FRAMES[i] * 192:
				goblin_strips[i] = strip
	Epic.backdrop(self, 0.56)
	var margins := MarginContainer.new()
	margins.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margins.add_theme_constant_override("margin_left", 18)
	margins.add_theme_constant_override("margin_right", 18)
	margins.add_theme_constant_override("margin_top", 22)
	margins.add_theme_constant_override("margin_bottom", 22)
	add_child(margins)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	margins.add_child(layout)
	var title := Label.new()
	title.text = L10n.t("GALERIA POSTACI")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_decorate(title, 32, Color("f6d18b"))
	layout.add_child(title)
	var sub := Label.new()
	sub.text = L10n.t("Wybierz bohatera i poznaj jego ruchy")
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_decorate(sub, 15, Color("b4cadf"))
	layout.add_child(sub)
	var unit_controls := HBoxContainer.new()
	layout.add_child(unit_controls)
	_add_button(unit_controls, "◀ POSTAĆ", _change_unit.bind(-1))
	unit_label = Label.new()
	unit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	unit_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_decorate(unit_label, 19, Color("f5e3bd"))
	unit_controls.add_child(unit_label)
	_add_button(unit_controls, "POSTAĆ ▶", _change_unit.bind(1))
	var factions := HBoxContainer.new()
	factions.add_theme_constant_override("separation", 4)
	layout.add_child(factions)
	for index in 4:
		_add_button(factions, [L10n.t("DWARVES"), L10n.t("GOBLINS"), L10n.t("ELVES"), L10n.t("VOIDBORN")][index], _select_faction_preview.bind(index))
	preview = Control.new()
	preview.custom_minimum_size = Vector2(0, 250)
	preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview.draw.connect(_draw_preview)
	layout.add_child(preview)
	frame_label = Label.new()
	frame_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_decorate(frame_label, 16, Color("9ad6cb"))
	layout.add_child(frame_label)
	var action_controls := HBoxContainer.new()
	layout.add_child(action_controls)
	_add_button(action_controls, L10n.t("◀ ACTION"), _change_action.bind(-1))
	action_label = Label.new()
	action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_decorate(action_label, 21, Color("f5e3bd"))
	action_controls.add_child(action_label)
	_add_button(action_controls, L10n.t("ACTION ▶"), _change_action.bind(1))
	var direction_controls := HBoxContainer.new()
	layout.add_child(direction_controls)
	_add_button(direction_controls, "ZMIEŃ KIERUNEK", _flip)
	_add_button(direction_controls, "WRÓĆ", _close)
	var footnote := Label.new()
	footnote.text = L10n.t("11 animated character roles. Base actions for every role, plus special sequences where available.")
	footnote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footnote.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_decorate(footnote, 13, Color("b4cadf"))
	layout.add_child(footnote)
	_refresh_labels()
	set_process(true)

func _decorate(label: Label, size: int, color: Color) -> void:
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	if size >= 21:
		Epic.heading(label, size)

func _add_button(parent: HBoxContainer, caption: String, handler: Callable) -> void:
	var button := Button.new()
	button.text = L10n.t(caption)
	button.custom_minimum_size = Vector2(120, 62)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 15)
	parent.add_child(button)
	Epic.button(button, false, 15)
	button.pressed.connect(handler)

func _select_faction_preview(faction: int) -> void:
	# Direct entry points for every faction, especially the previously missing Voidborn.
	selected_unit = [0, 4, 2, 7][clampi(faction, 0, 3)]
	selected_action = 0
	elapsed = 0.0
	_refresh_labels()

func _change_unit(direction: int) -> void:
	selected_unit = posmod(selected_unit + direction, UNIT_NAMES.size())
	if selected_action >= _action_count():
		selected_action = 0
	elapsed = 0.0
	_refresh_labels()

func _change_action(direction: int) -> void:
	selected_action = posmod(selected_action + direction, _action_count())
	elapsed = 0.0
	_refresh_labels()

func _action_count() -> int:
	return ACTION_NAMES.size() + (6 if special_atlases.has(selected_unit) else 0)

func _flip() -> void:
	facing_right = not facing_right
	_refresh_labels()

func _close() -> void:
	queue_free()

func _refresh_labels() -> void:
	unit_label.text = L10n.t(UNIT_NAMES[selected_unit])
	if selected_action >= ACTION_NAMES.size():
		var names: Array = SPECIAL_NAMES.get(selected_unit, [])
		action_label.text = L10n.t(names[selected_action - ACTION_NAMES.size()]) if selected_action - ACTION_NAMES.size() < names.size() else L10n.t("SPECIAL")
	else:
		action_label.text = L10n.t(ACTION_NAMES[selected_action])
	preview.queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	preview.queue_redraw()

func _draw_preview() -> void:
	var center := Vector2(preview.size.x * 0.5, preview.size.y * 0.67)
	preview.draw_rect(Rect2(Vector2.ZERO, preview.size), Color("15243b"))
	for j in 5:
		var off: float = float(j - 2) * 52.0
		preview.draw_line(center + Vector2(-155, 19 + off * 0.15), center + Vector2(155, 19 + off * 0.15), Color("527185", 0.14), 2)
	preview.draw_circle(center + Vector2(0, 15), 70, Color("060e1c", 0.5))
	var is_special: bool = selected_action >= ACTION_NAMES.size()
	var strip: Texture2D = goblin_strips.get(selected_action) if selected_unit == 4 and not is_special else null
	var source: Texture2D = special_atlases.get(selected_unit) if is_special else strip if strip != null else atlases[selected_unit]
	if source == null:
		frame_label.text = L10n.t("MISSING SOURCE TEXTURE")
		return
	var cell: int = 192 if strip != null else 128
	var frame_count: int = int(source.get_width() / cell) if strip != null else 8
	var fps: float = 12.0 if is_special else ACTION_FPS[selected_action]
	var frame: int = int(floor(elapsed * fps)) % frame_count
	var row: int = selected_action - ACTION_NAMES.size() if is_special else 0 if strip != null else ACTION_ROWS[selected_action]
	var hero_height: float = minf(preview.size.y * 0.64, 245.0)
	var hero_width: float = hero_height
	var flip: float = 1.0 if facing_right else -1.0
	preview.draw_set_transform(center, 0.0, Vector2(flip, 1.0))
	preview.draw_texture_rect_region(source,
		Rect2(Vector2(-hero_width * 0.5, -hero_height), Vector2(hero_width, hero_height)),
		Rect2(Vector2(float(frame * cell), float(row * cell)), Vector2(cell, cell)))
	preview.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	frame_label.text = L10n.t("FRAME %d/%d • %s • %s") % [
		frame + 1, frame_count, L10n.t("SPECIAL ATLAS") if is_special else L10n.t("EXTRA STRIP") if strip != null else L10n.t("6-ROW ATLAS"),
		L10n.t("RIGHT") if facing_right else L10n.t("LEFT")
	]
