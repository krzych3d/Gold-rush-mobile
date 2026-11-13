extends RefCounted
## Device-local account progression; battle stats never depend on account level.
signal changed
const MAX_LEVEL := 20
const UNLOCK_LEVELS := [1, 1, 5, 10]
const MATCH_WIN_XP := 50
const MATCH_LOSS_XP := 25
const WAVE_XP := 20
const MAX_REWARDED_WAVES := 20
const HISTORY_LIMIT := 64
var config_path := "user://account_progress.cfg"
var total_xp := 0
var claimed_matches := PackedStringArray()
var primary_valid := false
var load_failed := false

func _init(path: String = "user://account_progress.cfg") -> void:
	config_path = path
	primary_valid = _load_file(config_path)
	if not primary_valid:
		var restored: bool = _load_file(config_path + ".bak")
		# Preserve unreadable saves instead of silently replacing progress with zero.
		load_failed = not restored and (FileAccess.file_exists(config_path) or FileAccess.file_exists(config_path + ".bak"))

static func xp_for_level(value: int) -> int:
	var steps: int = clampi(value, 1, MAX_LEVEL) - 1
	return steps * 100 + 25 * steps * (steps - 1)

func level() -> int:
	return level_for_xp(total_xp)

static func level_for_xp(amount: int) -> int:
	var current := 1
	while current < MAX_LEVEL and amount >= xp_for_level(current + 1):
		current += 1
	return current

func xp_in_level() -> int:
	return total_xp - xp_for_level(level())

func xp_needed() -> int:
	return 0 if level() == MAX_LEVEL else xp_for_level(level() + 1) - xp_for_level(level())

func race_unlocked(race: int) -> bool:
	return race >= 0 and race < UNLOCK_LEVELS.size() and level() >= UNLOCK_LEVELS[race]

static func recovery_code_for_xp(amount: int) -> String:
	var value: int = clampi(amount, 0, xp_for_level(MAX_LEVEL))
	var checksum: String = ("vault-wars-v1|" + str(value)).sha256_text().substr(0, 8).to_upper()
	return "VW1-%d-%s" % [value, checksum]

func recovery_code() -> String:
	return recovery_code_for_xp(total_xp)

func restore_recovery_code(code: String) -> String:
	# This local code detects typing mistakes; it is not online authentication.
	var parts := code.strip_edges().to_upper().split("-")
	if parts.size() != 3 or parts[0] != "VW1" or parts[1].length() > 5 or not parts[1].is_valid_int():
		return "invalid"
	var value: int = parts[1].to_int()
	if value < 0 or value > xp_for_level(MAX_LEVEL) or recovery_code_for_xp(value) != code.strip_edges().to_upper():
		return "invalid"
	if value <= total_xp:
		return "unchanged"
	var previous: int = total_xp
	total_xp = value
	if not _save():
		total_xp = previous
		return "save_failed"
	changed.emit()
	return "saved"

func _load_file(path: String) -> bool:
	var config := ConfigFile.new()
	if config.load(path) != OK or config.get_value("account", "version", 0) != 1:
		return false
	var value = config.get_value("account", "total_xp", -1)
	var history = config.get_value("account", "claimed_matches", PackedStringArray())
	if not value is int or value < 0 or value > xp_for_level(MAX_LEVEL):
		return false
	if not history is PackedStringArray or history.size() > HISTORY_LIMIT:
		return false
	for match_id in history:
		if match_id.is_empty() or match_id.length() > 128:
			return false
	total_xp = value
	claimed_matches = history
	return true

func _save() -> bool:
	if load_failed:
		return false
	var config := ConfigFile.new()
	config.set_value("account", "version", 1)
	config.set_value("account", "total_xp", total_xp)
	config.set_value("account", "claimed_matches", claimed_matches)
	var temporary: String = config_path + ".pending"
	if config.save(temporary) != OK:
		return false
	if primary_valid and FileAccess.file_exists(config_path):
		if DirAccess.copy_absolute(config_path, config_path + ".bak") != OK:
			DirAccess.remove_absolute(temporary)
			return false
	# Rename on the same filesystem prevents a partially written primary save.
	if DirAccess.rename_absolute(temporary, config_path) != OK:
		DirAccess.remove_absolute(temporary)
		return false
	primary_valid = true
	return true

func claim_match(match_id: String, victory: bool, finished_waves: int, battle_seconds: float) -> Dictionary:
	var before: int = level()
	var result := {"gained": 0, "before_level": before, "level": before, "before_xp": total_xp, "after_xp": total_xp, "unlocked": [], "status": "ineligible"}
	if match_id.is_empty() or match_id.length() > 128 or finished_waves < 1 or battle_seconds <= 0.0:
		return result
	if claimed_matches.has(match_id):
		result["status"] = "already_claimed"
		return result
	var old_xp: int = total_xp
	var old_history: PackedStringArray = claimed_matches.duplicate()
	var earned: int = (MATCH_WIN_XP if victory else MATCH_LOSS_XP) + WAVE_XP * clampi(finished_waves, 0, MAX_REWARDED_WAVES)
	total_xp = mini(xp_for_level(MAX_LEVEL), total_xp + earned)
	claimed_matches.append(match_id)
	while claimed_matches.size() > HISTORY_LIMIT:
		claimed_matches.remove_at(0)
	if not _save():
		total_xp = old_xp
		claimed_matches = old_history
		result["status"] = "save_failed"
		return result
	result["status"] = "saved"
	result["gained"] = total_xp - old_xp
	result["earned"] = earned
	result["level"] = level()
	result["before_xp"] = old_xp
	result["after_xp"] = total_xp
	result["match_id"] = match_id
	for race in UNLOCK_LEVELS.size():
		if UNLOCK_LEVELS[race] > before and UNLOCK_LEVELS[race] <= level():
			result["unlocked"].append(race)
	changed.emit()
	return result
