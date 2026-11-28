extends RefCounted
## Text narrator and shared cast metadata. The narrator stays within each POV.
const L10n = preload("res://scripts/localization.gd")
const CAST := {
	"Thorgar": {"portrait": "thorgar", "role": ["dowódca straży, ojciec Eiry", "guard commander, Eira's father"]},
	"Borin": {"portrait": "borin", "role": ["konstruktor, młodszy brat Thorgara", "engineer, Thorgar's younger brother"]},
	"Eira": {"portrait": "eira", "role": ["zmarła córka Thorgara", "Thorgar's deceased daughter"]},
	"Rikk": {"portrait": "rikk", "role": ["złodziej, przyjaciel Nix", "thief, Nix's friend"]},
	"Nix": {"portrait": "nix", "role": ["wynalazczyni, przyjaciółka Rikka", "inventor, Rikk's friend"]}
}

static func localized(pair: Array) -> String:
	return str(pair[0] if L10n.language == "pl" else pair[1])

static func speaker(text: String, race: int) -> Dictionary:
	var line: String = text.get_slice("\n", 0)
	var colon: int = line.find(":")
	if colon > 0 and colon < 35:
		var name: String = line.left(colon)
		if CAST.has(name):
			return {"caption": name.to_upper() + " • " + localized(CAST[name]["role"]), "portrait": CAST[name]["portrait"], "narrator": false}
		if name not in ["Narrator", "Kronikarz"]:
			return {"caption": name.to_upper(), "portrait": "", "narrator": false}
	var perspective: Array = ["kronika goblinów", "goblin chronicle"] if race == 1 else ["kronika krasnoludów", "dwarven chronicle"]
	return {"caption": "NARRATOR • " + localized(perspective), "portrait": "", "narrator": true}

static func cast_notes(race: int) -> String:
	var rows := PackedStringArray()
	for name in (["Rikk", "Nix"] if race == 1 else ["Thorgar", "Borin", "Eira"]):
		rows.append(str(name) + " — " + localized(CAST[name]["role"]))
	return "\n".join(rows)
