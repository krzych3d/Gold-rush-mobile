extends Control
## Dwarven story episodes. UI is modal; simulation is owned by game.gd.
const Epic = preload("res://scripts/epic_theme.gd")
const Battlefields = preload("res://scripts/battlefields.gd")
const CampaignMaps = preload("res://scripts/campaign_maps.gd")
const MobileLayout = preload("res://scripts/mobile_layout.gd")
const L10n = preload("res://scripts/localization.gd")
const Narration = preload("res://scripts/story_narration.gd")
const FIRST_CHAPTERS = [
	{"id": "dwarf_bells", "race": 0, "level": 1, "requires": "", "map": "dwarves", "enemy": 0, "waves": 3, "target": 0, "gold": 1250,
	"title": ["Dzwony dla umarłych", "Bells for the Dead"],
	"objective": ["Przetrwaj 3 fale i ocal własny skarbiec.", "Survive 3 waves and keep your vault alive."],
	"setting": ["Vargheim • noc królewskiego pogrzebu", "Vargheim • the night of the royal funeral"],
	"recap": ["Thorgar Żelazne Serce dowodzi królewską strażą Vargheim. Jego młodszy brat Borin buduje miejskie mechanizmy i naprawia to, co Thorgar potrafi tylko utrzymać siłą. Po śmierci córki Eiry Thorgar wrócił na służbę. Oddał jej imienną monetę do skarbca, jak nakazuje obyczaj. Uwierzył, że zapewnił jej spokój.", "Thorgar Ironheart commands the royal guard of Vargheim. His younger brother Borin builds the city’s mechanisms and repairs what Thorgar can only hold together by force. After his daughter Eira died, Thorgar returned to duty. He gave her name-coin to the vault, as custom requires. He believed he had laid her to rest."],
	"briefing": ["Utrzymaj skarbiec przez trzy fale. Podczas przygotowań wybieraj alejki i rozstawiaj obronę. Darmowe jednostki ruszą każdą linią po rozpoczęciu ataku. Zakupy oraz kradzieże uszczuplają twoje złoto; nie wydawaj ostatnich monet. Po pierwszej fali nadejdą posiłki zmarłych.", "Keep the vault standing for three waves. Select lanes and place defences during preparation. Free units take every lane when the attack begins. Purchases and enemy theft both reduce your gold; keep a reserve. More dead join the assaults after the first wave."],
	"intro": ["""W Vargheim każdy noworodek otrzymuje monetę ze swoim imieniem. Po śmierci moneta wraca do królewskiego skarbca. Kapłani mówią, że przodkowie strzegą w ten sposób potomnych. Tej nocy dołącza do nich król. Na trzech drogach prowadzących do skarbca stoją żałobnicy i straż.

Thorgar: Nad zachodnią wieżą była gwiazda. Pamiętam, jak pokazywałem ją Eirze. Dziś jest tam pustka.
Borin: Tam nigdy nie było gwiazdy, bracie. Chodź. Zaczynają bić dzwony.

Borin: Trzynasty. Nasz mechanizm ma tylko dwanaście dzwonów. Ten dźwięk dochodzi spod kamienia.
Thorgar: Zabezpieczyć trzy drogi. Najpierw odprowadzić rodziny od bram.
Borin: To nie mieszkańcy idą ku nam. Grobowce otwierają się od środka. Wychodzą z nich twoi strażnicy. Ci, których pochowałeś.

Thorgar rozpoznaje pękniętą tarczę człowieka, któremu sam zamknął oczy. Zmarły nie szuka żałobników. Wyciąga dłoń ku skarbcowi, jakby czegoś żądał. Od drzwi królewskiej krypty dobiega ciche brzęknięcie srebra.

Thorgar: Eira nosiła taki dzwoneczek. Zgubiła go przed pogrzebem.
Borin: Nie idź tam sam. Jeśli padnie skarbiec, upadnie ostatnia zamknięta brama między zmarłymi a rodzinami. Utrzymamy ją razem. Potem sprawdzimy, kto dzwoni.""", """In Vargheim, every newborn receives a coin bearing their name. At death, the coin returns to the royal vault. The priests say this lets the ancestors protect their descendants. Tonight the king joins them. Mourners and guards line the three roads to the vault.

Thorgar: There was a star above the western tower. I remember showing it to Eira. Tonight there is nothing.
Borin: There was never a star there, brother. Come. The bells are starting.

Borin: Thirteen. Our mechanism has only twelve bells. That sound is coming from beneath the stone.
Thorgar: Secure all three roads. Get the families away from the gates first.
Borin: Those are not citizens coming towards us. The tombs are opening from within. Your guards are walking out. The ones you buried.

Thorgar recognises the broken shield of a man whose eyes he closed himself. The dead guard ignores the mourners. He reaches towards the vault as though demanding something. A faint silver chime comes from the royal crypt.

Thorgar: Eira wore a little bell like that. It went missing before her funeral.
Borin: You are not going in alone. If the vault falls, so does the last sealed gate between the dead and the families. We hold it together. Then we find out who is ringing."""],
	"mid": ["""Borin: Pierwszy napór minął. Ale groby przy wschodniej drodze też się otwierają. Kolejne fale będą liczniejsze.
Thorgar: Ten z pękniętą tarczą osłonił mnie pod Kamiennym Brodem. Rozkazałem zanieść jego monetę królowi. Dlaczego teraz chce ją odebrać?

Borin: Imię na monecie jest przysięgą. Tak uczono nas w świątyni. A jeśli przysięga nie wygasa po śmierci?
Thorgar: To ktoś właśnie wezwał moich ludzi na kolejną wartę. Nie pozwolę, żeby zapłacili za nią mieszkańcy.

Zza wrót dobiega dziecięcy szept, urwany jak źle złożona modlitwa. Thorgar zostaje na murze. Po raz pierwszy od pogrzebu córki obowiązek każe mu nie odchodzić do jej głosu.""", """Borin: The first assault is over. But the graves beside the eastern road are opening too. More will join the next waves.
Thorgar: The one with the broken shield covered me at Stone Ford. I ordered his coin taken to the king. Why is he trying to take it back?

Borin: The name on the coin is an oath. That is what the temple taught us. What if the oath does not end with death?
Thorgar: Then someone has called my men back for another watch. The families will not pay for it.

A child’s whisper reaches through the gate, cut short like a broken prayer. Thorgar stays on the wall. For the first time since his daughter’s funeral, duty means refusing to follow her voice."""],
	"outro": ["""Trzecia fala ustaje. Bramy wytrzymały. Przy jednej z nich klęczy martwy strażnik. Nie atakuje już. Kładzie pod nogami Thorgara monetę i rozsypuje się w pył. Na złocie wybito imię: Eira.

Thorgar: Sam zaniosłem tę monetę do skarbca po zarazie. Powiedz, że to fałszerstwo.
Borin: Znam rysę na brzegu. Zrobiłem ją, gdy jeszcze bawiła się przy moim stole. To ta sama moneta. Ale data na odwrocie… to jutro.

Eira: Tato, nie oddawaj mnie z powrotem. Tutaj nikt nie śpi. Pod nami oddycha coś większego.
Thorgar: Gdzie jesteś?
Eira: Tam, gdzie kończą się schody, które kazano wam zamurować.

Borin znajduje pęknięcie w pieczęci dawnego szybu. Powietrze wypływa z niego w równych odstępach, ciepłe jak oddech. Thorgar chowa monetę pod zbroją. Miasto jest bezpieczne na tę noc. Jego córka nie była bezpieczna przez żaden z minionych dni.""", """The third wave ends. The gates have held. A dead guard kneels beside one of them. He no longer attacks. He lays a coin at Thorgar’s feet and crumbles to dust. The gold bears a name: Eira.

Thorgar: I took this coin to the vault myself after the plague. Tell me it is a forgery.
Borin: I know that scratch on its edge. I made it when she still played beside my workbench. It is the same coin. But the date on the back… that is tomorrow.

Eira: Father, do not give me back. Nobody sleeps here. Something greater is breathing beneath us.
Thorgar: Where are you?
Eira: Where the stairs end. The ones you were ordered to wall up.

Borin finds a crack in the old shaft’s seal. Warm air escapes at regular intervals, like breath. Thorgar slips the coin beneath his armour. The city is safe for this night. His daughter has not been safe for a single day since her funeral."""]},
	{"id": "dwarf_mountain", "race": 0, "level": 1, "requires": "dwarf_bells", "map": "void", "enemy": 3, "waves": 4, "target": 180, "gold": 1400,
	"title": ["Góra, która oddycha", "The Breathing Mountain"],
	"objective": ["Dostarcz 180 złota pamięci do skarbca w maks. 4 falach. Zachowaj własny skarbiec.", "Deliver 180 memory gold to your vault within 4 waves. Keep your vault alive."],
	"setting": ["Zapieczętowany szyb • pod Vargheim", "The sealed shaft • beneath Vargheim"],
	"recap": ["Bramy Vargheim przetrwały pogrzeb. Zmarły strażnik zwrócił Thorgarowi monetę Eiry, z której przemówiła jego córka. Moneta wskazuje jutro, a głos prowadzi do zamkniętego szybu. Thorgar niesie ją przy sobie. Borin schodzi z nim, zanim kapłani zdążą odnowić pieczęcie.", "Vargheim’s gates survived the funeral. A dead guard returned Eira’s coin, and Thorgar heard his daughter speak from it. The coin bears tomorrow’s date; her voice leads to a sealed shaft. Thorgar keeps it with him. Borin follows him down before the priests can renew the seals."],
	"briefing": ["Dostarcz do własnego skarbca 180 złota pamięci w najwyżej czterech falach. Samo zabranie złota przeciwnikowi nie wystarczy: najeźdźcy muszą bezpiecznie wrócić. Odsetki nie wypełniają celu. Fioletowa szczelina spowalnia obie armie o 45% i zmienia linię co falę.", "Deliver 180 memory gold to your own vault within four waves. Taking it from the enemy is not enough: your raiders must return safely. Interest does not count towards the objective. The violet fissure slows both armies by 45% and changes lane each wave."],
	"intro": ["""Pod ulicami kończą się ślady dłut. Ściany stają się gładkie i wygięte; w pęknięciach lśni złoto. Krasnoludzkie pieśni opowiadają o bogu, który chciał pożreć słońce. Przodkowie mieli go zabić i wznieść na jego szczątkach miasto. Dotąd Borin uważał tę opowieść za przypowieść o dobrych fundamentach.

Borin: To nie podpory. Stoimy między żebrami. A te miechy nie tłoczą powietrza do kuźni. Odbierają je czemuś pod nami.
Thorgar: Eira miała tu spoczywać pod opieką przodków. Dlaczego zamknęli do niej drogę?

Eira: Moja moneta jest z tobą, ale głos ma korzenie tutaj. Zabierzcie złoto z tamtych komór. Dopóki zasila pieczęć, nie usłyszycie, co zrobili pozostałym.
Borin: Złoto pamięta dotyk i słowa. Jeśli wrócimy z nim do naszego skarbca, odczytam zapis poza ich pieczęcią.

Z mroku wychodzą istoty spowite fioletowym światłem. Nie noszą królewskich znaków. Strzegą komór, jakby złoto było czymś, czego żywi nie powinni dotykać. Borin nie zna ich rozkazów. Thorgar nie ma czasu o nie pytać.

Borin: Góra nabiera powietrza. Fioletowa szczelina ściska jedną drogę; spowolni naszych i strażników komór. Po każdej fali oddech przeniesie się dalej. Musimy wrócić z pamięcią, nie tylko wyrwać ją z cudzego skarbca.""", """Beneath the streets, the chisel marks end. The walls grow smooth and curved; gold shines in their cracks. Dwarven songs tell of a god that tried to devour the sun. The ancestors supposedly killed it and built their city upon its remains. Until now, Borin thought this was a parable about sound foundations.

Borin: These are not supports. We are standing between ribs. Those bellows are not feeding a forge. They are drawing air out of something beneath us.
Thorgar: Eira was meant to rest under the ancestors’ protection. Why did they seal the road to her?

Eira: My coin is with you, but my voice is rooted here. Take the gold from those chambers. While it feeds their seal, you cannot hear what they did to the others.
Borin: Gold remembers touch and speech. Bring it to our vault and I can read it beyond their seal.

Figures wrapped in violet light emerge from the dark. They bear no royal insignia. They guard the chambers as though the gold is something the living must never touch. Borin does not know their orders. Thorgar has no time to ask.

Borin: The mountain is drawing breath. The violet fissure constricts one road; it slows our people and the chamber guards alike. After each wave the breath moves on. We need the memory brought home, not merely stolen from the far vault."""],
	"mid": ["""Borin: Posłuchaj tych monet. Każda kończy zdanie tam, gdzie zaczyna następna. To księga rozbita na tysiące głosów.
Eira: Przewracają nas w piecach. Kiedy zapominamy imiona, złoto staje się ciche. Wtedy wydają je żywym.

Borin: Odsetki. Całe życie myślałem, że król dzieli się wydobyciem. To nie góra rodzi nowe bogactwo. To kapłani zużywają pamięć zmarłych.
Thorgar: Sam zanosiłem im monety poległych. Po każdej bitwie dziękowali mi za służbę.

Eira: Nie tylko po bitwach, tato.
Thorgar zaciska dłoń na jej monecie. Przypomina sobie dzień po zarazie. Tymczasem oddech góry przesuwa fioletową szczelinę na następną linię.""", """Borin: Listen to these coins. Each finishes a sentence where the next begins. This is a book broken into thousands of voices.
Eira: They turn us over in the furnaces. When we forget our names, the gold falls silent. Then they spend it among the living.

Borin: Interest. All my life I thought the king was sharing the mine’s yield. The mountain is not making new wealth. The priests are consuming the memory of the dead.
Thorgar: I brought them the fallen soldiers’ coins myself. After every battle they thanked me for my service.

Eira: Not only after battles, Father.
Thorgar closes his hand around her coin. He remembers the day after the plague. Meanwhile the mountain’s breath moves the violet fissure to the next lane."""],
	"outro": ["""Borin układa odzyskane monety poza pieczęcią komór. Przez chwilę słychać zwyczajny poranek: kobietę wołającą na śniadanie, skrzypienie drzwi, dziecko pytające o pogodę. Potem trzask ognia. Żaden zapis nie kończy się ciszą.

Borin: Oni wciąż tam są. A w żyle pod stopami nie ma zwykłej rudy. Jeśli pieśń mówiła prawdę o ciele boga, złoto jest tym, co zostało z jego krwi.
Thorgar: Kto wiedział?
Borin: Sprawdźmy mennicę. Każda moneta ma tam swój odpis i podpis tego, kto ją przyjął.

Głos: Złóż nową przysięgę, Thorgarze. Oddam ci córkę.
To jego własny głos, wydobywający się z metalu. Borin odsuwa monetę od ucha brata. Eira milczy.

Przy wyjściu odkrywają cztery herby i miejsce po piątym, starannie skute. Poniżej ocalało zdanie: «Pierwszy dług nie został spłacony». Thorgar zabiera odłamek do mennicy. Po raz pierwszy chce sprawdzić dokument, pod którym kiedyś tylko stawiał podpis.""", """Borin lays the recovered coins beyond the chambers’ seal. For a moment they hear an ordinary morning: a woman calling everyone to breakfast, a creaking door, a child asking about the weather. Then the crack of fire. No recording ends in silence.

Borin: They are still in there. And the seam beneath our feet is no ordinary ore. If the song told the truth about the god’s body, gold is what remains of its blood.
Thorgar: Who knew?
Borin: Let us check the mint. It keeps a copy of every name-coin and the signature of whoever received it.

Voice: Swear a new oath, Thorgar. I will give you your daughter back.
It is his own voice, coming from the metal. Borin pulls the coin away from his brother’s ear. Eira is silent.

At the exit they find four crests and the space where a fifth was carefully chiselled away. One sentence survives below: ‘The first debt remains unpaid.’ Thorgar takes a fragment to the mint. For the first time he wants to read a document he once merely signed."""]}
]
const MISSIONS = FIRST_CHAPTERS + preload("res://scripts/dwarf_chapters.gd").MISSIONS + preload("res://scripts/goblin_chapters.gd").MISSIONS
var game
var mode := "menu"
var index := 0
var won := false
var reward: Dictionary = {}

