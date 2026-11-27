extends Control
## Dwarven story episodes. UI is modal; simulation is owned by game.gd.
const Epic = preload("res://scripts/epic_theme.gd")
const Battlefields = preload("res://scripts/battlefields.gd")
const CampaignMaps = preload("res://scripts/campaign_maps.gd")
const MobileLayout = preload("res://scripts/mobile_layout.gd")
const L10n = preload("res://scripts/localization.gd")
const FIRST_CHAPTERS = [
	{"id": "dwarf_bells", "race": 0, "level": 1, "requires": "", "map": "dwarves", "enemy": 0, "waves": 3, "target": 0, "gold": 1250,
	"title": ["Dzwony dla umarłych", "Bells for the Dead"],
	"objective": ["Przetrwaj 3 fale i ocal własny skarbiec.", "Survive 3 waves and keep your vault alive."],
	"intro": ["VARGHEIM • Noc królewskiego pogrzebu\n\nBorin: Trzynasty dzwon. A mamy przecież tylko dwanaście.\nThorgar: Zamknij bramy. Nikt nie może opuścić miasta.\nBorin: To nie mieszkańcy uciekają. To strażnicy wychodzą z grobowców.\n\nZmarła córka Thorgara nosiła srebrny dzwoneczek. Teraz ten sam dźwięk dochodzi ze skarbca.", "VARGHEIM • The royal funeral\n\nBorin: A thirteenth bell. We only have twelve.\nThorgar: Seal the gates. Nobody leaves the city.\nBorin: It is not the citizens fleeing. The guards are leaving their tombs.\n\nThorgar's late daughter wore a silver bell. Now its sound comes from the vault."],
	"mid": ["Strażnik: Dowódco... rozpoznaję ich. To nasi polegli.\nBorin: Ich imiona są zapisane na monetach w królewskim skarbcu. Ktoś przywołuje ich do służby.\nThorgar: Własnych zmarłych?! Utrzymać bramę.\n\nW kolejnych falach nadciągną dodatkowi najeźdźcy.", "Guard: Commander... I know them. They are our fallen.\nBorin: Their names are stamped on coins in the royal vault. Someone is calling them back to duty.\nThorgar: Our own dead?! Hold the gate.\n\nAdditional raiders arrive in the next waves."],
	"outro": ["Ostatni dzwon milknie. Thorgar znajduje monetę z imieniem swojej córki: Eira. Na jej odwrocie widnieje data jutrzejszego dnia.\n\nEira (szept): Tato... góra nie jest grobem. Góra jest głodna.\n\nBorin wskazuje zapieczętowany szyb. Ktoś otworzył go od środka.", "The last bell falls silent. Thorgar finds a coin bearing his daughter's name: Eira. Its reverse bears tomorrow's date.\n\nEira (whisper): Father... the mountain is not a tomb. The mountain is hungry.\n\nBorin points to the sealed shaft. Someone opened it from within."]},
	{"id": "dwarf_mountain", "race": 0, "level": 1, "requires": "dwarf_bells", "map": "void", "enemy": 3, "waves": 4, "target": 180, "gold": 1400,
	"title": ["Góra, która oddycha", "The Breathing Mountain"],
	"objective": ["Dostarcz 180 złota pamięci do skarbca w maks. 4 falach. Zachowaj własny skarbiec.", "Deliver 180 memory gold to your vault within 4 waves. Keep your vault alive."],
	"intro": ["ZAPIECZĘTOWANY SZYB • Pod Vargheim\n\nBorin: Te tunele nie są wykute w skale. To żebra.\nThorgar: Znajdźmy monetę Eiry.\nBorin: Oddech góry spowalnia obie armie na jednej linii. Uważaj na fioletową szczelinę. Co falę przenosi się na następną linię.\n\nOdzyskaj 180 złota pamięci. Liczy się wyłącznie łup dostarczony do domu, nie odsetki.", "THE SEALED SHAFT • Beneath Vargheim\n\nBorin: These tunnels were not carved in stone. They are ribs.\nThorgar: Find Eira's coin.\nBorin: The mountain's breath slows both armies on one lane. Watch the violet fissure. It moves to the next lane each wave.\n\nRecover 180 memory gold. Only loot delivered home counts, not interest."],
	"mid": ["Eira: Nie jestem jedyną. Pod nami są tysiące głosów.\nBorin: Kapłani przetapiają monety z imionami zmarłych. Tak powstają nasze odsetki...\nThorgar: Przez całe życie zanosiłem tam monety poległych.\n\nGóra budzi się. Jej oddech zmienia linię.", "Eira: I am not the only one. Thousands of voices lie below us.\nBorin: The priests melt coins bearing the names of the dead. That is where our interest comes from...\nThorgar: All my life I brought them the coins of fallen soldiers.\n\nThe mountain wakes. Its breath changes lanes."],
	"outro": ["W odzyskanym złocie Thorgar słyszy własny głos, choć wciąż żyje.\n\nGłos: Złóż przysięgę, a odzyskasz córkę.\nBorin: Nie słuchaj. To nie Eira.\n\nNa ścianie szybów wyryto cztery herby i piąty, celowo zniszczony. Pod nimi: «Pierwszy dług nie został spłacony».", "In the recovered gold, Thorgar hears his own voice, though he is still alive.\n\nVoice: Swear the oath and your daughter will return.\nBorin: Do not listen. That is not Eira.\n\nFour crests are carved into the shaft wall, and a fifth was deliberately destroyed. Below: 'The first debt remains unpaid.'"]}
]
const MISSIONS = FIRST_CHAPTERS + preload("res://scripts/dwarf_chapters.gd").MISSIONS
var game
var mode := "menu"
var index := 0
var won := false
var reward: Dictionary = {}

