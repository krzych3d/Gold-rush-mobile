extends RefCounted
## Shared readable fantasy surfaces. Decoration never paints over native labels.
const Surface = preload("res://scripts/epic_button_surface.gd")
const DISPLAY_FONT = preload("res://assets/fonts/Cinzel.ttf")
const GOLD := Color("edce8f")
const COPY := Color("edf2f7")
const SCENERY := "res://assets/ui/lobby/epic_vault_menu.png"
const WORDMARK := "res://assets/ui/lobby/vault_wars_wordmark.png"

static func button(node: Button, primary: bool = false, font_size: int = 21) -> void:
	var baked_surface := node.get_node_or_null("IllustratedSurface") as CanvasItem
	if baked_surface != null:
		baked_surface.hide()
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		var skin := StyleBoxTexture.new()
		skin.texture = Surface.ART
		skin.modulate_color = Color(1, 1, 1, 0)
		skin.set_content_margin_all(22)
		skin.content_margin_top = 14
		skin.content_margin_bottom = 2
		node.add_theme_stylebox_override(state, skin)
	node.add_theme_stylebox_override("focus", focus())
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		node.add_theme_color_override(state, Color("fff2ce") if primary else COPY)
	node.add_theme_color_override("font_disabled_color", Color("acacc3"))
	node.add_theme_color_override("font_shadow_color", Color("02040e"))
	node.add_theme_constant_override("shadow_offset_y", 2)
	node.add_theme_font_size_override("font_size", font_size)
	node.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	var surface := node.get_node_or_null("EpicButtonSurface")
	if surface == null:
		surface = Surface.new()
		surface.name = "EpicButtonSurface"
		surface.primary = primary
		node.add_child(surface)
	node.add_theme_font_override("font", DISPLAY_FONT)
	node.add_theme_color_override("font_color", Color("ffe9b0"))
	node.add_theme_color_override("font_outline_color", Color("180c08"))
	node.add_theme_constant_override("outline_size", 3)
	node.set_meta("epic_font_size", font_size)
	if not node.resized.is_connected(_fit_button.bind(node)):
		node.resized.connect(_fit_button.bind(node))
	_fit_button(node)

static func _fit_button(node: Button) -> void:
	if node.size.x < 1 or node is OptionButton:
		return
	var font_size: int = int(node.get_meta("epic_font_size", 21))
	var skin := node.get_theme_stylebox("normal")
	var available: float = maxf(10, node.size.x - skin.content_margin_left - skin.content_margin_right - 12)
	while font_size > 13 and DISPLAY_FONT.get_string_size(node.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > available:
		font_size -= 1
	node.add_theme_font_size_override("font_size", font_size)

static func heading(node: Label, font_size: int = 26) -> void:
	node.add_theme_font_override("font", DISPLAY_FONT)
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", GOLD)
	node.add_theme_color_override("font_outline_color", Color("1c100b"))
	node.add_theme_constant_override("outline_size", 3)
	node.add_theme_color_override("font_shadow_color", Color("000009"))
	node.add_theme_constant_override("shadow_offset_y", 2)

static func focus() -> StyleBoxFlat:
	var skin := StyleBoxFlat.new()
	skin.bg_color = Color.TRANSPARENT
	skin.border_color = Color("fff1a3", 0.72)
	skin.set_border_width_all(2)
	skin.set_corner_radius_all(8)
	return skin

static func panel(margin: int = 22) -> StyleBoxTexture:
	var skin := StyleBoxTexture.new()
	skin.texture = load("res://assets/ui/lobby/panel.svg") as Texture2D
	skin.texture_margin_left = 30
	skin.texture_margin_right = 30
	skin.texture_margin_top = 30
	skin.texture_margin_bottom = 30
	skin.set_content_margin_all(margin)
	return skin

static func backdrop(parent: Control, dim: float = 0.55) -> TextureRect:
	var art := TextureRect.new()
	art.name = "EpicScenery"
	art.texture = load(SCENERY) as Texture2D
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(art)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.025, 0.065, dim)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(shade)
	return art