static func copy(pl: String, en: String) -> String:
	return pl if L10n.language == "pl" else en

static func localized(pair: Array) -> String:
	return str(pair[0] if L10n.language == "pl" else pair[1])

static func campaign_name(race: int) -> String:
	return copy("GOBLINY • ZŁODZIEJE PRZEZNACZENIA", "GOBLINS • THIEVES OF FATE") if race == 1 else copy("KRASNOLUDY • DZIEDZICTWO KRWI", "DWARVES • LEGACY OF BLOOD")

static func chapter_number(mission_index: int) -> int:
	var number := 0
	for i in range(mission_index + 1):
		if MISSIONS[i]["race"] == MISSIONS[mission_index]["race"]: number += 1
	return number

static func index_for_id(id: String) -> int:
	for i in MISSIONS.size():
		if str(MISSIONS[i]["id"]) == id: return i
	return -1

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
var speaker_label: Label
var advance: Button
var previous: Button
var choices_box: VBoxContainer
var context_button: Button
var context_open := false
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
	_label(stack, copy("KRONIKI RAS • WYBIERZ OPOWIEŚĆ", "RACIAL CHRONICLES • CHOOSE A STORY") if mode == "menu" else campaign_name(int(MISSIONS[index]["race"])), 17, true)
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
		portrait_scene.custom_minimum_size = Vector2(0, minf(300, size.y * 0.25)) if body.vertical else Vector2(size.x * 0.34, 0)
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
	var completed := 0
	var previous_race := -1
	for i in MISSIONS.size():
		var mission: Dictionary = MISSIONS[i]
		var race: int = int(mission["race"])
		if race != previous_race:
			_label(chapters, campaign_name(race), 20, true)
			previous_race = race
		var done: bool = game.account.campaign_completed.has(str(mission["id"]))
		if done: completed += 1
		var available: bool = unlocked(game.account, i)
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
		image.custom_minimum_size = Vector2(144, 100)
		row.add_child(image)
		var title := VBoxContainer.new()
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(title)
		_label(title, "%02d • %s" % [chapter_number(i), localized(mission["title"])], 20, true)
		_label(title, "★".repeat(rating) + "☆".repeat(3 - rating), 19, true)
		if available:
			_label(title, localized(mission["setting"]), 16)
		_label(column, localized(mission["objective"]) if available else copy("Ukończ poprzedni rozdział, by odkryć dalszą historię.", "Complete the previous chapter to uncover the next part of the story."), 17)
		var button := _button(column, copy("POWTÓRZ", "REPLAY") if done else copy("ROZPOCZNIJ", "BEGIN"), game._start_campaign.bind(i), available)
		button.name = "CampaignMission%d" % i
		button.disabled = not available
		button.custom_minimum_size.y = 54
	_label(pane, copy("Kronika: %d/%d • Gwiazdy: %d/%d", "Chronicle: %d/%d • Stars: %d/%d") % [completed, MISSIONS.size(), total, MISSIONS.size() * 3], 17, true)
	# A landscape second page shows the original protagonist artwork.
	portrait_scene = _scene(body, 0)
	portrait_scene.visible = size.x >= 950 and size.x >= size.y * 1.3
	resized.connect(func(): portrait_scene.visible = size.x >= 950 and size.x >= size.y * 1.3)
	_button(stack, copy("WRÓĆ DO MENU", "BACK TO MENU"), game._close_campaign_overlay)

