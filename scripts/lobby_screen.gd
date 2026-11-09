extends Control
const L10n = preload("res://scripts/localization.gd")
## Cinematic entry screen; detailed reference and animation live one level deeper.
const Catalog = preload("res://scripts/game_catalog.gd")
const Preview = preload("res://scripts/menu_preview.gd")
const Epic = preload("res://scripts/epic_theme.gd")
const MENU_ART := "res://assets/ui/lobby/epic_vault_menu.png"
const WORDMARK := "res://assets/ui/lobby/vault_wars_wordmark.png"
const GOLD := Color("edce8f")
const INK := Color("09121e")
const COPY := Color("d4dfdf")
var game
var mode := "home"
var focus_race := 0
var focus_entry := "runner"
var column: VBoxContainer
var content: VBoxContainer
var footer: VBoxContainer
var detail: VBoxContainer
var detail_scroll: ScrollContainer
var live_preview
var race_cards: Array[Button] = []
var race_detail: VBoxContainer
var hero_art: TextureRect
var hero_name: Label
var hero_copy: Label
var category_filter: OptionButton
var race_filter: OptionButton
var search: LineEdit
var entry_list: ItemList
var result_count: Label
var filtered_entries: Array[Dictionary] = []
var quality_caption: Label
var race_role := 0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_install_theme()
	focus_race = game.selected_race
	var background := TextureRect.new()
	background.name = "MainMenuScenery" if mode == "home" else "CinematicScenery"
	background.texture = load(MENU_ART) as Texture2D
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.modulate = Color.WHITE
	add_child(background)
	if mode in ["home", "race"]:
		_build_cinematic_shading()
		if mode == "home":
			_build_home()
		else:
			_build_races()
		return
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.025, 0.06, 0.55)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 22 if edge in ["left", "right"] else 16)
	add_child(margin)
	column = VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)
	var scroll := ScrollContainer.new()
	scroll.name = "ScreenScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	scroll.add_child(content)
	footer = VBoxContainer.new()
	footer.add_theme_constant_override("separation", 8)
	column.add_child(footer)
	match mode:
		"codex":
			# The index and description have independent scrolling; controls stay reachable.
			column.remove_child(scroll)
			scroll.queue_free()
			content = VBoxContainer.new()
			content.size_flags_vertical = Control.SIZE_EXPAND_FILL
			content.add_theme_constant_override("separation", 10)
			column.add_child(content)
			column.move_child(content, 0)
			_build_codex()
		"settings": _build_settings()
		"tutorial": _build_tutorial()

func _label(text: String, font_size: int = 20, color: Color = COPY) -> Label:
	var node := Label.new()
	node.text = L10n.t(text)
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if font_size >= 24:
		Epic.heading(node, font_size)
	return node

func _button(parent: Node, caption: String, id: String, handler: Callable, primary: bool = false) -> Button:
	var node := Button.new()
	node.name = id
	node.text = L10n.t(caption)
	node.custom_minimum_size.y = 76 if primary else 60
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	for variant in ["normal", "hover", "pressed", "focus", "disabled"]:
		node.add_theme_stylebox_override(variant, _button_skin(primary, variant))
	node.add_theme_color_override("font_color", Color("fff0ca") if primary else Color("e1e8e6"))
	node.add_theme_color_override("font_hover_color", Color.WHITE)
	node.add_theme_color_override("font_pressed_color", GOLD)
	node.add_theme_font_size_override("font_size", 25 if primary else 20)
	parent.add_child(node)
	Epic.button(node, primary, 25 if primary else 20)
	node.pressed.connect(handler)
	return node

func _button_skin(primary: bool = false, variant: String = "normal") -> StyleBoxFlat:
	var skin := StyleBoxFlat.new()
	skin.bg_color = Color("825225") if primary else Color("132a3a")
	if variant in ["hover", "focus"]:
		skin.bg_color = skin.bg_color.lightened(0.12)
	elif variant == "pressed":
		skin.bg_color = skin.bg_color.darkened(0.12)
	skin.border_color = GOLD if primary or variant == "focus" else Color("406078")
	skin.set_border_width_all(2 if primary or variant == "focus" else 1)
	skin.set_corner_radius_all(10)
	skin.content_margin_left = 12
	skin.content_margin_right = 12
	skin.content_margin_top = 8
	skin.content_margin_bottom = 8
	return skin

