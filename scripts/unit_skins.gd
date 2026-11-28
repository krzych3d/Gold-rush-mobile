extends RefCounted
## Cosmetic data only. Never read by prices, AI, damage or the simulation clock.
const L10n = preload("res://scripts/localization.gd")
const ROOT := "res://assets/epic/skins/"
const SKINS := [
	{"id": "classic", "races": [0, 1, 2, 3], "name": ["Dziedzictwo", "Legacy"], "lore": ["Tradycyjne stroje i barwy twojej armii.", "Your army’s traditional costumes and colours."], "type": ["Zestaw podstawowy", "Original costumes"]},
	{"id": "royal_oath", "races": [0], "name": ["Królewska przysięga", "Royal Oath"], "lore": ["Karmazynowe płaszcze straży Vargheim. Thorgar nosił te barwy, zanim usłyszał głos z monety Eiry.", "The crimson cloaks of Vargheim’s guard. Thorgar wore these colours before he heard a voice from Eira’s coin."], "type": ["Nowe stroje • 3 postacie", "New costumes • 3 characters"]},
	{"id": "restless", "races": [0], "mission": "dwarf_bells", "name": ["Niespokojni przodkowie", "Restless Ancestors"], "lore": ["Ci sami strażnicy. Ta sama przysięga. Śmierć nie zwolniła ich ze służby. Widmowy rycerz i eteryczna eskorta skarbca.", "The same guards. The same oath. Death did not release them from service. A spectral knight and an ethereal vault escort."], "type": ["Widmowy rycerz • efekty całej armii", "Spectral knight • army-wide effects"]},
	{"id": "mintbound", "races": [0], "mission": "dwarf_coin", "name": ["Dłużnicy mennicy", "Mintbound"], "lore": ["Złoty pył wnika w królewskie zbroje. Każdy wydany pieniądz zostawia na nich kolejny ślad długu.", "Gold dust settles into royal armour. Every coin spent leaves another trace of debt."], "type": ["Królewskie stroje • barwy mennicy", "Royal costumes • mint colours"]},
	{"id": "threadkeepers", "races": [1], "mission": "goblin_contract", "name": ["Złodzieje nici", "Thread Thieves"], "lore": ["Morskie płaszcze, skórzane sakwy i znaki utkane złotą nicią. Ludzie Rikka kradną to, czego nie da się zamknąć w skarbcu.", "Teal cloaks, leather satchels and gold-thread signs. Rikk’s crew steal things no vault can hold."], "type": ["Nowe stroje • 2 postacie", "New costumes • 2 characters"]},
	{"id": "threadbare", "races": [1], "mission": "goblin_funeral", "name": ["Ci, których śmierć minęła", "Those Death Passed By"], "lore": ["Barwy złodziei bledną po powrocie. W Mieście bez pogrzebów kolejny oddech nie zawsze jest darem.", "The thieves’ colours fade after their return. In the City Without Funerals, another breath is not always a gift."], "type": ["Stroje złodziei • barwy powrotu", "Thief costumes • revenant colours"]},
	{"id": "moonwake", "races": [2], "name": ["Czuwanie Białego Gaju", "White Grove Vigil"], "lore": ["Chłodne barwy nocnego obrzędu. Przodkowie słyszą tych, którzy nie odwracają wzroku od ciemności.", "The cool colours of the night rite. Ancestors hear those who do not turn away from the dark."], "type": ["Wariant kolorystyczny", "Colour variant"]},
	{"id": "black_sun", "races": [3], "name": ["Czarne słońce", "Black Sun"], "lore": ["Przygaszone barwy strażników bram. Ich światło przypomina słońce, którego nikt z żywych nie pamięta.", "The muted colours of the gatekeepers. Their light recalls a sun no living being remembers."], "type": ["Wariant kolorystyczny", "Colour variant"]},
	{"id": "forgotten", "races": [3], "mission": "dwarf_oath", "name": ["Ślad zapomnianych", "Trace of the Forgotten"], "lore": ["Postacie na granicy pamięci. Pozostały po nich głosy, choć z kamienia skuto ich imiona.", "Figures at the edge of memory. Their voices remain, though their names were chiselled from the stone."], "type": ["Wariant widmowy", "Spectral variant"]}
]
const ROYAL := {"dwarf_defender": "royal_defender.png", "dwarf_carrier": "royal_carrier.png", "arcane_mage": "royal_runekeeper.png"}
const THREADS := {"goblin_raider": "thread_raider.png", "goblin_saboteur": "thread_saboteur.png"}
const MISSION_NAMES := {
	"dwarf_bells": ["Dzwony dla umarłych", "Bells for the Dead"],
	"dwarf_coin": ["Cena jednej monety", "The Price of a Coin"],
	"dwarf_oath": ["Ostatnia przysięga", "The Last Oath"],
	"goblin_contract": ["Zlecenie od nieznajomej", "A Stranger’s Contract"],
	"goblin_funeral": ["Miasto bez pogrzebów", "City Without Funerals"]
}

