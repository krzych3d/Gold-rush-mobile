extends Control
## Native mobile lobby: artwork, working navigation and one visible atlas preview.
const Catalog = preload("res://scripts/game_catalog.gd")
const Preview = preload("res://scripts/menu_preview.gd")
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
	background.texture = game.epic_battlefield_texture
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.modulate = Color(0.38, 0.50, 0.62, 1.0)
	add_child(background)
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.045, 0.075, 0.88)
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
		"home": _build_home()
		"race": _build_races()
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

func _label(text: String, font_size: int = 20, color: Color = COPY) -> Label:
	var node := Label.new()
	node.text = text
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return node

func _button(parent: Node, caption: String, id: String, handler: Callable, primary: bool = false) -> Button:
	var node := Button.new()
	node.name = id
	node.text = caption
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

func _install_theme() -> void:
	theme = Theme.new()
	theme.default_font_size = 20
	for control_type in ["OptionButton", "LineEdit", "ItemList"]:
		theme.set_color("font_color", control_type, COPY)
		theme.set_color("font_selected_color", control_type, GOLD)
		for variant in ["normal", "hover", "pressed", "focus"]:
			theme.set_stylebox(variant, control_type, _button_skin(false, variant))
	theme.set_stylebox("panel", "ItemList", _button_skin())
	theme.set_stylebox("selected", "ItemList", _button_skin(false, "focus"))
	theme.set_stylebox("selected_focus", "ItemList", _button_skin(false, "focus"))
	theme.set_color("font_placeholder_color", "LineEdit", Color("829baa"))

func _panel(parent: Node, tint: Color = GOLD) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var skin := StyleBoxFlat.new()
	skin.bg_color = Color("0b1928", 0.96)
	skin.border_color = Color(tint, 0.45)
	skin.set_border_width_all(1)
	skin.set_corner_radius_all(16)
	skin.set_content_margin_all(15)
	panel.add_theme_stylebox_override("panel", skin)
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
	art.texture = load(path) as Texture2D if ResourceLoader.exists(path) else null
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.custom_minimum_size.y = height
	art.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return art

func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
	live_preview = null

func _build_home() -> void:
	var logo := _image("res://assets/ui/direct/title.png", 100)
	logo.name = "MainMenuLogo"
	content.add_child(logo)
	_heading("TWÓJ SKARBIEC. TWOJA LEGENDA.", "4 rasy  •  3 alejki  •  złoto jest twoim życiem")
	var showcase := _panel(content)
	showcase.get_parent().size_flags_vertical = Control.SIZE_EXPAND_FILL
	hero_art = _image(Catalog.portrait(focus_race), 235)
	hero_art.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hero_art.name = "MainMenuScenery"
	showcase.add_child(hero_art)
	hero_name = _label("", 27, GOLD)
	showcase.add_child(hero_name)
	hero_copy = _label("", 18)
	showcase.add_child(hero_copy)
	live_preview = Preview.new()
	live_preview.name = "HomeLivePreview"
	live_preview.custom_minimum_size.y = 220
	showcase.add_child(live_preview)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	showcase.add_child(row)
	for index in 4:
		var choice := _button(row, Catalog.RACE_TITLES[index], "ShowcaseRace%d" % index, _showcase_race.bind(index))
		choice.add_theme_font_size_override("font_size", 16)
	_showcase_race(focus_race)
	var prompt := _label("Zbuduj obronę. Wyślij najeźdźców. Wróć ze złotem.", 19, GOLD)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(prompt)
	_button(footer, "ROZPOCZNIJ GRĘ", "StartGame", game._open_race_selection, true)
	var shortcuts := HBoxContainer.new()
	shortcuts.add_theme_constant_override("separation", 8)
	footer.add_child(shortcuts)
	_button(shortcuts, "Księga gry", "OpenCodex", game._show_codex.bind("runner"))
	_button(shortcuts, "Jak grać", "HowToPlay", game._show_how_to_play)
	var utilities := HBoxContainer.new()
	utilities.add_theme_constant_override("separation", 8)
	footer.add_child(utilities)
	_button(utilities, "Ustawienia", "OpenSettings", game._show_settings)
	_button(utilities, "Animacje", "OpenAnimationStudio", game._open_animation_gallery)

func _showcase_race(index: int) -> void:
	focus_race = index
	hero_art.texture = load(Catalog.portrait(index)) as Texture2D
	hero_name.text = Catalog.RACE_TITLES[index] + "  /  " + Catalog.RACE_STYLES[index]
	hero_name.add_theme_color_override("font_color", game.RACE_COLORS[index])
	hero_copy.text = ["Więcej oszczędności i pancerza.", "Tempo, wypady i szybki powrót.", "Więcej PŻ i miejsca na złoto.", "Kosmiczni zabójcy. Szybkość i bogate łupy."][index]
	live_preview.configure(game, Catalog.find(game, index, "race_%d" % index))