func _primary_style(button: Button) -> void:
	Epic.button(button, true, 26)
	button.custom_minimum_size.y = 90

func _quiet_style(button: Button, icon_name: String = "") -> void:
	Epic.button(button, false, 20)
	button.custom_minimum_size.y = 66
	if not icon_name.is_empty():
		button.tooltip_text = button.text

func _gradient_overlay(id: String, top: float, bottom: float, colors: PackedColorArray) -> void:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.7, 1.0]) if colors.size() == 3 else PackedFloat32Array([0.0, 1.0])
	gradient.colors = colors
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 8
	texture.height = 256
	texture.fill_from = Vector2(0.0, 0.0)
	texture.fill_to = Vector2(0.0, 1.0)
	var overlay := TextureRect.new()
	overlay.name = id
	overlay.texture = texture
	overlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.anchor_right = 1.0
	overlay.anchor_top = top
	overlay.anchor_bottom = bottom
	add_child(overlay)

func _build_cinematic_shading() -> void:
	_gradient_overlay("LogoShade", 0.0, 0.25, PackedColorArray([Color(0.01, 0.04, 0.055, 0.52), Color.TRANSPARENT]))
	_gradient_overlay("ControlShade", 0.64 if mode == "home" else 0.38, 1.0, PackedColorArray([Color.TRANSPARENT, Color(0.01, 0.035, 0.04, 0.55), Color(0.01, 0.035, 0.04, 0.96)]))

func _install_theme() -> void:
	theme = Theme.new()
	theme.default_font_size = 20
	for control_type in ["OptionButton", "LineEdit", "ItemList"]:
		theme.set_color("font_color", control_type, COPY)
		theme.set_color("font_selected_color", control_type, GOLD)
		for variant in ["normal", "hover", "pressed", "focus"]:
			theme.set_stylebox(variant, control_type, Epic.focus() if variant == "focus" else Epic.panel(14))
	theme.set_stylebox("panel", "ItemList", Epic.panel(14))
	theme.set_stylebox("selected", "ItemList", _button_skin(false, "focus"))
	theme.set_stylebox("selected_focus", "ItemList", _button_skin(false, "focus"))
	theme.set_color("font_placeholder_color", "LineEdit", Color("829baa"))

func _panel(parent: Node, tint: Color = GOLD) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", Epic.panel())
	parent.add_child(panel)
	var inside := VBoxContainer.new()
	inside.add_theme_constant_override("separation", 9)
	panel.add_child(inside)
	return inside

func _heading(title: String, subtitle: String) -> void:
	var heading := _label(title, 32, GOLD)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(heading)
	var copy := _label(subtitle, 18)
	copy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(copy)

func _image(path: String, height: float) -> TextureRect:
	var art := TextureRect.new()
	art.texture = _illustration_texture(path)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.custom_minimum_size.y = height
	art.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return art

func _illustration_texture(path: String) -> Texture2D:
	var source: Texture2D = load(path) as Texture2D if ResourceLoader.exists(path) else null
	if source == null or not path.contains("/ui/direct/") or path.ends_with("title.png"):
		return source
	# Labels are drawn by Godot in the selected language, never inside a PNG.
	var crop := AtlasTexture.new()
	crop.atlas = source
	var dimensions: Vector2 = source.get_size()
	var strip: bool = dimensions.x > dimensions.y * 2.0
	crop.region = Rect2(dimensions * Vector2(0.03, 0.16), dimensions * Vector2(0.29, 0.70)) if strip else Rect2(dimensions * Vector2(0.04, 0.15), dimensions * Vector2(0.92, 0.63))
	return crop

func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
	live_preview = null

