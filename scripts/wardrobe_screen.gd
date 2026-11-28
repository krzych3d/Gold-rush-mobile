extends Control
## A scene-local preview. Locked costumes can be inspected but never equipped.
const Skins = preload("res://scripts/unit_skins.gd")
const Epic = preload("res://scripts/epic_theme.gd")
const Preview = preload("res://scripts/menu_preview.gd")
const MobileLayout = preload("res://scripts/mobile_layout.gd")
const L10n = preload("res://scripts/localization.gd")
var game
var race := 0
var skin := "classic"
var role := 0
var action := -1
var reverse := false
var margin: MarginContainer
var body: BoxContainer
var preview: Control
var title: Label
var lore: Label
var requirement: Label
var kind: Label
var equip_button: Button
var choices: VBoxContainer
var notice: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	skin = game.wardrobe.equipped(race, game.account)
	_build()
	resized.connect(_layout)
	_layout()

func _label(parent: Node, text: String, font_size: int = 20) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", Color("f0dfbd"))
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label

func _button(parent: Node, text: String, callback: Callable, primary: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 56
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	Epic.button(button, primary, 18)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _build() -> void:
	var background := TextureRect.new()
	background.texture = load("res://assets/epic/story/chronicle.jpg")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var shade := ColorRect.new()
	shade.color = Color("050913", 0.67)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	margin = MarginContainer.new()
	margin.name = "WardrobeSafeArea"
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 10)
	margin.add_child(stack)
	var heading := HBoxContainer.new()
	heading.add_theme_constant_override("separation", 8)
	stack.add_child(heading)
	var heading_label := _label(heading, Skins.text(["KSIĘGA STROJÓW", "BOOK OF COSTUMES"]), 26)
	Epic.heading(heading_label, 26)
	heading_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for code in ["pl", "en"]:
		var language_button := _button(heading, code.to_upper(), game._change_language.bind(code))
		language_button.size_flags_horizontal = Control.SIZE_SHRINK_END
		language_button.custom_minimum_size.x = 64
	var back := _button(heading, Skins.text(["WRÓĆ", "BACK"]), game._close_wardrobe)
	back.name = "CloseWardrobe"
	back.size_flags_horizontal = Control.SIZE_SHRINK_END
	back.custom_minimum_size.x = 110
	var races := HBoxContainer.new()
	races.add_theme_constant_override("separation", 6)
	stack.add_child(races)
	for index in 4:
		var button := _button(races, L10n.t(game.RACE_NAMES[index]), _select_race.bind(index), index == race)
		button.name = "SkinRace%d" % index
		button.add_theme_font_size_override("font_size", 15)
	var scroll := ScrollContainer.new()
	scroll.name = "WardrobeScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(scroll)
	body = BoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 16)
	scroll.add_child(body)
	var left := VBoxContainer.new()
	left.name = "CostumePreviewColumn"
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.0
	left.add_theme_constant_override("separation", 10)
	body.add_child(left)
	title = _label(left, "", 25)
	Epic.heading(title, 25)
	preview = Preview.new()
	preview.name = "CostumeLivePreview"
	preview.custom_minimum_size.y = 310
	left.add_child(preview)
	var playback := HBoxContainer.new()
	playback.add_theme_constant_override("separation", 8)
	left.add_child(playback)
	var roles := OptionButton.new()
	roles.name = "SkinRole"
	for pair in [["Zwiadowca", "Runner"], ["Tragarz", "Carrier"], ["Sabotażysta", "Saboteur"], ["Obrońca", "Defender"]]:
		roles.add_item(Skins.text(pair))
	roles.selected = role
	roles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	Epic.option(roles, 18)
	roles.item_selected.connect(func(index): role = index; _update_preview())
	playback.add_child(roles)
	var actions := OptionButton.new()
	actions.name = "SkinAction"
	for pair in [["Pełny pokaz", "Full showcase"], ["Spoczynek", "Idle"], ["Ruch", "Walk"], ["Atak", "Attack"], ["Trafienie", "Hit"], ["Upadek", "Fall"], ["Oddanie złota", "Deposit gold"]]:
		actions.add_item(Skins.text(pair))
	actions.selected = action + 1
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	Epic.option(actions, 18)
	actions.item_selected.connect(func(index): action = index - 1; preview.set_action(action))
	playback.add_child(actions)
	var motion := HBoxContainer.new()
	motion.add_theme_constant_override("separation", 8)
	left.add_child(motion)
	_button(motion, Skins.text(["ODWRÓĆ POSTAĆ", "TURN AROUND"]), _reverse).name = "SkinDirection"
	_button(motion, Skins.text(["ODTWÓRZ / PAUZA", "PLAY / PAUSE"]), func(): preview.toggle_playback()).name = "SkinPlayback"
	kind = _label(left, "", 17)
	var right := VBoxContainer.new()
	right.name = "CostumeDetailsColumn"
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 12)
	body.add_child(right)
	lore = _label(right, "", 21)
	requirement = _label(right, "", 20)
	equip_button = _button(right, "", _equip, true)
	equip_button.name = "EquipSkin"
	choices = VBoxContainer.new()
	choices.name = "CostumeChoices"
	choices.add_theme_constant_override("separation", 8)
	right.add_child(choices)
	notice = _label(right, Skins.text(["Stroje zmieniają wygląd twojej armii w pojedynkach. Kampania dobiera kostiumy do sceny. Zdrowie, ceny i zdolności pozostają takie same.", "Costumes change your army’s appearance in duels. The campaign chooses outfits for each scene. Health, prices and abilities stay the same."]), 17)
	_update_selection()

