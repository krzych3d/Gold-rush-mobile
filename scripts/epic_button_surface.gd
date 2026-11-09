extends Control
## Keep the painted ends and crystal proportional; stretch only the blank face.
const ART = preload("res://assets/ui/lobby/epic_button.png")
var primary := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	show_behind_parent = true
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var button := get_parent() as BaseButton
	for event in [button.mouse_entered, button.mouse_exited, button.button_down, button.button_up, button.focus_entered, button.focus_exited, button.toggled]:
		event.connect(func(_value = null) -> void: queue_redraw())

func _draw() -> void:
	var button := get_parent() as BaseButton
	var source: Vector2 = ART.get_size()
	var scale_factor: float = size.y / source.y
	var edge: float = minf(source.x * 0.16 * scale_factor, size.x * 0.26)
	var tint := Color(1.10, 1.03, 0.92) if primary else Color.WHITE
	if button.disabled:
		tint = Color(0.60, 0.62, 0.72)
	elif button.is_pressed():
		tint = Color(0.78, 0.77, 0.91)
	elif button.is_hovered() or button.has_focus():
		tint = Color(1.18, 1.12, 1.22)
	draw_texture_rect_region(ART, Rect2(edge, 0, maxf(0, size.x - edge * 2), size.y), Rect2(source.x * 0.20, 0, source.x * 0.12, source.y), tint)
	draw_texture_rect_region(ART, Rect2(0, 0, edge, size.y), Rect2(0, 0, source.x * 0.16, source.y), tint)
	draw_texture_rect_region(ART, Rect2(size.x - edge, 0, edge, size.y), Rect2(source.x * 0.84, 0, source.x * 0.16, source.y), tint)
	var crystal := Vector2(source.x * 0.22, source.y * 0.40) * scale_factor
	draw_texture_rect_region(ART, Rect2((size.x - crystal.x) * 0.5, 0, crystal.x, crystal.y), Rect2(source.x * 0.39, 0, source.x * 0.22, source.y * 0.40), tint)