func _build_races() -> void:
	_heading("WYBIERZ SWOJĄ RASĘ", "Dotknij portretu. Poznaj premię i zobacz jednostki w ruchu.")
	var grid := GridContainer.new()
	grid.name = "RacePortraitGrid"
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	content.add_child(grid)
	for index in 4:
		var card := Button.new()
		card.name = "ChooseRace%d" % index
		card.custom_minimum_size.y = 185
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(card)
		var stack := VBoxContainer.new()
		stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stack.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		stack.offset_left = 8
		stack.offset_right = -8
		stack.offset_top = 8
		stack.offset_bottom = -8
		card.add_child(stack)
		var art := _image(Catalog.portrait(index), 125)
		art.size_flags_vertical = Control.SIZE_EXPAND_FILL
		stack.add_child(art)
		var name_label := _label(Catalog.RACE_TITLES[index], 22, game.RACE_COLORS[index])
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stack.add_child(name_label)
		card.pressed.connect(select_race.bind(index))
		race_cards.append(card)
	race_detail = VBoxContainer.new()
	race_detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	race_detail.add_theme_constant_override("separation", 10)
	content.add_child(race_detail)
	_button(footer, "", "ConfirmFaction", game._confirm_faction, true)
	var navigation := HBoxContainer.new()
	navigation.add_theme_constant_override("separation", 8)
	footer.add_child(navigation)
	_button(navigation, "Poznaj tę rasę", "InspectRace", _inspect_race)
	_button(navigation, "Wróć do menu", "BackFromRace", game._back_from_race_selection)
	select_race(game.selected_race)

func select_race(index: int) -> void:
	focus_race = index
	game.selected_race = index
	for race_index in race_cards.size():
		var skin := StyleBoxFlat.new()
		skin.bg_color = Color("101f2c") if index == race_index else Color("09121e")
		skin.border_color = GOLD if index == race_index else Color(game.RACE_COLORS[race_index], 0.4)
		skin.set_border_width_all(3 if index == race_index else 1)
		skin.set_corner_radius_all(12)
		race_cards[race_index].add_theme_stylebox_override("normal", skin)
		race_cards[race_index].add_theme_stylebox_override("focus", skin)
		race_cards[race_index].add_theme_stylebox_override("hover", skin)
		race_cards[race_index].add_theme_stylebox_override("pressed", skin)
	_clear(race_detail)
	var panel := _panel(race_detail, game.RACE_COLORS[index])
	panel.get_parent().size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(_label(Catalog.RACE_TITLES[index] + " • " + Catalog.RACE_STYLES[index], 25, game.RACE_COLORS[index]))
	panel.add_child(_label(Catalog.RACE_COPY[index], 18))
	live_preview = Preview.new()
	live_preview.name = "RaceLivePreview"
	live_preview.custom_minimum_size.y = 180
	live_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(live_preview)
	var data: Dictionary = Catalog.find(game, index, "defender" if race_role == 3 else ["runner", "carrier", "saboteur"][race_role])
	live_preview.configure(game, data)
	var roles := OptionButton.new()
	roles.name = "PreviewRole"
	roles.custom_minimum_size.y = 58
	for title in ["Zwiadowca • szybki najazd", "Tragarz • duży łup", "Sabotażysta • rozbrajanie pułapek", "Obrońca • ochrona alejki"]:
		roles.add_item(title)
	roles.selected = race_role
	panel.add_child(roles)
	roles.item_selected.connect(_pick_role)
	var confirm := find_child("ConfirmFaction", true, false) as Button
	confirm.text = "GRAJ: " + Catalog.RACE_TITLES[index].to_upper()

func _pick_role(index: int) -> void:
	race_role = index
	var data: Dictionary = Catalog.find(game, focus_race, "defender" if index == 3 else ["runner", "carrier", "saboteur"][index])
	live_preview.configure(game, data)

func _inspect_race() -> void:
	game._show_codex("race_%d" % focus_race)

func _build_codex() -> void:
	_heading("KSIĘGA GRY", "Dotknij wpisu, aby poznać koszt, działanie i sposób użycia.")
	var filters := HBoxContainer.new()
	filters.add_theme_constant_override("separation", 8)
	content.add_child(filters)
	category_filter = OptionButton.new()
	category_filter.name = "CatalogCategory"
	category_filter.custom_minimum_size.y = 58
	category_filter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for title in Catalog.CATEGORIES:
		category_filter.add_item(title)
	filters.add_child(category_filter)
	race_filter = OptionButton.new()
	race_filter.name = "CatalogRace"
	race_filter.custom_minimum_size.y = 58
	race_filter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for title in Catalog.RACE_TITLES:
		race_filter.add_item(title)
	race_filter.selected = focus_race
	filters.add_child(race_filter)
	search = LineEdit.new()
	search.name = "CatalogSearch"
	search.placeholder_text = "Szukaj jednostki, pułapki, zdolności…"
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
	_button(footer, "Wróć", "CloseCodex", game._close_codex)
	_filter_entries()