func _build_home() -> void:
	# Exactly three actions. The artwork is the scene, not a card inside a panel.
	var logo := _image(WORDMARK, 0)
	logo.name = "MainMenuLogo"
	logo.anchor_left = 0.09
	logo.anchor_right = 0.91
	logo.anchor_top = 0.025
	logo.anchor_bottom = 0.185
	add_child(logo)
	_build_language_switch()
	footer = VBoxContainer.new()
	footer.name = "HomeActions"
	footer.anchor_left = 0.08
	footer.anchor_right = 0.92
	footer.anchor_top = 0.77
	footer.anchor_bottom = 0.965
	footer.alignment = BoxContainer.ALIGNMENT_END
	footer.add_theme_constant_override("separation", 12)
	add_child(footer)
	var start := _button(footer, L10n.t("ROZPOCZNIJ GRĘ"), "StartGame", game._open_race_selection, true)
	_primary_style(start)
	var navigation := HBoxContainer.new()
	navigation.add_theme_constant_override("separation", 10)
	footer.add_child(navigation)
	_quiet_style(_button(navigation, L10n.t("Księga gry"), "OpenCodex", game._show_codex.bind("runner")), "book")
	_quiet_style(_button(navigation, L10n.t("Ustawienia"), "OpenSettings", game._show_settings), "settings")
	var tagline := _label(L10n.t("TWÓJ SKARBIEC. TWOJA LEGENDA."), 18, GOLD)
	tagline.name = "HomeTagline"
	tagline.anchor_left = 0.08
	tagline.anchor_right = 0.92
	tagline.anchor_top = 0.71
	tagline.anchor_bottom = 0.76
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Epic.heading(tagline, 20)
	add_child(tagline)

func _build_language_switch() -> void:
	var row := HBoxContainer.new()
	row.name = "LanguageSwitch"
	row.anchor_left = 1.0
	row.anchor_right = 1.0
	row.offset_left = -182
	row.offset_right = -16
	row.offset_top = 12
	row.offset_bottom = 70
	row.add_theme_constant_override("separation", 6)
	add_child(row)
	for code in L10n.LANGUAGES:
		var choice := _button(row, code.to_upper(), "Language" + code.to_upper(), game._change_language.bind(code))
		choice.custom_minimum_size = Vector2(80, 58)
		choice.disabled = code == game.presentation.language
		Epic.button(choice, code == game.presentation.language, 18)
		choice.tooltip_text = "Polski" if code == "pl" else "English"

func rebuild_language() -> void:
	# Rebuild visible labels without replacing the game, purchases or preferences.
	var retained_race := focus_race
	var retained_entry := focus_entry
	var retained_category: int = category_filter.selected if is_instance_valid(category_filter) else 0
	var retained_query: String = search.text if is_instance_valid(search) else ""
	for child in get_children():
		remove_child(child)
		child.queue_free()
	race_cards.clear()
	live_preview = null
	_ready()
	if mode == "codex":
		focus_race = retained_race
		focus_entry = retained_entry
		race_filter.selected = retained_race
		category_filter.selected = retained_category
		search.text = retained_query
		_filter_entries()

