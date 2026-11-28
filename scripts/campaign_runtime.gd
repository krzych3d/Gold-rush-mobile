extends RefCounted
## Per-battle state. No campaign modifiers ever enter balance_rules.gd.
var mission: Dictionary
var index := -1
var spent := 0
var rescued := 0
var lost := 0
var boss_health := 0.0
var boss_max := 0.0
var boss_defeated := false
var boss_enraged := false
var wave_damage := 0.0
var choices: Dictionary = {}
var artifact_state := "vault"
var rebirths := 0

func _init(mission_index: int, data: Dictionary, saved_choices: Dictionary = {}) -> void:
	index = mission_index
	mission = data
	choices = saved_choices.duplicate()
	boss_max = float(data.get("boss_hp", 0))
	if str(data.get("rule", "")) == "siege":
		boss_max += 80.0 if choices.get("dwarf_refugees", "") == "open" else -60.0 if choices.get("dwarf_refugees", "") == "hidden" else 0.0
	boss_health = boss_max

func rule() -> String:
	return str(mission.get("rule", ""))

func boss_lane(wave: int) -> int:
	return (wave - 1) % 3

func danger_lane(wave: int) -> int:
	if rule() in ["siege", "collapse"] and wave >= 2:
		return (wave - 2) % 3
	return -1

func enemy_multiplier() -> float:
	return 1.0 + minf(0.8, float(spent / 100) * 0.08) if rule() == "debt" else 1.0

func record_spending(amount: int) -> void:
	spent += maxi(0, amount)

func artifact_lane() -> int:
	return clampi(int(mission.get("artifact_lane", 1)), 0, 2)

func take_artifact(unit: Dictionary) -> void:
	if rule() == "heist" and artifact_state == "vault" and int(unit["side"]) == 0 and int(unit["lane"]) == artifact_lane() and int(unit["kind"]) >= 0:
		unit["campaign_artifact"] = true
		artifact_state = "carried"

func try_rebirth(actor: Dictionary, wave: int, guard: bool = false) -> bool:
	if rule() != "undying" or int(actor.get("campaign_rebirth_wave", -1)) == wave:
		return false
	actor["campaign_rebirth_wave"] = wave
	actor["campaign_rising"] = 2.0
	actor["max_health"] = maxf(1.0, float(actor["max_health"]) * 0.60)
	actor["health"] = actor["max_health"]
	actor["hit_time"] = 0.0
	actor["attack_time"] = 0.0
	for event in ["hit", "attack"]:
		actor.erase(event + "_pose_age")
		actor.erase(event + "_pose_duration")
	if guard:
		actor["cooldown"] = maxf(2.0, float(actor.get("cooldown", 0.0)))
		actor["shield"] = 0.0
	else:
		actor["speed"] = float(actor["speed"]) * 0.80
		actor["capacity"] = maxi(1, int(float(actor["capacity"]) * 0.70))
		actor["stunned"] = maxf(2.0, float(actor.get("stunned", 0.0)))
		actor["blocked"] = false
	rebirths += 1
	return true

func prepare(game) -> void:
	if rule() == "siege" and choices.get("dwarf_refugees", "") == "open":
		for path in 3:
			game.guards.append({"side": 0, "lane": path, "position": 0.19, "health": game.GUARD_HP, "max_health": game.GUARD_HP, "shield": 0.0, "cooldown": 0.0})

func begin_wave(game) -> void:
	if rule() == "escort":
		var path: int = boss_lane(game.wave)
		game._spawn(0, path, 1, 0.96)
		var refugee: Dictionary = game.units.back()
		refugee["campaign_refugee"] = true
		refugee["returning"] = true
		refugee["health"] = 110.0
		refugee["max_health"] = 110.0
		refugee["speed"] = 0.024
		refugee["capacity"] = 0
		refugee["stunned"] = 10.0
		# The threatened road is marked during PREP, before the group sets out.
		# These ritual snares also trigger on escorted returning units.
		for slot in 3:
			game.traps[1].append({"lane": path, "kind": 1 if slot == 1 else 0, "slot": slot, "charges": game.Rules.free_units(game.wave) + 2, "cooldown": 0.0, "fire_time": 0.0, "campaign_ritual": true})
	if boss_max > 0.0 and not boss_defeated:
		game._spawn(1, boss_lane(game.wave), 1, 0.02)
		var boss: Dictionary = game.units.back()
		boss["campaign_boss"] = true
		boss["health"] = boss_health
		boss["max_health"] = boss_max
		boss["capacity"] = 90
		boss["speed"] = 0.020
		boss["boss_base_speed"] = 0.020

func tick(game, dt: float) -> void:
	if rule() == "undying":
		for actor in game.units + game.guards:
			if actor.has("campaign_rising"):
				actor["campaign_rising"] = maxf(0.0, float(actor["campaign_rising"]) - dt)
	var danger: int = danger_lane(game.wave)
	for unit in game.units:
		if bool(unit.get("campaign_boss", false)):
			boss_health = maxf(0.0, float(unit["health"]))
			if boss_health <= boss_max * 0.5:
				boss_enraged = true
				unit["speed"] = float(unit["boss_base_speed"]) * 1.35
		if rule() == "collapse" and int(unit["lane"]) == danger and float(unit["position"]) >= 0.0:
			unit["health"] = float(unit["health"]) - 5.0 * dt
	if rule() == "collapse":
		for guard in game.guards:
			if int(guard["lane"]) == danger:
				guard["health"] = float(guard["health"]) - 5.0 * dt

func fallen(unit: Dictionary) -> void:
	if bool(unit.get("campaign_artifact", false)):
		artifact_state = "vault"
	if bool(unit.get("campaign_boss", false)) and not boss_defeated:
		boss_health = 0.0
		boss_defeated = true
	if bool(unit.get("campaign_refugee", false)):
		lost += 1

func returned(unit: Dictionary) -> void:
	if bool(unit.get("campaign_artifact", false)) and int(unit["side"]) == 0:
		artifact_state = "delivered"
	if bool(unit.get("campaign_refugee", false)):
		rescued += 1
	if bool(unit.get("campaign_boss", false)):
		boss_health = maxf(0.0, float(unit["health"]))

func settle(game) -> void:
	# Save surviving boss wounds before the simulator removes timed-out units.
	for unit in game.units:
		if bool(unit.get("campaign_artifact", false)):
			artifact_state = "vault"
		if bool(unit.get("campaign_boss", false)):
			boss_health = maxf(0.0, float(unit["health"]))
		if bool(unit.get("campaign_refugee", false)):
			lost += 1

func victory(delivered: int, wave: int) -> bool:
	match rule():
		"heist": return artifact_state == "delivered"
		"escort": return rescued >= int(mission["target"])
		"boss": return boss_defeated
		"siege", "collapse": return boss_defeated and delivered >= int(mission["target"])
	var target: int = int(mission["target"])
	return delivered >= target if target > 0 else wave >= int(mission["waves"])

func impossible(wave: int) -> bool:
	return rule() == "escort" and rescued + int(mission["waves"]) - wave < int(mission["target"])

func stars(game) -> int:
	var rating := 1
	if int(game.gold[0]) >= int(mission["gold"]) / 2:
		rating += 1
	var optional: bool = game.wave < int(mission["waves"]) if int(mission["target"]) > 0 or boss_max > 0 else int(game.gold[0]) >= 1000
	if rule() == "escort":
		optional = lost == 0
	elif rule() == "debt":
		optional = spent <= 600
	if optional:
		rating += 1
	return rating
