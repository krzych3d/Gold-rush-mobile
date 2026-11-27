extends Control
## Two texture layers and a handful of motes, with no shaders or particle nodes.
var battlefield: Texture2D
var portrait_name := "thorgar"
var reduced_motion := false
var battery := false
var elapsed := 0.0
var portrait: TextureRect
var background: TextureRect
var portraits: Dictionary = {}

func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	background = _art(battlefield)
	background.modulate = Color(0.65, 0.72, 0.82)
	portrait = _art(load("res://assets/epic/story/%s.jpg" % portrait_name))
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	resized.connect(_layout)
	_layout()
	set_process(not reduced_motion and not battery)

func _art(texture: Texture2D) -> TextureRect:
	var node := TextureRect.new()
	node.texture = texture
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(node)
	return node

func _layout() -> void:
	background.position = Vector2(-8, -8)
	background.size = size + Vector2(16, 16)
	# Match the portrait's own 3:4 aspect so eyes and hair are never cropped.
	var width: float = minf(size.x * 0.60, size.y * 0.75)
	portrait.size = Vector2(width, size.y)
	portrait.position = Vector2(size.x - width, 0)
	queue_redraw()

func show_speaker(name: String) -> void:
	if not is_instance_valid(portrait):
		return
	if not portraits.has(name):
		portraits[name] = load("res://assets/epic/story/%s.jpg" % name)
	portrait.texture = portraits[name]
	portrait.modulate.a = 1.0
	if not reduced_motion and not battery:
		portrait.modulate.a = 0.65
		create_tween().tween_property(portrait, "modulate:a", 1.0, 0.35)

func _process(dt: float) -> void:
	elapsed += minf(dt, 0.1)
	background.position.x = -8.0 + sin(elapsed * 0.18) * 5.0
	portrait.position.y = sin(elapsed * 0.55) * 1.5
	queue_redraw()

func _draw() -> void:
	# The vignette leaves an unobscured portrait and a calm left text area.
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x * 0.22, size.y)), Color(0.025, 0.02, 0.04, 0.4))
	for i in (3 if battery else 8):
		var t: float = fmod(float(i) * 0.137 + elapsed * 0.015, 1.0)
		var p := Vector2(fmod(float(i) * 73.0, maxf(1, size.x)), size.y * (1.0 - t))
		draw_circle(p, 1.2 + float(i % 2), Color(0.83, 0.76, 0.50, 0.22 + 0.22 * sin(t * PI)))
