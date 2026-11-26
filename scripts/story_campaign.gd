extends Control
## Dwarven story episodes. UI is modal; simulation is owned by game.gd.
const Epic = preload("res://scripts/epic_theme.gd")
const Battlefields = preload("res://scripts/battlefields.gd")
const CampaignMaps = preload("res://scripts/campaign_maps.gd")
const MobileLayout = preload("res://scripts/mobile_layout.gd")
const L10n = preload("res://scripts/localization.gd")
const MISSIONS = [
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
	"outro": ["W odzyskanym złocie Thorgar słyszy własny głos, choć wciąż żyje.\n\nGłos: Złóż przysięgę, a odzyskasz córkę.\nBorin: Nie słuchaj. To nie Eira.\n\nNa ścianie szybów wyryto cztery herby i piąty, celowo zniszczony. Pod nimi: «Pierwszy dług nie został spłacony».\n\nKoniec dostępnych rozdziałów.", "In the recovered gold, Thorgar hears his own voice, though he is still alive.\n\nVoice: Swear the oath and your daughter will return.\nBorin: Do not listen. That is not Eira.\n\nFour crests are carved into the shaft wall, and a fifth was deliberately destroyed. Below: 'The first debt remains unpaid.'\n\nEnd of available chapters."]}
]
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

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := TextureRect.new()
	bg.texture = CampaignMaps.texture(0 if mode == "menu" else index)
	if bg.texture == null:
		bg.texture = Battlefields.texture("dwarves" if mode == "menu" else str(MISSIONS[index]["map"]))
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.022, 0.045, 0.82)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(margin)
	var safe := MobileLayout.safe_rect(self)
	margin.offset_left = safe.position.x + 16
	margin.offset_top = safe.position.y + 16
	margin.offset_right = safe.end.x - size.x - 16
	margin.offset_bottom = safe.end.y - size.y - 16
	resized.connect(func(): 
		var area := MobileLayout.safe_rect(self)
		margin.offset_left = area.position.x + 16
		margin.offset_top = area.position.y + 16
		margin.offset_right = area.end.x - size.x - 16
		margin.offset_bottom = area.end.y - size.y - 16)
	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override("panel", Epic.panel(18))
	margin.add_child(frame)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 12)
	frame.add_child(stack)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(scroll)
	var pages := VBoxContainer.new()
	pages.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pages.add_theme_constant_override("separation", 16)
	scroll.add_child(pages)
	_label(pages, copy("TESTAMENT UMARŁYCH BOGÓW", "TESTAMENT OF THE DEAD GODS"), 27, true)
	_label(pages, copy("KRASNOLUDY • DZIEDZICTWO KRWI", "DWARVES • LEGACY OF BLOOD"), 21, true)
	if mode == "menu":
		for i in MISSIONS.size():
			var mission: Dictionary = MISSIONS[i]
			var completed: bool = game.account.campaign_completed.has(str(mission["id"]))
			_label(pages, "%02d • %s" % [i + 1, localized(mission["title"])], 24, true)
			_label(pages, localized(mission["objective"]), 19)
			var button := _button(pages, copy("POWTÓRZ", "REPLAY") if completed else copy("ROZPOCZNIJ", "BEGIN"), game._start_campaign.bind(i), true)
			button.name = "CampaignMission%d" % i
			button.disabled = not unlocked(game.account, i)
			if button.disabled:
				_label(pages, copy("Ukończ poprzedni rozdział i odblokuj rasę.", "Finish the previous chapter and unlock the faction."), 17)
		_button(stack, copy("WRÓĆ DO MENU", "BACK TO MENU"), game._close_campaign_overlay)
		return
	var data: Dictionary = MISSIONS[index]
	_label(pages, localized(data["title"]), 26, true)
	if mode == "intro":
		_label(pages, localized(data["intro"]), 21)
		_label(pages, localized(data["objective"]), 20, true)
		_button(stack, copy("DO WALKI", "TO BATTLE"), game._close_campaign_overlay, true)
	elif mode == "mid":
		_label(pages, localized(data["mid"]), 21)
		_button(stack, copy("KONTYNUUJ", "CONTINUE"), game._close_campaign_overlay, true)
	else:
		_label(pages, copy("ZWYCIĘSTWO", "VICTORY") if won else copy("PORAŻKA", "DEFEAT"), 27, true)
		_label(pages, localized(data["outro"]) if won else copy("Przysięga pozostała niespełniona. Spróbuj innej strategii.", "The oath remains unfulfilled. Try a different strategy."), 21)
		if won:
			_label(pages, copy("Zdobyte EXP: %d", "XP earned: %d") % int(reward.get("gained", 0)), 21, true)
			if reward.get("status") == "save_failed":
				_label(pages, copy("Nie udało się zapisać postępu. Powtórz po sprawdzeniu pamięci urządzenia.", "Progress could not be saved. Retry after checking device storage."), 20)
		_button(stack, copy("WRÓĆ DO KRONIKI", "RETURN TO CHRONICLE"), game._return_to_campaign, true)

func _label(parent: Node, value: String, font_size: int, heading: bool = false) -> void:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("f1d397") if heading else Color("e2e0e9"))
	if heading:
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