func _build_races() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 30)
	add_child(margin)
	column = VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	margin.add_child(column)
	var title := _label(L10n.t("WYBIERZ RASĘ"), 34, GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var hint := _label(L10n.t("Cztery style walki. Który jest twój?"), 18)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(hint)
	var nameplate := PanelContainer.new()
	nameplate.name = "FactionNameplate"
	nameplate.add_theme_stylebox_override("panel", Epic.panel(10))
	column.add_child(nameplate)
	hero_name = _label("", 30, GOLD)
	hero_name.name = "SelectedFactionName"
	hero_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nameplate.add_child(hero_name)
	var artwork_frame := PanelContainer.new()
	artwork_frame.name = "RaceArtworkFrame"
	artwork_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	artwork_frame.add_theme_stylebox_override("panel", Epic.panel(8))
	column.add_child(artwork_frame)
	hero_art = _image(Catalog.portrait(focus_race), 160)
	hero_art.name = "SelectedRaceIllustration"
	hero_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	hero_art.clip_contents = true
	artwork_frame.add_child(hero_art)
	hero_art.resized.connect(_fit_race_portrait)
	var choices := HBoxContainer.new()
	choices.name = "RacePortraitGrid"
	choices.add_theme_constant_override("separation", 8)
	column.add_child(choices)
	for index in 4:
		var card := Button.new()
		card.name = "ChooseRace%d" % index
		card.custom_minimum_size.y = 142
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		choices.add_child(card)
		var stack := VBoxContainer.new()
		stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stack.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		stack.offset_left = 7
		stack.offset_right = -7
		stack.offset_top = 7
		stack.offset_bottom = -7
		stack.add_theme_constant_override("separation", 7)
		card.add_child(stack)
		var art := _image(Catalog.portrait(index), 89)
		# A display region removes the old baked English nameplate, without
		# modifying or duplicating any original faction artwork.
		var source := art.texture
		var portrait := AtlasTexture.new()
		portrait.atlas = source
		portrait.region = Rect2(0, source.get_height() * 0.03, source.get_width(), floorf(source.get_height() * 0.40))
		art.texture = portrait
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		stack.add_child(art)
		var name_label := _label(Catalog.RACE_TITLES[index], 16, game.RACE_COLORS[index])
		Epic.heading(name_label, 16)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stack.add_child(name_label)
		card.pressed.connect(select_race.bind(index))
		race_cards.append(card)
	race_detail = VBoxContainer.new()
	race_detail.name = "SelectedRaceSummary"
	race_detail.custom_minimum_size.y = 92
	race_detail.add_theme_constant_override("separation", 6)
	column.add_child(race_detail)
	footer = VBoxContainer.new()
	footer.name = "RaceActions"
	footer.add_theme_constant_override("separation", 6)
	column.add_child(footer)
	_primary_style(_button(footer, "", "ConfirmFaction", game._confirm_faction, true))
	var navigation := HBoxContainer.new()
	navigation.add_theme_constant_override("separation", 16)
	footer.add_child(navigation)
	_quiet_style(_button(navigation, L10n.t("Poznaj tę rasę"), "InspectRace", _inspect_race), "book")
	_quiet_style(_button(navigation, L10n.t("Wróć"), "BackFromRace", game._back_from_race_selection))
	select_race(game.selected_race)

func select_race(index: int) -> void:
	focus_race = index
	game.selected_race = index
	hero_name.text = L10n.t(Catalog.RACE_TITLES[index]).to_upper()
	var source := load(Catalog.portrait(index)) as Texture2D
	var portrait := AtlasTexture.new()
	portrait.atlas = source
	portrait.region = Rect2(0, 0, source.get_width(), source.get_height())
	hero_art.texture = portrait
	_fit_race_portrait()
	for race_index in race_cards.size():
		var skin := Epic.panel(7)
		skin.modulate_color = Color(1.20, 1.13, 0.88) if index == race_index else Color(0.55, 0.62, 0.73)
		for variant in ["normal", "hover", "focus", "pressed"]:
			race_cards[race_index].add_theme_stylebox_override(variant, skin)
		race_cards[race_index].add_theme_stylebox_override("focus", Epic.focus())
	_clear(race_detail)
	var summary := _label(Catalog.RACE_STYLES[index], 24, game.RACE_COLORS[index])
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	race_detail.add_child(summary)
	var bonus := _label([L10n.t("28% odsetek  •  +25% PŻ najeźdźców"), L10n.t("18% odsetek  •  +20% tempa najeźdźców"), L10n.t("18% odsetek  •  +10% PŻ  •  +10 łupu"), L10n.t("18% odsetek  •  +10% tempa  •  +15 łupu")][index], 18)
	bonus.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	race_detail.add_child(bonus)
	var confirm := find_child("ConfirmFaction", true, false) as Button
	confirm.text = L10n.t("GRAJ: %s") % L10n.t(Catalog.RACE_TITLES[index]).to_upper()
	Epic._fit_button(confirm)

func _fit_race_portrait() -> void:
	if hero_art == null or hero_art.texture == null or hero_art.size.x <= 0:
		return
	var crop := hero_art.texture as AtlasTexture
	if crop == null:
		return
	var source: Vector2 = crop.atlas.get_size()
	# Keep faces in view when the phone's aspect ratio crops the tall painting.
	var crop_height: float = minf(source.y, source.x * hero_art.size.y / hero_art.size.x)
	crop.region = Rect2(0, 0, source.x, crop_height)

func _pick_role(index: int) -> void:
	race_role = index
	if live_preview != null:
		var data: Dictionary = Catalog.find(game, focus_race, "defender" if index == 3 else ["runner", "carrier", "saboteur"][index])
		live_preview.configure(game, data)

func _inspect_race() -> void:
	game._show_codex("race_%d" % focus_race)

func _build_codex() -> void:
	var header := HBoxContainer.new()
	content.add_child(header)
	var heading := _label(L10n.t("KSIĘGA GRY"), 30, GOLD)
	header.add_child(heading)
	var tutorial := _button(header, L10n.t("Jak grać"), "HowToPlay", _open_tutorial)
	tutorial.size_flags_horizontal = Control.SIZE_FILL
	tutorial.custom_minimum_size.x = 190
	_quiet_style(tutorial)
	var filters := HBoxContainer.new()
	filters.add_theme_constant_override("separation", 8)
	content.add_child(filters)
	category_filter = OptionButton.new()
	category_filter.name = "CatalogCategory"
	category_filter.custom_minimum_size.y = 58
	category_filter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for title in Catalog.CATEGORIES:
		category_filter.add_item(L10n.t(title))
	filters.add_child(category_filter)
	race_filter = OptionButton.new()
	race_filter.name = "CatalogRace"
	race_filter.custom_minimum_size.y = 58
	race_filter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for title in Catalog.RACE_TITLES:
		race_filter.add_item(L10n.t(title))
	race_filter.selected = focus_race
	filters.add_child(race_filter)
	search = LineEdit.new()
	search.name = "CatalogSearch"
	search.placeholder_text = L10n.t("Szukaj jednostki, pułapki, zdolności…")
	search.custom_minimum_size.y = 54
	search.add_theme_font_size_override("font_size", 20)
	content.add_child(search)
	result_count = _label("", 16, GOLD)
	content.add_child(result_count)
	entry_list = ItemList.new()
	entry_list.name = "CatalogEntries"
	entry_list.custom_minimum_size.y = 154
	entry_list.max_columns = 2
	entry_list.same_column_width = true
	entry_list.fixed_icon_size = Vector2i(54, 50)
	entry_list.fixed_column_width = 260
	entry_list.allow_reselect = true
	entry_list.add_theme_constant_override("v_separation", 12)
	entry_list.add_theme_constant_override("h_separation", 8)
	entry_list.add_theme_font_size_override("font_size", 18)
	content.add_child(entry_list)
	detail_scroll = ScrollContainer.new()
	detail_scroll.name = "CatalogDetailScroll"
	detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(detail_scroll)
	detail = VBoxContainer.new()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.add_theme_constant_override("separation", 12)
	detail_scroll.add_child(detail)
	category_filter.item_selected.connect(func(_index: int) -> void: _filter_entries())
	race_filter.item_selected.connect(func(index: int) -> void:
		focus_race = index
		_filter_entries())
	search.text_changed.connect(func(_value: String) -> void: _filter_entries())
	entry_list.item_selected.connect(_select_entry)
	var navigation := HBoxContainer.new()
	footer.add_child(navigation)
	_button(navigation, L10n.t("Wróć"), "CloseCodex", game._close_codex)
	var studio := _button(navigation, L10n.t("Animacje"), "OpenAnimationStudio", _open_studio)
	_quiet_style(studio)
	_filter_entries()

func _filter_entries() -> void:
	entry_list.clear()
	filtered_entries.clear()
	var query: String = search.text.strip_edges().to_lower()
	var category: String = L10n.t(Catalog.CATEGORIES[category_filter.selected])
	var selected := -1
	for entry in Catalog.entries(game, focus_race):
		if category_filter.selected != 0 and entry["category"] != category:
			continue
		var haystack: String = (str(entry["title"]) + " " + str(entry["body"]) + " " + str(entry["tip"]) + " " + str(entry["stats"])).to_lower()
		if not query.is_empty() and not haystack.contains(query):
			continue
		if entry["id"] == focus_entry:
			selected = filtered_entries.size()
		filtered_entries.append(entry)
		var icon: Texture2D = _illustration_texture(entry["art"])
		entry_list.add_item(entry["title"], icon)
	result_count.text = L10n.t("%d wpisów • statystyki: %s") % [filtered_entries.size(), L10n.t(Catalog.RACE_TITLES[focus_race])]
	if filtered_entries.is_empty():
		_clear(detail)
		detail.add_child(_label(L10n.t("Brak wyników. Zmień kategorię lub skróć wyszukiwanie."), 22, GOLD))
		return
	selected = maxi(0, selected)
	entry_list.select(selected)
	entry_list.ensure_current_is_visible()
	_select_entry(selected)

func _select_entry(index: int) -> void:
	var data: Dictionary = filtered_entries[index]
	focus_entry = str(data["id"])
	_clear(detail)
	detail_scroll.scroll_vertical = 0
	var pane := _panel(detail, game.RACE_COLORS[int(data["race"])])
	var title := _label(data["title"], 28, GOLD)
	title.name = "EntryTitle"
	pane.add_child(title)
	var media := HBoxContainer.new()
	media.add_theme_constant_override("separation", 8)
	pane.add_child(media)
	var art := _image(data["art"], 205)
	art.name = "EntryIllustration"
	media.add_child(art)
	live_preview = Preview.new()
	live_preview.name = "EntryLivePreview"
	live_preview.custom_minimum_size.y = 205
	live_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	media.add_child(live_preview)
	live_preview.configure(game, data)
	var playback := HBoxContainer.new()
	playback.add_theme_constant_override("separation", 8)
	pane.add_child(playback)
	var actions := OptionButton.new()
	actions.name = "PreviewAction"
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.custom_minimum_size.y = 56
	for label in [L10n.t("Pokaz działania"), L10n.t("Spoczynek"), L10n.t("Ruch"), L10n.t("Atak"), L10n.t("Trafienie"), L10n.t("Upadek"), L10n.t("Oddanie złota")]:
		actions.add_item(label)
	actions.disabled = data["demo"] in ["bank", "spikes", "snare", "turret"]
	playback.add_child(actions)
	actions.item_selected.connect(func(action_index: int) -> void: live_preview.set_action(action_index - 1))
	var pause := _button(playback, L10n.t("Pauza") if live_preview.playing else L10n.t("Odtwórz"), "TogglePreview", _toggle_preview)
	pause.size_flags_horizontal = Control.SIZE_FILL
	pause.custom_minimum_size.x = 130
	var stats := GridContainer.new()
	stats.name = "EntryStats"
	stats.columns = 2
	stats.add_theme_constant_override("h_separation", 14)
	stats.add_theme_constant_override("v_separation", 6)
	pane.add_child(stats)
	for value in data["stats"]:
		var label := _label(str(value), 18, GOLD)
		label.custom_minimum_size.y = 39
		stats.add_child(label)
	pane.add_child(_label(L10n.t("JAK DZIAŁA"), 18, GOLD))
	pane.add_child(_label(data["body"], 20))
	pane.add_child(_label(L10n.t("KIEDY UŻYĆ"), 18, GOLD))
	pane.add_child(_label(data["tip"], 19))
	if not str(data["limit"]).is_empty():
		pane.add_child(_label(data["limit"], 17, Color("aebec8")))

func _toggle_preview() -> void:
	if live_preview == null:
		return
	live_preview.toggle_playback()
	var button := find_child("TogglePreview", true, false) as Button
	button.text = L10n.t("Pauza") if live_preview.playing else L10n.t("Odtwórz")

func _build_tutorial() -> void:
	_heading(L10n.t("JAK GRAĆ"), L10n.t("Zdobądź złoto wroga. Ocal własny skarbiec."))
	var art := _image("res://assets/epic/world/battlefield_clean.jpg", 190)
	art.name = "TutorialBattlefield"
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.clip_contents = true
	content.add_child(art)
	var chapters := [
		[L10n.t("ZŁOTO JEST TWOIM ŻYCIEM"), L10n.t("Zaczynasz z 1000 złota. Każdy zakup zabiera monety ze skarbca. Gdy twój skarbiec osiągnie zero, przegrywasz od razu. Zachowuj rezerwę."), "dwarf_bank"],
		[L10n.t("PRZYGOTOWANIE • 30 SEKUND"), L10n.t("Wybierz jedną z trzech alejek. Kup zwiadowców (75), tragarzy (140), sabotażystów (110), obronę lub ulepszenia. Szczegóły i podglądy znajdziesz w Księdze gry."), "dwarf_runner"],
		[L10n.t("ATAK • DO 60 SEKUND"), L10n.t("Darmowa fala rusza z kupionymi jednostkami. Najeźdźca musi ukraść złoto i wrócić do twojego skarbca. Łup niedostarczony przed końcem fali wraca do obrabowanej strony."), "goblin_carrier"],
		[L10n.t("ROZWIJAJ SKARBIEC"), L10n.t("Poziomy skarbca 1–5 zmieniają jego wygląd i dodają po 4 punkty procentowe odsetek po fali. Odsetki liczą się od pozostałego złota; minimalna wypłata to 20."), "elf_bank"],
		[L10n.t("BROŃ SWOICH ALEJEK"), L10n.t("Kolce zadają obrażenia. Sidła ranią i zatrzymują przeciwnika na 2,5 s. Wieżyczki strzelają co 0,6 s. Obrońca pilnuje wybranej alejki."), "dwarf_turret"],
		[L10n.t("RASY I ZDOLNOŚCI"), L10n.t("Krasnoludy: oszczędzanie i PŻ. Gobliny: szybkość. Elfy: PŻ i łup. Voidborn: szybkość i łup. Zdolność kosztuje 120 złota, raz na falę w przygotowaniach. Iron Wall wzmacnia już zatrudnionych obrońców."), "goblin_ability"],
		[L10n.t("ZWYCIĘSTWO"), L10n.t("Opróżnij skarbiec przeciwnika. Każda wydana moneta zmniejsza też twoje życie. Mecz trwa do wyzerowania skarbca; nie ma limitu pięciu fal."), "dwarf_raid"]
	]
	for index in chapters.size():
		var chapter: Array = chapters[index]
		var pane := _panel(content)
		pane.get_parent().name = "TutorialChapter%d" % index
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 16)
		pane.add_child(row)
		var illustration := _image("res://assets/ui/direct/" + str(chapter[2]) + ".png", 100)
		illustration.custom_minimum_size.x = 110
		illustration.size_flags_horizontal = Control.SIZE_FILL
		row.add_child(illustration)
		var copy := VBoxContainer.new()
		copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		copy.add_theme_constant_override("separation", 10)
		row.add_child(copy)
		copy.add_child(_label(str(chapter[0]), 21, GOLD))
		copy.add_child(_label(str(chapter[1]), 19))
	_button(footer, L10n.t("WRÓĆ DO MENU"), "BackToMainMenu", game._close_how_to_play)
	_primary_style(_button(footer, L10n.t("ROZPOCZNIJ GRĘ"), "BeginFromHowTo", game._open_race_selection, true))

