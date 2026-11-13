extends Control
## Reuse the original faction illustration, excluding its baked English labels.
## A native engraved caption stays readable and switches languages instantly.
const Epic = preload("res://scripts/epic_theme.gd")
var illustration: TextureRect
var caption: Label
var cost: Label
var base_size := 19
var banner := false
var frame: StyleBoxTexture

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame = Epic.panel(0)
	illustration = TextureRect.new()
	illustration.name = "FactionIllustration"
	illustration.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	illustration.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	illustration.clip_contents = true
	illustration.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(illustration)
	caption = Label.new()
	caption.name = "LocalizedCaption"
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	Epic.heading(caption, base_size)
	add_child(caption)
	cost = Label.new()
	cost.name = "LocalizedCost"
	cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cost.add_theme_color_override("font_color", Color("ffe59d"))
	cost.add_theme_font_size_override("font_size", 18)
	add_child(cost)
	resized.connect(_layout)

func configure(source: Texture2D, title: String, price: String, is_banner: bool = false) -> void:
	banner = is_banner
	var crop := illustration.texture as AtlasTexture
	if crop == null:
		crop = AtlasTexture.new()
	crop.atlas = source
	if source != null:
		var dimensions: Vector2 = source.get_size()
		if banner and dimensions.x > dimensions.y * 2.0:
			crop.region = Rect2(dimensions * Vector2(0.03, 0.16), dimensions * Vector2(0.29, 0.70))
		else:
			# Portrait cards and wide trap cards have different label baselines.
			var wide: bool = dimensions.x > dimensions.y * 1.5
			crop.region = Rect2(dimensions * Vector2(0.04, 0.06 if wide else 0.05), dimensions * Vector2(0.92, 0.66 if wide else 0.73))
	illustration.texture = crop
	caption.text = title
	cost.text = price
	var button := get_parent() as Button
	modulate = Color(0.62, 0.64, 0.72) if button.disabled else Color.WHITE
	_layout()
	queue_redraw()

func _layout() -> void:
	if illustration == null:
		return
	var slot: float = minf(180, size.x * 0.28)
	if banner:
		illustration.size = Vector2(maxf(16, slot - 16), minf(62, maxf(20, size.y - 16)))
		illustration.position = Vector2(8, (size.y - illustration.size.y) * 0.5)
	else:
		var available_height: float = maxf(20, size.y - 62)
		illustration.size = Vector2(minf(190, maxf(20, size.x - 28)), minf(126, available_height))
		illustration.position = Vector2((size.x - illustration.size.x) * 0.5, 8 + (available_height - illustration.size.y) * 0.5)
	var text_x: float = slot + 4 if banner else 6
	var text_width: float = size.x - text_x - 8
	caption.position = Vector2(text_x, 8 if banner else maxf(20, size.y - 55))
	caption.size = Vector2(text_width, (size.y - 16) * 0.60 if banner else 28)
	cost.position = Vector2(text_x, size.y * 0.58 if banner else size.y - 29)
	cost.size = Vector2(text_width, 23)
	var font_size: int = 19 if banner else 17
	while font_size > 11 and Epic.DISPLAY_FONT.get_string_size(caption.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > text_width:
		font_size -= 1
	caption.add_theme_font_size_override("font_size", font_size)

func _draw() -> void:
	if frame != null:
		draw_style_box(frame, Rect2(Vector2.ZERO, size))

static func apply(button: Button, source: Texture2D, title: String, price: String, banner_mode: bool = false) -> void:
	for name in ["IllustratedSurface", "DynamicPriceMask", "OriginalDynamicText"]:
		var baked := button.get_node_or_null(name) as CanvasItem
		if baked != null:
			baked.hide()
	var surface := button.get_node_or_null("LocalizedSurface")
	if surface == null:
		surface = load("res://scripts/localized_card.gd").new()
		surface.name = "LocalizedSurface"
		button.add_child(surface)
	surface.configure(source, title, price, banner_mode)
