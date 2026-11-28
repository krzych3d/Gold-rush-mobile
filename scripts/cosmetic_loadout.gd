extends RefCounted
## Separate atomic cosmetic save. Account progression is never rewritten here.
signal changed
const Skins = preload("res://scripts/unit_skins.gd")
var config_path := "user://wardrobe.cfg"
var selected: Dictionary = {}
var primary_valid := false
var load_failed := false

func _init(path: String = "user://wardrobe.cfg") -> void:
	config_path = path
	primary_valid = _load_file(config_path)
	if not primary_valid:
		var recovered: bool = _load_file(config_path + ".bak")
		load_failed = not recovered and (FileAccess.file_exists(config_path) or FileAccess.file_exists(config_path + ".bak"))

func _load_file(path: String) -> bool:
	var config := ConfigFile.new()
	if config.load(path) != OK or config.get_value("wardrobe", "version", 0) != 1:
		return false
	var value = config.get_value("wardrobe", "selected", {})
	if not value is Dictionary or value.size() > 4:
		return false
	var clean := {}
	for race in value:
		if not race is int or race < 0 or race > 3 or not value[race] is String:
			return false
		# Unknown IDs in an otherwise valid save safely fall back to the original.
		clean[race] = value[race] if Skins.valid_for(value[race], race) else "classic"
	selected = clean
	return true

func equipped(race: int, account) -> String:
	var id: String = selected.get(race, "classic")
	return id if Skins.available(id, race, account) else "classic"

func equip(race: int, id: String, account) -> String:
	if not Skins.available(id, race, account):
		return "locked"
	var previous: Dictionary = selected.duplicate()
	selected[race] = id
	if not _save():
		selected = previous
		return "save_failed"
	changed.emit()
	return "saved"

func _save() -> bool:
	if load_failed:
		return false
	var config := ConfigFile.new()
	config.set_value("wardrobe", "version", 1)
	config.set_value("wardrobe", "selected", selected)
	var pending: String = config_path + ".pending"
	if config.save(pending) != OK:
		return false
	if primary_valid and FileAccess.file_exists(config_path):
		if DirAccess.copy_absolute(config_path, config_path + ".bak") != OK:
			DirAccess.remove_absolute(pending)
			return false
	if DirAccess.rename_absolute(pending, config_path) != OK:
		DirAccess.remove_absolute(pending)
		return false
	primary_valid = true
	return true