func _layout() -> void:
	if margin == null:
		return
	var safe: Rect2 = MobileLayout.safe_rect(self)
	margin.add_theme_constant_override("margin_left", int(safe.position.x) + 18)
	margin.add_theme_constant_override("margin_right", int(size.x - safe.end.x) + 18)
	margin.add_theme_constant_override("margin_top", int(safe.position.y) + 14)
	margin.add_theme_constant_override("margin_bottom", int(size.y - safe.end.y) + 14)
	body.vertical = safe.size.x < safe.size.y * 1.15
	preview.custom_minimum_size.y = 300 if body.vertical else 280

func rebuild_language() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_build()
	_layout()

func _select_race(index: int) -> void:
	race = index
	skin = game.wardrobe.equipped(race, game.account)
	role = 0
	rebuild_language()

func _select_skin(id: String) -> void:
	skin = id
	_update_selection()

func _update_selection() -> void:
	var data: Dictionary = Skins.data(skin)
	title.text = Skins.text(data["name"])
	lore.text = Skins.text(data["lore"])
	kind.text = Skins.text(data["type"])
	requirement.text = Skins.requirement(skin, race, game.account)
	var available: bool = Skins.available(skin, race, game.account)
	var equipped: bool = available and skin == game.wardrobe.equipped(race, game.account)
	equip_button.disabled = not available or equipped
	equip_button.text = Skins.text(["ZAŁOŻONA", "EQUIPPED"]) if equipped else Skins.text(["ZAŁÓŻ STRÓJ", "EQUIP COSTUME"]) if available else Skins.text(["PODGLĄD • ZABLOKOWANA", "PREVIEW • LOCKED"])
	for child in choices.get_children():
		choices.remove_child(child)
		child.queue_free()
	for option in Skins.for_race(race):
		var id: String = option["id"]
		var caption: String = Skins.text(option["name"])
		if id == game.wardrobe.equipped(race, game.account) and game.account.race_unlocked(race):
			caption += "  ◆"
		var button := _button(choices, caption, _select_skin.bind(id), id == skin)
		button.name = "Skin_" + id
		button.custom_minimum_size.y = 64
	_update_preview()

func _update_preview() -> void:
	preview.direction_override = -1.0 if reverse else 1.0
	preview.configure(game, {"race": race, "role": mini(role, 2), "demo": "defender" if role == 3 else "unit", "skin": skin})
	preview.set_action(action)

func _reverse() -> void:
	reverse = not reverse
	preview.direction_override = -1.0 if reverse else 1.0
	preview._update_pose()
	preview.queue_redraw()

func _equip() -> void:
	var result: String = game.wardrobe.equip(race, skin, game.account)
	if result == "save_failed":
		notice.text = Skins.text(["Nie zapisano stroju. Poprzedni wybór pozostał aktywny. Sprawdź wolne miejsce na urządzeniu.", "Costume could not be saved. Your previous selection remains active. Check free device storage."])
		return
	game.last_localized_card_signature = ""
	game._refresh()
	_update_selection()
