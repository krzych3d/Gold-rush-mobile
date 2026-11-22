extends SceneTree
## Exercises the shipping simulator at its real 20 Hz. No proxy combat model.
const Game = preload("res://scripts/game.gd")
const STRATEGIES := ["save", "bank", "training", "rush", "carriers", "saboteurs", "spikes", "turrets", "guards", "mixed", "adaptive"]
var matches: Array = []
var timed_out := 0
var game

func _initialize() -> void:
	call_deferred("run")

func reset(race_a: int, race_b: int, seed_value: int) -> void:
	game.selected_race = race_a
	game.bot_race = race_b
	game.phase = "PREP"
	game.wave = 1
	game.gold = [1000, 1000]
	game.interest_last = [0, 0]
	game.bank_level = 0
	game.bot_bank_level = 0
	game.raid_boost = 0
	game.bot_raid_boost = 0
	game.ability_used = false
	game.bot_ability_used = false
	game.previous_raids = [[0, 0, 0], [0, 0, 0]]
	game.previous_kinds = [[0, 0, 0], [0, 0, 0]]
	game.orders = [[], []]
	game.traps = [[], []]
	game.guards.clear()
	game.units.clear()
	game.hit_sparks.clear()
	game.turret_bolts.clear()
	game.fallen_actors.clear()
	game.deposit_actors.clear()
	game.account_finished_waves = 0
	game.account_wave_active = false
	game.rng.seed = seed_value

func play(race_a: int, strategy_a: String, race_b: int, strategy_b: String, seed_value: int) -> void:
	reset(race_a, race_b, seed_value)
	while game.phase != "END" and game.wave <= 24:
		game.prepare_strategy(0, strategy_a)
		game.prepare_strategy(1, strategy_b)
		game.phase = "ATTACK"
		game.launch_wave()
		for _tick in 1200:
			game._simulate(0.05)
			if game.phase == "END" or game.units.is_empty():
				break
		if game.phase != "END":
			game._end_wave()
	var score := 0.5
	if game.gold[0] > 0 and game.gold[1] <= 0:
		score = 1.0
	elif game.gold[1] > 0 and game.gold[0] <= 0:
		score = 0.0
	if game.phase != "END":
		timed_out += 1
	matches.append({"race_a": race_a, "strategy_a": strategy_a, "race_b": race_b, "strategy_b": strategy_b,
		"seed": seed_value, "score_a": score, "wave": game.wave, "gold": game.gold.duplicate()})

func run() -> void:
	game = Game.new()
	var full: bool = "--full" in OS.get_cmdline_user_args()
	var seed_values := [1701]
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--seeds="):
			seed_values.clear()
			for value in argument.trim_prefix("--seeds=").split(","):
				seed_values.append(int(value))
	var started: int = Time.get_ticks_msec()
	for seed_value in seed_values:
		for race_a in 4:
			for index_a in STRATEGIES.size():
				for race_b in 4:
					for index_b in STRATEGIES.size():
						if race_a * STRATEGIES.size() + index_a >= race_b * STRATEGIES.size() + index_b:
							continue
						# Quick CI: every strategy pair with same-race symmetry;
						# full also crosses all factions and both board sides.
						if not full and race_a != race_b:
							continue
						play(race_a, STRATEGIES[index_a], race_b, STRATEGIES[index_b], seed_value)
						play(race_b, STRATEGIES[index_b], race_a, STRATEGIES[index_a], seed_value)
				print("Tournament progress: %d matches, %.1f s" % [matches.size(), float(Time.get_ticks_msec() - started) / 1000.0])
	var faction_scores: Array = [0.0, 0.0, 0.0, 0.0]
	var faction_games: Array = [0, 0, 0, 0]
	var policy_scores: Dictionary = {}
	var policy_games: Dictionary = {}
	var head_to_head: Dictionary = {}
	var profiles: Dictionary = {}
	var draws := 0
	var longest := 0
	for strategy in STRATEGIES:
		policy_scores[strategy] = 0.0
		policy_games[strategy] = 0
		head_to_head[strategy] = {}
	for result in matches:
		if result["score_a"] == 0.5:
			draws += 1
		longest = maxi(longest, int(result["wave"]))
		for side in ["a", "b"]:
			var race: int = result["race_" + side]
			var strategy: String = result["strategy_" + side]
			var other: String = result["strategy_b" if side == "a" else "strategy_a"]
			var score: float = result["score_a"] if side == "a" else 1.0 - float(result["score_a"])
			var profile := "%d/%s" % [race, strategy]
			if not profiles.has(profile):
				profiles[profile] = {"games": 0, "points": 0.0, "losses": 0}
			profiles[profile]["games"] += 1
			profiles[profile]["points"] += score
			if score == 0.0:
				profiles[profile]["losses"] += 1
			faction_scores[race] += score
			faction_games[race] += 1
			policy_scores[strategy] += score
			policy_games[strategy] += 1
			if not head_to_head[strategy].has(other):
				head_to_head[strategy][other] = {"points": 0.0, "games": 0}
			head_to_head[strategy][other]["points"] += score
			head_to_head[strategy][other]["games"] += 1
	var race_rates: Array = []
	var strategy_rates: Dictionary = {}
	var failed: bool = timed_out > 0
	for race in 4:
		var rate: float = float(faction_scores[race]) / float(faction_games[race])
		race_rates.append(rate)
		print("Faction %s: %.2f%% points" % [game.RACE_NAMES[race], rate * 100.0])
		if full and (rate < 0.40 or rate > 0.60):
			failed = true
	var counters: Dictionary = {}
	for strategy in STRATEGIES:
		var rate: float = float(policy_scores[strategy]) / float(policy_games[strategy])
		strategy_rates[strategy] = rate
		if rate > 0.75:
			failed = true
		var worst := 1.0
		var counter := ""
		for other in head_to_head[strategy]:
			if other == strategy:
				continue
			var data: Dictionary = head_to_head[strategy][other]
			var value: float = float(data["points"]) / float(data["games"])
			if value < worst:
				worst = value
				counter = other
		counters[strategy] = {"strategy": counter, "points_against": worst}
		print("Strategy %s: %.2f%% points; counter %s (%.2f%%)" % [strategy, rate * 100.0, counter, worst * 100.0])
		# A policy winning every aggregate matchup is a balance regression.
		if worst >= 0.5:
			failed = true
	for profile in profiles:
		if int(profiles[profile]["losses"]) == 0:
			push_error("No tested counter for faction/strategy " + str(profile))
			failed = true
	var report := {"engine": Engine.get_version_info()["string"], "mode": "full" if full else "quick", "seeds": seed_values,
		"match_count": matches.size(), "draws": draws, "timeouts": timed_out, "longest_waves": longest,
		"race_point_rates": race_rates, "strategy_point_rates": strategy_rates, "counters": counters,
		"head_to_head": head_to_head, "profiles": profiles, "elapsed_seconds": float(Time.get_ticks_msec() - started) / 1000.0, "matches": matches}
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--report="):
			var file := FileAccess.open(argument.trim_prefix("--report="), FileAccess.WRITE)
			if file == null:
				push_error("Cannot save tournament report")
				failed = true
			else:
				file.store_string(JSON.stringify(report, "\t") + "\n")
	game.free()
	print("Balance tournament %s: %d matches; %d draws; %d timeouts; longest %d waves" % ["FAILED" if failed else "PASSED", matches.size(), draws, timed_out, longest])
	quit(1 if failed else 0)
