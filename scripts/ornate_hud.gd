extends RefCounted
## Real nine-patch artwork for every battle control. Only art lives here:
## game rules, gold, prices, and signals remain in scripts/game.gd.
const UI_DIR := "res://assets/ui/ornate/"
var texture_cache: Dictionary = {}
var style_cache: Dictionary = {}

func image(name: String) -> Texture2D:
	if not texture_cache.has(name):
		texture_cache[name] = load(UI_DIR + name + ".svg") as Texture2D
	return texture_cache[name]

func style(name: String, variant: String = "normal") -> StyleBoxTexture:
	var key: String = name + ":" + variant
	if style_cache.has(key):
		return style_cache[key]
	var skin := StyleBoxTexture.new()
	skin.texture = image(name)
	var side: float = 21.0 if name.begins_with("card") else 34.0 if name.begins_with("lane") else 47.0
	skin.texture_margin_left = side
	skin.texture_margin_right = side
	skin.texture_margin_top = 19.0
	skin.texture_margin_bottom = 19.0
	# Explicit content margins avoid the automatic oversized nine-patch padding.
	skin.content_margin_left = 5.0
	skin.content_margin_right = 5.0
	skin.content_margin_top = 2.0
	skin.content_margin_bottom = 2.0
	if variant == "hover":
		skin.modulate_color = Color(1.14, 1.08, 1.13)
	elif variant == "pressed":
		skin.modulate_color = Color(1.21, 1.10, 1.20)
	elif variant == "disabled":
		skin.modulate_color = Color(0.86, 0.88, 0.95)
	style_cache[key] = skin
	return skin

func panel(panel_node: PanelContainer, name: String, horizontal_border: int = 40, vertical_border: int = 16) -> void:
	var skin := style(name).duplicate() as StyleBoxTexture
	skin.texture_margin_left = float(horizontal_border)
	skin.texture_margin_right = float(horizontal_border)
	skin.texture_margin_top = float(vertical_border)
	skin.texture_margin_bottom = float(vertical_border)
	skin.content_margin_left = 6
	skin.content_margin_right = 6
	skin.content_margin_top = 3
	skin.content_margin_bottom = 3
	panel_node.add_theme_stylebox_override("panel", skin)

func button(button_node: Button, normal: String, pushed: String = "", lane: bool = false) -> void:
	var chosen: String = normal if pushed.is_empty() else pushed
	button_node.add_theme_stylebox_override("normal", style(normal))
	button_node.add_theme_stylebox_override("hover", style(normal, "hover"))
	button_node.add_theme_stylebox_override("pressed", style(chosen, "pressed"))
	button_node.add_theme_stylebox_override("disabled", style(normal, "disabled"))
	button_node.add_theme_stylebox_override("focus", style(chosen))
	button_node.add_theme_color_override("font_color", Color("fff3ca"))
	button_node.add_theme_color_override("font_hover_color", Color("ffffff"))
	button_node.add_theme_color_override("font_pressed_color", Color("ffffff"))
	button_node.add_theme_color_override("font_disabled_color", Color("d9cbb9"))
	button_node.add_theme_color_override("font_shadow_color", Color("15091c"))
	button_node.add_theme_constant_override("shadow_offset_x", 2)
	button_node.add_theme_constant_override("shadow_offset_y", 2)
	button_node.add_theme_font_size_override("font_size", 18 if lane else 20)

# Real cropped PNGs from the original ImageGen artwork, not redrawn SVG lookalikes.
# These are optional until their checked ZIP is imported by GitHub Actions.
const DIRECT_DIR := "res://assets/ui/direct/"
var direct_styles: Dictionary = {}

func has_original_art() -> bool:
	return ResourceLoader.exists(DIRECT_DIR + "title.png") and ResourceLoader.exists(DIRECT_DIR + "runner.png")

func original_texture(name: String) -> Texture2D:
	var path: String = DIRECT_DIR + name + ".png"
	return load(path) as Texture2D if ResourceLoader.exists(path) else null

func original_style(name: String, variant: String = "normal") -> StyleBoxTexture:
	var key: String = name + ":" + variant
	if direct_styles.has(key):
		return direct_styles[key]
	var frame := StyleBoxTexture.new()
	frame.texture = original_texture(name)
	# The source graphic already has illustrated borders and inset faces.
	# Stretch the complete card, never repeat a corner nine times.
	frame.texture_margin_left = 0
	frame.texture_margin_right = 0
	frame.texture_margin_top = 0
	frame.texture_margin_bottom = 0
	frame.content_margin_left = 0
	frame.content_margin_right = 0
	frame.content_margin_top = 0
	frame.content_margin_bottom = 0
	if variant == "hover":
		frame.modulate_color = Color(1.13, 1.11, 1.15)
	elif variant == "pressed":
		frame.modulate_color = Color(1.2, 1.12, 1.22)
	elif variant == "disabled":
		frame.modulate_color = Color(0.88, 0.88, 0.95)
	direct_styles[key] = frame
	return frame

func original_panel(panel_node: PanelContainer, name: String) -> void:
	var background := original_style(name)
	panel_node.add_theme_stylebox_override("panel", background)

func original_button(button_node: Button, name: String) -> void:
	# Stretching a whole 310×168 PNG into a 250×140 card deforms the artwork.
	# Retain StyleBoxTexture metadata for compatibility tests but paint an actual
	# aspect-locked TextureRect beneath the caption and above the invisible skin.
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var variant: String = state if state != "focus" else "normal"
		var skin := original_style(name, variant).duplicate() as StyleBoxTexture
		skin.modulate_color = Color(1, 1, 1, 0)
		button_node.add_theme_stylebox_override(state, skin)
	var art := button_node.get_node_or_null("IllustratedSurface") as TextureRect
	if art == null:
		art = TextureRect.new()
		art.name = "IllustratedSurface"
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		button_node.add_child(art)
		button_node.move_child(art, 0)
		art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.texture = original_texture(name)
	button_node.add_theme_font_size_override("font_size", 19)
	button_node.add_theme_color_override("font_color", Color("fff0cd"))
	button_node.add_theme_color_override("font_disabled_color", Color("ded8cf"))