func _build_dialogue(stack: VBoxContainer) -> void:
	var data: Dictionary = MISSIONS[index]
	portrait_scene = _scene(body, index)
	var panel := PanelContainer.new()
	panel.name = "StoryReadingPanel"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", Epic.panel(20))
	body.add_child(panel)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 10)
	panel.add_child(column)
	_label(column, localized(data["title"]), 24, true)
	var setting := Label.new()
	setting.name = "StorySetting"
	setting.text = localized(data["setting"])
	setting.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	setting.add_theme_font_size_override("font_size", 16)
	setting.add_theme_color_override("font_color", Color("c9c4b9"))
	column.add_child(setting)
	speaker_label = Label.new()
	speaker_label.name = "StorySpeaker"
	speaker_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	speaker_label.add_theme_font_size_override("font_size", 17)
	speaker_label.add_theme_color_override("font_color", Color("f1d397"))
	column.add_child(speaker_label)
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
	if mode == "intro":
		pages_text.insert(0, copy("ZANIM RUSZYSZ DALEJ\n", "BEFORE YOU CONTINUE\n") + _recap_text(data))
		pages_text.append(copy("ODPRAWA\n", "BRIEFING\n") + localized(data["briefing"]) + "\n\n" + localized(data["objective"]) + "\n\n" + _star_goals(data))
	var reading_tools := HBoxContainer.new()
	reading_tools.add_theme_constant_override("separation", 8)
	column.add_child(reading_tools)
	page_label = Label.new()
	page_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reading_tools.add_child(page_label)
	context_button = _button(reading_tools, copy("KONTEKST", "CONTEXT"), _toggle_context)
	context_button.name = "StoryContext"
	context_button.custom_minimum_size = Vector2(148, 44)
	var navigation := HBoxContainer.new()
	navigation.name = "StoryNavigation"
	navigation.add_theme_constant_override("separation", 12)
	stack.add_child(navigation)
	previous = _button(navigation, copy("WCZEŚNIEJ", "PREVIOUS"), _previous)
	previous.name = "StoryPrevious"
	previous.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	advance = _button(navigation, "", _advance, true)
	advance.name = "StoryAdvance"
	advance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if mode == "result" and won and reward.get("status") == "save_failed" and not game.campaign_choice_pending:
		var retry := _button(stack, copy("PONÓW ZAPIS", "RETRY SAVE"), game._retry_campaign_save)
		retry.name = "RetryCampaignSave"
	if mode in ["intro", "mid"] and game.account.campaign_completed.has(str(data["id"])):
		var skip := _button(stack, copy("POMIŃ OBEJRZANY DIALOG", "SKIP SEEN DIALOGUE"), game._close_campaign_overlay)
		skip.name = "SkipSeenStory"
		skip.custom_minimum_size.y = 48
	if mode == "result" and won and game.campaign_choice_pending:
		choices_box = VBoxContainer.new()
		choices_box.name = "StoryDecisions"
		choices_box.add_theme_constant_override("separation", 12)
		page_column.add_child(choices_box)
		_label(choices_box, copy("Wybór zostanie zapisany i wpłynie na dalszą historię. Powtórzenie misji go nie zmieni.", "Your choice is saved and affects the continuing story. Replaying this mission cannot change it."), 18)
		for choice in data["choices"]:
			_label(choices_box, localized(choice["detail"]), 18)
			var button := _button(choices_box, localized(choice["label"]), game._choose_campaign_ending.bind(str(choice["id"])), true)
			button.name = "StoryChoice_" + str(choice["id"])
		if reward.get("status") == "save_failed":
			_label(choices_box, copy("Zapis nie powiódł się. Wybierz ponownie po zwolnieniu miejsca.", "Save failed. Free device storage and choose again."), 18)
	_update_page()