static func copy(pl: String, en: String) -> String:
	return pl if L10n.language == "pl" else en

static func localized(pair: Array) -> String:
	return str(pair[0] if L10n.language == "pl" else pair[1])

static func unlocked(profile, mission_index: int) -> bool:
	if mission_index < 0 or mission_index >= MISSIONS.size():
		return false
	var mission: Dictionary = MISSIONS[mission_index]
	return profile.race_unlocked(int(mission["race"])) and profile.level() >= int(mission["level"]) and (str(mission["requires"]).is_empty() or profile.campaign_completed.has(str(mission["requires"])))

static func hazard_lane(mission_index: int, wave: int) -> int:
	return (wave - 1) % 3 if mission_index == 1 else -1

static func speed_factor(mission_index: int, wave: int, lane: int) -> float:
	return 0.55 if lane == hazard_lane(mission_index, wave) else 1.0

const SceneArt = preload("res://scripts/story_scene.gd")
var body: BoxContainer
var portrait_scene: Control
var text_label: Label
var page_label: Label
var advance: Button
var pages_text := PackedStringArray()
var page := 0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := TextureRect.new()
	bg.name = "ChronicleArtwork"
	bg.texture = load("res://assets/epic/story/chronicle.jpg")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var margin := MarginContainer.new()
	margin.name = "StorySafeArea"
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 10)
	margin.add_child(stack)
	_label(stack, copy("TESTAMENT UMARŁYCH BOGÓW", "TESTAMENT OF THE DEAD GODS"), 23, true)
	_label(stack, copy("KRASNOLUDY • DZIEDZICTWO KRWI", "DWARVES • LEGACY OF BLOOD"), 17, true)
	body = BoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 14)
	stack.add_child(body)
	if mode == "menu":
		_build_chronicle(stack)
	else:
		_build_dialogue(stack)
	resized.connect(_layout.bind(margin))
	_layout(margin)

func _layout(margin: MarginContainer) -> void:
	var safe := MobileLayout.safe_rect(self)
	margin.offset_left = safe.position.x + 20
	margin.offset_top = safe.position.y + 18
	margin.offset_right = safe.end.x - size.x - 20
	margin.offset_bottom = safe.end.y - size.y - 18
	body.vertical = size.x < 950 or size.x < size.y * 1.3
	if is_instance_valid(portrait_scene):
		portrait_scene.custom_minimum_size = Vector2(0, minf(300, size.y * 0.30)) if body.vertical else Vector2(size.x * 0.34, 0)
		portrait_scene.size_flags_vertical = Control.SIZE_FILL if body.vertical else Control.SIZE_EXPAND_FILL

func _scene(parent: Node, chapter: int) -> Control:
	var scene = SceneArt.new()
	scene.name = "StoryParallax"
	scene.battlefield = CampaignMaps.texture(chapter)
	scene.portrait_name = str(MISSIONS[chapter].get("portrait", "thorgar" if chapter == 0 else "borin"))
	scene.reduced_motion = game.presentation.reduced_motion
	scene.battery = game.presentation.effective_quality == "battery"
	parent.add_child(scene)
	return scene