static func text(pair: Array) -> String:
	return str(pair[0] if L10n.language == "pl" else pair[1])

static func data(id: String) -> Dictionary:
	for skin in SKINS:
		if skin["id"] == id:
			return skin
	return SKINS[0]

static func valid_for(id: String, race: int) -> bool:
	return data(id)["id"] == id and race in data(id)["races"]

static func available(id: String, race: int, account) -> bool:
	if not valid_for(id, race) or not account.race_unlocked(race):
		return false
	var mission: String = data(id).get("mission", "")
	return mission.is_empty() or mission in account.campaign_completed

static func requirement(id: String, race: int, account) -> String:
	if not account.race_unlocked(race):
		return text(["Poziom konta %d", "Account level %d"]) % account.UNLOCK_LEVELS[clampi(race, 0, 3)]
	var mission: String = data(id).get("mission", "")
	if not mission.is_empty() and mission not in account.campaign_completed:
		return text(["Ukończ: %s", "Complete: %s"]) % text(MISSION_NAMES[mission])
	return text(["Dostępna", "Available"])

static func for_race(race: int) -> Array:
	return SKINS.filter(func(skin): return race in skin["races"])

static func reward_for(mission: String) -> String:
	for skin in SKINS:
		if skin.get("mission", "") == mission:
			return str(skin["id"])
	return ""

static func path(id: String, key: String) -> String:
	if id == "restless" and key == "dwarf_defender":
		return ROOT + "ancestor_defender.png"
	var files: Dictionary = ROYAL if id in ["royal_oath", "restless", "mintbound"] else THREADS if id in ["threadkeepers", "threadbare"] else {}
	return ROOT + str(files[key]) if files.has(key) else ""

static func tint(id: String, key: String = "") -> Color:
	match id:
		"restless": return Color(0.83, 1.0, 1.0, 0.80) if key == "dwarf_defender" else Color(0.57, 1.05, 1.40, 0.69)
		"mintbound": return Color(1.20, 1.02, 0.66)
		"threadbare": return Color(0.68, 0.88, 0.96, 0.88)
		"moonwake": return Color(0.76, 1.03, 1.20)
		"black_sun": return Color(1.08, 0.78, 0.62)
		"forgotten": return Color(0.57, 1.04, 1.25, 0.70)
	return Color.WHITE

static func spectral(id: String) -> bool:
	return id in ["restless", "forgotten"]

static func campaign_skin(index: int, side: int, risen: bool = false) -> String:
	# Story costumes override a loadout for the scene only; they never equip it.
	match index:
		0, 3: return "royal_oath" if side == 0 else "restless"
		1, 6: return "royal_oath" if side == 0 else "forgotten"
		2: return "royal_oath" if side == 0 else "mintbound"
		4: return "mintbound" if side == 0 else "royal_oath"
		5: return "royal_oath" if side == 0 else "restless"
		7: return "threadkeepers" if side == 0 else "royal_oath"
		8: return "threadbare" if risen else "threadkeepers"
	return "classic"

static func draw_frame(canvas: CanvasItem, texture: Texture2D, destination: Rect2, region: Rect2, id: String, key: String, settings, clock: float, fade: float = 1.0) -> void:
	var colour: Color = tint(id, key)
	colour.a *= fade
	# One optional extra quad. No nodes, particles, shaders, random numbers or timers.
	if spectral(id) and not settings.reduced_motion and settings.effective_quality != "battery":
		var echo := Color(0.41, 0.94, 1.0, 0.10 * fade)
		var offset := Vector2(-destination.size.x * 0.026, -destination.size.y * 0.012 * sin(clock * 2.0))
		canvas.draw_texture_rect_region(texture, Rect2(destination.position + offset, destination.size), region, echo)
	canvas.draw_texture_rect_region(texture, destination, region, colour)