func _star_goals(data: Dictionary) -> String:
	var third := copy("Ukończ przed ostatnią falą.", "Finish before the last wave.")
	match str(data.get("rule", "")):
		"escort": third = copy("Nie strać żadnej grupy.", "Lose no refugee groups.")
		"debt": third = copy("Wydaj maksymalnie 600 złota.", "Spend at most 600 gold.")
	if int(data["target"]) == 0 and int(data.get("boss_hp", 0)) == 0:
		third = copy("Zachowaj co najmniej 1000 złota.", "Keep at least 1000 gold.")
	return copy("★ Wykonaj cel.\n★★ Zachowaj połowę początkowego złota.\n★★★ ", "★ Complete the objective.\n★★ Keep half your starting gold.\n★★★ ") + third

func _update_page() -> void:
	var data: Dictionary = MISSIONS[index]
	if context_open:
		text_label.text = copy("PUNKT WYJŚCIA\n", "THE STORY SO FAR\n") + _recap_text(data) + copy("\n\nPOSTACIE\n", "\n\nCHARACTERS\n") + Narration.cast_notes(int(data["race"]))
		speaker_label.text = copy("NARRATOR • PRZYPOMNIENIE HISTORII", "NARRATOR • STORY CONTEXT")
		portrait_scene.show_speaker("")
		page_label.text = copy("Kontekst • strona %d / %d", "Context • page %d / %d") % [page + 1, pages_text.size()]
		previous.disabled = true
		advance.show()
		advance.text = copy("WRÓĆ DO DIALOGU", "RETURN TO THE SCENE")
		context_button.text = copy("WRÓĆ", "RETURN")
		Epic._fit_button(advance)
		Epic._fit_button(context_button)
		if choices_box != null: choices_box.hide()
		call_deferred("_reset_dialogue_scroll")
		return
	context_button.text = copy("KONTEKST", "CONTEXT")
	Epic._fit_button(context_button)
	text_label.text = pages_text[page]
	page_label.text = "%d / %d" % [page + 1, pages_text.size()]
	var speaker: Dictionary = Narration.speaker(text_label.text, int(data["race"]))
	speaker_label.text = str(speaker["caption"])
	if mode == "intro" and page == pages_text.size() - 1:
		speaker_label.text = copy("ODPRAWA • CEL I ZASADY MISJI", "BRIEFING • OBJECTIVE AND MISSION RULES")
	portrait_scene.show_speaker(str(speaker["portrait"]))
	previous.disabled = page == 0
	var decision_page: bool = choices_box != null and page == pages_text.size() - 1
	if choices_box != null:
		choices_box.visible = decision_page
	advance.visible = not decision_page
	advance.text = copy("DALEJ", "NEXT") if page < pages_text.size() - 1 else copy("DO WALKI", "TO BATTLE") if mode == "intro" else copy("KONTYNUUJ", "CONTINUE") if mode == "mid" else copy("WRÓĆ DO KRONIKI", "RETURN TO CHRONICLE")
	Epic._fit_button(advance)
	var scroll := text_label.get_parent().get_parent() as ScrollContainer
	scroll.scroll_vertical = 0
	call_deferred("_reset_dialogue_scroll")