func _build_chronicle(stack: VBoxContainer) -> void:
	var pane := VBoxContainer.new()
	pane.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pane.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(pane)
	var scroll := ScrollContainer.new()
	scroll.name = "ChapterScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pane.add_child(scroll)
	var chapters := VBoxContainer.new()
	chapters.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chapters.add_theme_constant_override("separation", 12)
	scroll.add_child(chapters)
	var total := 0
	for i in MISSIONS.size():
		var mission: Dictionary = MISSIONS[i]
		var done: bool = game.account.campaign_completed.has(str(mission["id"]))
		var rating: int = int(game.account.campaign_stars.get(str(mission["id"]), 1 if done else 0))
		total += rating
		var card := PanelContainer.new()
		card.name = "ChapterCard%d" % i
		card.add_theme_stylebox_override("panel", Epic.panel(12))
		chapters.add_child(card)
		var column := VBoxContainer.new()
		column.add_theme_constant_override("separation", 7)
		card.add_child(column)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		column.add_child(row)
		var image := TextureRect.new()
		image.texture = CampaignMaps.texture(i)
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		image.custom_minimum_size = Vector2(94, 70)
		row.add_child(image)
		var title := VBoxContainer.new()
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(title)
		_label(title, "%02d • %s" % [i + 1, localized(mission["title"])], 20, true)
		_label(title, "★".repeat(rating) + "☆".repeat(3 - rating), 19, true)
		var available: bool = unlocked(game.account, i)
		_label(column, localized(mission["objective"]) if available else copy("Ukończ poprzedni rozdział, by odkryć dalszą historię.", "Complete the previous chapter to uncover the next part of the story."), 17)
		var button := _button(column, copy("POWTÓRZ", "REPLAY") if done else copy("ROZPOCZNIJ", "BEGIN"), game._start_campaign.bind(i), available)
		button.name = "CampaignMission%d" % i
		button.disabled = not available
		button.custom_minimum_size.y = 54
	_label(pane, copy("Kronika: %d/%d • Gwiazdy: %d/21", "Chronicle: %d/%d • Stars: %d/21") % [game.account.campaign_completed.size(), MISSIONS.size(), total], 17, true)
	# A landscape second page shows the original protagonist artwork.
	portrait_scene = _scene(body, 0)
	portrait_scene.visible = size.x >= 950 and size.x >= size.y * 1.3
	resized.connect(func(): portrait_scene.visible = size.x >= 950 and size.x >= size.y * 1.3)
	_button(stack, copy("WRÓĆ DO MENU", "BACK TO MENU"), game._close_campaign_overlay)

