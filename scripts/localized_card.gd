extends Control
## Large, uncropped battle illustrations with separate native labels and prices.
const Epic = preload("res://scripts/epic_theme.gd")
const CARD_HEIGHT := 182.0
const BANNER_HEIGHT := 104.0
var illustration: TextureRect
var caption: Label
var cost: Label
var base_size := 19
var banner := false
var frame: StyleBoxTexture
var art_tint := Color.WHITE

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
	# Godot resolves wrapped minimum height after its width has settled. On a
	# cold OpenGL start it may initially clamp to a one-pixel-wide paragraph.
	caption.minimum_size_changed.connect(_layout)
	cost = Label.new()
	cost.name = "LocalizedCost"
	cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cost.add_theme_color_override("font_color", Color("ffe59d"))
	cost.add_theme_font_size_override("font_size", 18)
	add_child(cost)
	resized.connect(_layout)

func configure(source: Texture2D, title: String, price: String, is_banner: bool = false, full_art: bool = false, skin_tint: Color = Color.WHITE) -> void:
	art_tint = skin_tint
	banner = is_banner
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if banner else TextServer.AUTOWRAP_OFF
	if full_art:
		# Ready-to-use battlefield AtlasTexture, no nested atlas or label crop.
		illustration.texture = source
	else:
		var crop := illustration.texture as AtlasTexture
		if crop == null or bool(get_meta("full_art", false)):
			crop = AtlasTexture.new()
		crop.atlas = source
		if source != null:
			var dimensions: Vector2 = source.get_size()
			if banner and dimensions.x > dimensions.y * 2.0:
				crop.region = Rect2(dimensions * Vector2(0.03, 0.16), dimensions * Vector2(0.29, 0.70))
			else:
				var wide: bool = dimensions.x > dimensions.y * 1.5
				crop.region = Rect2(dimensions * Vector2(0.04, 0.06 if wide else 0.05), dimensions * Vector2(0.92, 0.66 if wide else 0.73))
		illustration.texture = crop
	set_meta("full_art", full_art)
	caption.text = title
	cost.text = price
	var button := get_parent() as Button
	button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, BANNER_HEIGHT if banner else CARD_HEIGHT)
	sync_availability(button.disabled)
	_layout()
	queue_redraw()

func sync_availability(disabled: bool) -> void:
	# Disabled purchases remain identifiable; native labels keep full contrast.
	modulate = Color.WHITE
	var tint: Color = art_tint * (Color(0.72, 0.75, 0.82) if disabled else Color.WHITE)
	if illustration.modulate != tint:
		illustration.modulate = tint

func _layout() -> void:
	if illustration == null or caption == null or cost == null or size.x < 96:
		return
	var slot: float = minf(124, size.x * 0.38)
	var text_x: float = slot + 16 if banner else 12
	var text_width: float = maxf(20, size.x - text_x - 14)
	var font_size: int = 18 if banner else 17
	if banner:
		if Epic.DISPLAY_FONT.get_string_size(caption.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > text_width:
			slot = minf(104, size.x * 0.36)
			text_x = slot + 16
			text_width = maxf(20, size.x - text_x - 14)
			font_size = 16 # Long ability names wrap in full instead of shrinking away.
	else:
		while font_size > 13 and Epic.DISPLAY_FONT.get_string_size(caption.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > text_width:
			font_size -= 1
	if caption.get_theme_font_size("font_size") != font_size:
		caption.add_theme_font_size_override("font_size", font_size)
	var price_height: float = maxf(23.0, cost.get_combined_minimum_size().y)
	var caption_height := 26.0
	if banner:
		caption_height = maxf(caption_height, Epic.DISPLAY_FONT.get_multiline_string_size(caption.text, HORIZONTAL_ALIGNMENT_LEFT, text_width, font_size, -1, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND | TextServer.BREAK_ADAPTIVE).y)
		var button := get_parent() as Button
		var required_height: float = maxf(BANNER_HEIGHT, ceilf(caption_height + price_height + 28.0))
		if button.custom_minimum_size.y != required_height:
			button.custom_minimum_size.y = required_height
	var price_y: float = size.y - 14.0 - price_height
	var caption_y: float = price_y - caption_height - 2.0
	if banner:
		illustration.size = Vector2(maxf(20, slot - 4), maxf(20, size.y - 24))
		illustration.position = Vector2(12, (size.y - illustration.size.y) * 0.5)
		caption_y = (size.y - caption_height - price_height - 4) * 0.5
		price_y = caption_y + caption_height + 4
	else:
		var available_height: float = maxf(20, caption_y - 14.0)
		illustration.size = Vector2(maxf(20, size.x - 24), minf(160, available_height))
		illustration.position = Vector2(12, 10 + (available_height - illustration.size.y) * 0.5)
	caption.position = Vector2(text_x, caption_y)
	caption.size = Vector2(text_width, caption_height)
	cost.position = Vector2(text_x, price_y)
	cost.size = Vector2(text_width, price_height)

func _draw() -> void:
	if frame != null:
		draw_style_box(frame, Rect2(Vector2.ZERO, size))

static func apply(button: Button, source: Texture2D, title: String, price: String, banner_mode: bool = false, full_art: bool = false, skin_tint: Color = Color.WHITE) -> void:
	for name in ["IllustratedSurface", "DynamicPriceMask", "OriginalDynamicText"]:
		var baked := button.get_node_or_null(name) as CanvasItem
		if baked != null:
			baked.hide()
	var surface := button.get_node_or_null("LocalizedSurface")
	if surface == null:
		surface = load("res://scripts/localized_card.gd").new()
		surface.name = "LocalizedSurface"
		button.add_child(surface)
	surface.configure(source, title, price, banner_mode, full_art, skin_tint)
