extends ProgressBar
## Native range semantics with a carved gold vessel, runes and a brief level flare.
var energized := false
var flare := 0.0
var phase := 0.0

func _ready() -> void:
	custom_minimum_size.y = 24
	show_percentage = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for key in ["background", "fill"]:
		var skin := StyleBoxTexture.new()
		skin.texture = load("res://assets/ui/lobby/xp_%s.svg" % ("trough" if key == "background" else "fill")) as Texture2D
		skin.texture_margin_left = 16
		skin.texture_margin_right = 16
		skin.texture_margin_top = 6
		skin.texture_margin_bottom = 6
		add_theme_stylebox_override(key, skin)
	set_process(false)

func set_energized(value: bool) -> void:
	energized = value
	set_process(energized or flare > 0)
	queue_redraw()

func level_flash() -> void:
	flare = 1.0
	set_process(true)

func _process(delta: float) -> void:
	phase += delta
	flare = maxf(0, flare - delta * 1.8)
	queue_redraw()
	if not energized and flare <= 0:
		set_process(false)

func _draw() -> void:
	var ratio: float = clampf((value - min_value) / maxf(1, max_value - min_value), 0, 1)
	var end_x: float = 12 + maxf(0, size.x - 24) * ratio
	for index in 7:
		var x: float = 24 + (size.x - 48) * float(index) / 6.0
		var tint := Color("fff3bd", 0.52 if x <= end_x else 0.13)
		draw_polyline(PackedVector2Array([Vector2(x, 8), Vector2(x + 3, 12), Vector2(x, 16), Vector2(x - 3, 12), Vector2(x, 8)]), tint, 1.0, true)
	if energized and ratio > 0:
		var x: float = lerpf(14, maxf(14, end_x - 2), fmod(phase * 0.9, 1.0))
		draw_line(Vector2(x - 3, 8), Vector2(x + 3, size.y - 8), Color("fffbe0", 0.72), 2, true)
	if flare > 0:
		draw_rect(Rect2(Vector2(8, 4), size - Vector2(16, 8)), Color(1, 0.87, 0.43, flare * 0.45))
