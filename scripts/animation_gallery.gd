extends Control
## In-game QA viewer for the actual animation atlases used by the battlefield.
## No additional image generation, network requests, or paid APIs.

const UNIT_NAMES := [
	"DWARF DEFENDER", "DWARF CARRIER", "ELF RANGER", "ARCANE MAGE",
	"GOBLIN RAIDER", "GOBLIN SABOTEUR", "SHADOW WOLF"
]
const SHEET_PATHS := [
	"res://assets/epic/animations/dwarf_defender_sheet.png",
	"res://assets/epic/animations/dwarf_carrier_sheet.png",
	"res://assets/epic/animations/elf_ranger_sheet.png",
	"res://assets/epic/animations/arcane_mage_sheet.png",
	"res://assets/epic/animations/goblin_raider_sheet.png",
	"res://assets/epic/animations/goblin_saboteur_sheet.png",
	"res://assets/epic/animations/shadow_wolf_sheet.png"
]
const ACTION_NAMES := ["IDLE", "WALK", "ATTACK", "HIT", "DEATH", "DEPOSIT", "CARRY"]
const ACTION_ROWS := [0, 1, 2, 3, 4, 5, 1]
const ACTION_FPS := [5.0, 10.0, 11.0, 10.0, 11.0, 10.0, 10.0]
const GOBLIN_FRAMES := [8, 12, 12, 8, 16, 12, 12]

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

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	for path in SHEET_PATHS:
		atlases.append(load(path) as Texture2D)
	for i in ACTION_NAMES.size():
		var path: String = "res://assets/epic/animations/goblin_raider_%s.png" % ACTION_NAMES[i].to_lower()
		if ResourceLoader.exists(path):
			var strip := load(path) as Texture2D
			if strip != null and strip.get_height() == 192 and strip.get_width() == GOBLIN_FRAMES[i] * 192:
				goblin_strips[i] = strip
	var backdrop := ColorRect.new()
	backdrop.color = Color("0b1426")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
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
	title.text = "ANIMATION STUDIO"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_decorate(title, 32, Color("f6d18b"))
	layout.add_child(title)
	var sub := Label.new()
	sub.text = "LIVE ART • SAME ATLAS AS BATTLE"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_decorate(sub, 15, Color("b4cadf"))
	layout.add_child(sub)
	var unit_controls := HBoxContainer.new()
	layout.add_child(unit_controls)
	_add_button(unit_controls, "◀ HERO", _change_unit.bind(-1))
	unit_label = Label.new()
	unit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	unit_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_decorate(unit_label, 19, Color("f5e3bd"))
	unit_controls.add_child(unit_label)
	_add_button(unit_controls, "HERO ▶", _change_unit.bind(1))
	preview = Control.new()
	preview.custom_minimum_size = Vector2(0, 320)
	preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview.draw.connect(_draw_preview)
	layout.add_child(preview)
	frame_label = Label.new()
	frame_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_decorate(frame_label, 16, Color("9ad6cb"))
	layout.add_child(frame_label)
	var action_controls := HBoxContainer.new()
	layout.add_child(action_controls)
	_add_button(action_controls, "◀ ACTION", _change_action.bind(-1))
	action_label = Label.new()
	action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_decorate(action_label, 21, Color("f5e3bd"))
	action_controls.add_child(action_label)
	_add_button(action_controls, "ACTION ▶", _change_action.bind(1))
	var direction_controls := HBoxContainer.new()
	layout.add_child(direction_controls)
	_add_button(direction_controls, "FLIP DIRECTION", _flip)
	_add_button(direction_controls, "CLOSE", _close)
	var footnote := Label.new()
	footnote.text = "Compare real frames. An unanimated source sheet needs new art, not fake movement."
	footnote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footnote.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_decorate(footnote, 13, Color("b4cadf"))
	layout.add_child(footnote)
	_refresh_labels()
	set_process(true)

func _decorate(label: Label, size: int, color: Color) -> void:
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)

func _add_button(parent: HBoxContainer, caption: String, handler: Callable) -> void:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(120, 50)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 15)
	parent.add_child(button)
	button.pressed.connect(handler)

func _change_unit(direction: int) -> void:
	selected_unit = posmod(selected_unit + direction, UNIT_NAMES.size())
	elapsed = 0.0
	_refresh_labels()

func _change_action(direction: int) -> void:
	selected_action = posmod(selected_action + direction, ACTION_NAMES.size())
	elapsed = 0.0
	_refresh_labels()

func _flip() -> void:
	facing_right = not facing_right
	_refresh_labels()

func _close() -> void:
	queue_free()

func _refresh_labels() -> void:
	unit_label.text = UNIT_NAMES[selected_unit]
	action_label.text = ACTION_NAMES[selected_action]
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
	var strip: Texture2D = goblin_strips.get(selected_action) if selected_unit == 4 else null
	var source: Texture2D = strip if strip != null else atlases[selected_unit]
	if source == null:
		frame_label.text = "MISSING SOURCE TEXTURE"
		return
	var cell: int = 192 if strip != null else 128
	var frame_count: int = int(source.get_width() / cell) if strip != null else 8
	var frame: int = int(floor(elapsed * ACTION_FPS[selected_action])) % frame_count
	var row: int = 0 if strip != null else ACTION_ROWS[selected_action]
	var hero_height: float = minf(preview.size.y * 0.64, 245.0)
	var hero_width: float = hero_height
	var flip: float = 1.0 if facing_right else -1.0
	preview.draw_set_transform(center, 0.0, Vector2(flip, 1.0))
	preview.draw_texture_rect_region(source,
		Rect2(Vector2(-hero_width * 0.5, -hero_height), Vector2(hero_width, hero_height)),
		Rect2(Vector2(float(frame * cell), float(row * cell)), Vector2(cell, cell)))
	preview.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	frame_label.text = "FRAME %d/%d • %s • %s" % [
		frame + 1, frame_count, "EXTRA STRIP" if strip != null else "6-ROW ATLAS",
		"RIGHT" if facing_right else "LEFT"
	]