func _build_settings() -> void:
	_heading(L10n.t("USTAWIENIA"), L10n.t("Dostosuj oprawę do telefonu i swojego komfortu."))
	var language_panel := _panel(content)
	language_panel.add_child(_label(L10n.t("JĘZYK"), 24, GOLD))
	var language := OptionButton.new()
	language.name = "LanguageMode"
	language.custom_minimum_size.y = 66
	language.add_item("Polski")
	language.add_item("English")
	language.selected = L10n.LANGUAGES.find(game.presentation.language)
	language_panel.add_child(language)
	Epic.button(language, false, 20)
	language.item_selected.connect(func(index: int) -> void: game.call_deferred("_change_language", L10n.LANGUAGES[index]))
	language_panel.add_child(_label(L10n.t("Zmiana języka działa od razu i zostaje zapisana."), 18))
	var art := _image(WORDMARK, 86)
	art.name = "SettingsCrest"
	content.add_child(art)
	var panel := _panel(content)
	panel.add_child(_label(L10n.t("JAKOŚĆ I BATERIA"), 24, GOLD))
	panel.add_child(_label(L10n.t("Automatyczny ogranicza efekty przy utrzymujących się spadkach płynności. Oszczędny zmniejsza ruch i zużycie baterii."), 20))
	var quality := OptionButton.new()
	quality.name = "QualityMode"
	quality.custom_minimum_size.y = 66
	for title in [L10n.t("Automatyczny"), L10n.t("Oszczędny • do 30 kl./s"), L10n.t("Zrównoważony • do 60 kl./s"), L10n.t("Wysoki • do 60 kl./s")]:
		quality.add_item(L10n.t(title))
	quality.selected = game.presentation.MODES.find(game.presentation.quality)
	panel.add_child(quality)
	quality.item_selected.connect(_quality_changed)
	Epic.button(quality, false, 20)
	quality_caption = _label("", 18, GOLD)
	panel.add_child(quality_caption)
	_update_quality_caption()
	var comfort := _panel(content)
	comfort.add_child(_label(L10n.t("KOMFORT"), 24, GOLD))
	_check(comfort, L10n.t("Ogranicz ruch"), "ReducedMotion", game.presentation.reduced_motion, func(value: bool) -> void:
		game.presentation.reduced_motion = value
		game._apply_presentation(true))
	_check(comfort, L10n.t("Muzyka"), "MusicEnabled", game.presentation.music_enabled, func(value: bool) -> void:
		game.presentation.music_enabled = value
		game._apply_presentation(true))
	_check(comfort, L10n.t("Licznik płynności w bitwie"), "ShowFPS", game.presentation.show_fps, func(value: bool) -> void:
		game.presentation.show_fps = value
		game._apply_presentation(true))
	comfort.add_child(_label(L10n.t("Zmiany zapisują się od razu. Jakość efektów nie zmienia zasad, kosztów ani obrażeń."), 18))
	var artwork := _image(MENU_ART, 190)
	artwork.name = "SettingsIllustration"
	artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	artwork.size_flags_vertical = Control.SIZE_EXPAND_FILL
	artwork.clip_contents = true
	content.add_child(artwork)
	_button(footer, L10n.t("Wróć"), "CloseSettings", game._close_settings)