func _filter_entries() -> void:
	entry_list.clear()
	filtered_entries.clear()
	var query: String = search.text.strip_edges().to_lower()
	var category: String = Catalog.CATEGORIES[category_filter.selected]
	var selected := -1
	for entry in Catalog.entries(game, focus_race):
		if category != "Wszystko" and entry["category"] != category:
			continue
		var haystack: String = (str(entry["title"]) + " " + str(entry["body"]) + " " + str(entry["tip"]) + " " + str(entry["stats"])).to_lower()
		if not query.is_empty() and not haystack.contains(query):
			continue
		if entry["id"] == focus_entry:
			selected = filtered_entries.size()
		filtered_entries.append(entry)
		var icon: Texture2D = load(entry["art"]) as Texture2D if ResourceLoader.exists(entry["art"]) else null
		entry_list.add_item(entry["title"], icon)
	result_count.text = "%d wpisów • statystyki: %s" % [filtered_entries.size(), Catalog.RACE_TITLES[focus_race]]
	if filtered_entries.is_empty():
		_clear(detail)
		detail.add_child(_label("Brak wyników. Zmień kategorię lub skróć wyszukiwanie.", 22, GOLD))
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
	for label in ["Pokaz działania", "Spoczynek", "Ruch", "Atak", "Trafienie", "Upadek", "Oddanie złota"]:
		actions.add_item(label)
	actions.disabled = data["demo"] in ["bank", "spikes", "snare", "turret"]
	playback.add_child(actions)
	actions.item_selected.connect(func(action_index: int) -> void: live_preview.set_action(action_index - 1))
	var pause := _button(playback, "Pauza" if live_preview.playing else "Odtwórz", "TogglePreview", _toggle_preview)
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
	pane.add_child(_label("JAK DZIAŁA", 18, GOLD))
	pane.add_child(_label(data["body"], 20))
	pane.add_child(_label("KIEDY UŻYĆ", 18, GOLD))
	pane.add_child(_label(data["tip"], 19))
	if not str(data["limit"]).is_empty():
		pane.add_child(_label(data["limit"], 17, Color("aebec8")))

func _toggle_preview() -> void:
	if live_preview == null:
		return
	live_preview.toggle_playback()
	var button := find_child("TogglePreview", true, false) as Button
	button.text = "Pauza" if live_preview.playing else "Odtwórz"

func _build_settings() -> void:
	_heading("USTAWIENIA", "Dostosuj oprawę do telefonu i swojego komfortu.")
	var panel := _panel(content)
	panel.add_child(_label("JAKOŚĆ I BATERIA", 24, GOLD))
	panel.add_child(_label("Automatyczny ogranicza efekty przy utrzymujących się spadkach płynności. Oszczędny zmniejsza ruch i zużycie baterii.", 20))
	var quality := OptionButton.new()
	quality.name = "QualityMode"
	quality.custom_minimum_size.y = 66
	for title in ["Automatyczny", "Oszczędny • do 30 kl./s", "Zrównoważony • do 60 kl./s", "Wysoki • do 60 kl./s"]:
		quality.add_item(title)
	quality.selected = game.presentation.MODES.find(game.presentation.quality)
	panel.add_child(quality)
	quality.item_selected.connect(_quality_changed)
	quality_caption = _label("", 18, GOLD)
	panel.add_child(quality_caption)
	_update_quality_caption()
	var comfort := _panel(content)
	comfort.add_child(_label("KOMFORT", 24, GOLD))
	_check(comfort, "Ogranicz ruch • podglądy startują w pauzie", "ReducedMotion", game.presentation.reduced_motion, func(value: bool) -> void:
		game.presentation.reduced_motion = value
		game._apply_presentation(true))
	_check(comfort, "Muzyka", "MusicEnabled", game.presentation.music_enabled, func(value: bool) -> void:
		game.presentation.music_enabled = value
		game._apply_presentation(true))
	_check(comfort, "Licznik płynności w bitwie", "ShowFPS", game.presentation.show_fps, func(value: bool) -> void:
		game.presentation.show_fps = value
		game._apply_presentation(true))
	comfort.add_child(_label("Zmiany zapisują się od razu. Jakość efektów nie zmienia zasad, kosztów ani obrażeń.", 18))
	_button(footer, "Wróć", "CloseSettings", game._close_settings)

func _check(parent: Node, caption: String, id: String, value: bool, handler: Callable) -> void:
	var check := CheckButton.new()
	check.name = id
	check.text = caption
	check.custom_minimum_size.y = 72
	check.add_theme_font_size_override("font_size", 19)
	check.button_pressed = value
	check.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	parent.add_child(check)
	check.toggled.connect(handler)

func _quality_changed(index: int) -> void:
	game.presentation.quality = game.presentation.MODES[index]
	game.presentation.resolve_profile()
	game._apply_presentation(true)
	_update_quality_caption()

func _update_quality_caption() -> void:
	var label: String = {"battery": "oszczędny", "balanced": "zrównoważony", "high": "wysoki"}[game.presentation.effective_quality]
	quality_caption.text = "Aktywny profil: " + label