func _reset_dialogue_scroll() -> void:
	var scroll := text_label.get_parent().get_parent() as ScrollContainer
	scroll.scroll_vertical = 0

func _previous() -> void:
	if page > 0 and not context_open:
		page -= 1
		_update_page()

func _advance() -> void:
	if context_open:
		context_open = false
		_update_page()
		return
	if choices_box != null and page == pages_text.size() - 1:
		return # A required decision can only finish through its actual choice.
	if page < pages_text.size() - 1:
		page += 1
		_update_page()
	elif mode == "result":
		game._return_to_campaign()
	else:
		game._close_campaign_overlay()

func _toggle_context() -> void:
	context_open = not context_open
	_update_page()

func _recap_text(data: Dictionary) -> String:
	var recap: String = localized(data["recap"])
	if str(data["id"]) == "dwarf_throne":
		var choice: String = str(game.account.campaign_choices.get("dwarf_refugees", ""))
		if choice == "open":
			recap += "\n\n" + copy("Otworzyłeś bramy: uratowani strażnicy przysłali trzech obrońców, lecz twierdza zdążyła wzmocnić króla.", "You opened the gates: rescued guards sent three defenders, but the fortress had time to strengthen the king.")
		elif choice == "hidden":
			recap += "\n\n" + copy("Ukryłeś rodziny: Borin przeprowadził je bez ostrzegania twierdzy. Król ma mniej sił, ale brak dodatkowych obrońców.", "You hid the families: Borin moved them without warning the fortress. The king is weaker, but you have no extra defenders.")
	return recap

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