func _check(parent: Node, caption: String, id: String, value: bool, handler: Callable) -> void:
	var check := CheckButton.new()
	check.name = id
	check.text = L10n.t(caption)
	check.custom_minimum_size.y = 72
	check.add_theme_font_size_override("font_size", 19)
	check.button_pressed = value
	check.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	parent.add_child(check)
	check.add_theme_stylebox_override("normal", Epic.panel(14))
	check.add_theme_stylebox_override("hover", Epic.panel(14))
	check.add_theme_stylebox_override("pressed", Epic.panel(14))
	check.add_theme_stylebox_override("focus", Epic.focus())
	check.add_theme_color_override("font_color", COPY)
	check.toggled.connect(handler)

func _quality_changed(index: int) -> void:
	game.presentation.quality = game.presentation.MODES[index]
	game.presentation.resolve_profile()
	game._apply_presentation(true)
	_update_quality_caption()

func _update_quality_caption() -> void:
	var label: String = {"battery": L10n.t("oszczędny"), "balanced": L10n.t("zrównoważony"), "high": L10n.t("wysoki")}[game.presentation.effective_quality]
	quality_caption.text = L10n.t("Aktywny profil: %s") % label

func _open_tutorial() -> void:
	game._close_codex()
	game._show_how_to_play()

func _open_studio() -> void:
	game._close_codex()
	game._open_animation_gallery()