func _build_dialogue(stack: VBoxContainer) -> void:
	var data: Dictionary = MISSIONS[index]
	portrait_scene = _scene(body, index)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 10)
	body.add_child(column)
	_label(column, localized(data["title"]), 24, true)
	var scroll := ScrollContainer.new()
	scroll.name = "DialogueScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var page_column := VBoxContainer.new()
	page_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_column.add_theme_constant_override("separation", 12)
	scroll.add_child(page_column)
	text_label = Label.new()
	text_label.name = "StoryDialogue"
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.add_theme_font_size_override("font_size", 21)
	text_label.add_theme_color_override("font_color", Color("f4e9d3"))
	text_label.add_theme_color_override("font_shadow_color", Color("05030b"))
	text_label.add_theme_constant_override("shadow_offset_y", 2)
	page_column.add_child(text_label)
	var text: String = localized(data[mode]) if mode in ["intro", "mid"] else localized(data["outro"]) if won else copy("Przysięga pozostała niespełniona. Zmień rozstawienie obrony i zachowaj rezerwę złota.", "The oath remains unfulfilled. Reposition your defences and keep gold in reserve.")
	if mode == "result" and won and not game.campaign_choice_pending:
		for choice in data.get("choices", []):
			if game.account.campaign_choices.get(str(data.get("decision", "")), "") == choice["id"]:
				text = localized(choice["ending"])
		text += "\n\n" + copy("Zdobyte EXP: %d", "XP earned: %d") % int(reward.get("gained", 0))
		var rating: int = int(game.account.campaign_stars.get(str(data["id"]), 0))
		text += " • " + "★".repeat(rating) + "☆".repeat(3 - rating)
		if reward.get("status") == "save_failed":
			text += "\n" + copy("Nie udało się zapisać postępu. Sprawdź wolne miejsce na urządzeniu.", "Progress could not be saved. Check free device storage.")
	pages_text = text.split("\n\n", false)
	if pages_text.size() > 1 and pages_text[0].length() < 70 and not ":" in pages_text[0]:
		pages_text[0] += "\n\n" + pages_text[1]
		pages_text.remove_at(1)
	if mode == "intro":
		pages_text.append(localized(data["objective"]) + "\n\n" + _star_goals(data))
	page_label = Label.new()
	page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(page_label)
	advance = _button(stack, "", _advance, true)
	advance.name = "StoryAdvance"
	_update_page()
	if mode == "result" and won and reward.get("status") == "save_failed" and not game.campaign_choice_pending:
		var retry := _button(stack, copy("PONÓW ZAPIS", "RETRY SAVE"), game._retry_campaign_save)
		retry.name = "RetryCampaignSave"
	if mode in ["intro", "mid"] and game.account.campaign_completed.has(str(data["id"])):
		var skip := _button(stack, copy("POMIŃ OBEJRZANY DIALOG", "SKIP SEEN DIALOGUE"), game._close_campaign_overlay)
		skip.name = "SkipSeenStory"
		skip.custom_minimum_size.y = 48
	if mode == "result" and won and game.campaign_choice_pending:
		for choice in data["choices"]:
			_label(page_column, localized(choice["detail"]), 18)
			var button := _button(page_column, localized(choice["label"]), game._choose_campaign_ending.bind(str(choice["id"])), true)
			button.name = "StoryChoice_" + str(choice["id"])
		advance.hide()
		text_label.text = text
		page_label.text = copy("Decyzja zostanie zapisana i wpłynie na dalszą historię.", "Your decision is saved and affects the continuing story.")
		if reward.get("status") == "save_failed":
			page_label.text = copy("Zapis nie powiódł się. Wybierz ponownie po zwolnieniu miejsca.", "Save failed. Free device storage and choose again.")

func _star_goals(data: Dictionary) -> String:
	var third := copy("Ukończ przed ostatnią falą.", "Finish before the last wave.")
	match str(data.get("rule", "")):
		"escort": third = copy("Nie strać żadnej grupy.", "Lose no refugee groups.")
		"debt": third = copy("Wydaj maksymalnie 600 złota.", "Spend at most 600 gold.")
	if index == 0:
		third = copy("Zachowaj co najmniej 1000 złota.", "Keep at least 1000 gold.")
	return copy("★ Wykonaj cel.\n★★ Zachowaj połowę początkowego złota.\n★★★ ", "★ Complete the objective.\n★★ Keep half your starting gold.\n★★★ ") + third

func _update_page() -> void:
	text_label.text = pages_text[page]
	page_label.text = "%d / %d" % [page + 1, pages_text.size()]
	var speaker := "eira" if text_label.text.begins_with("Eira") else "borin" if text_label.text.begins_with("Borin") else str(MISSIONS[index].get("portrait", "thorgar"))
	portrait_scene.show_speaker(speaker)
	advance.text = copy("DALEJ", "NEXT") if page < pages_text.size() - 1 else copy("DO WALKI", "TO BATTLE") if mode == "intro" else copy("KONTYNUUJ", "CONTINUE") if mode == "mid" else copy("WRÓĆ DO KRONIKI", "RETURN TO CHRONICLE")
	Epic._fit_button(advance)
	var scroll := text_label.get_parent().get_parent() as ScrollContainer
	scroll.scroll_vertical = 0

func _advance() -> void:
	if page < pages_text.size() - 1:
		page += 1
		_update_page()
	elif mode == "result":
		game._return_to_campaign()
	else:
		game._close_campaign_overlay()

func _label(parent: Node, value: String, font_size: int, heading: bool = false) -> void:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_shadow_color", Color("05030b"))
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.add_theme_color_override("font_color", Color("f1d397") if heading else Color("e2e0e9"))
	if heading:
		Epic.heading(label, font_size)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(label)

func _button(parent: Node, value: String, handler: Callable, primary: bool = false) -> Button:
	var button := Button.new()
	button.text = value
	button.custom_minimum_size.y = 60
	Epic.button(button, primary, 20)
	parent.add_child(button)
	button.pressed.connect(handler)
	return button
