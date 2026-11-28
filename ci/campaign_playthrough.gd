extends SceneTree
## Real 20Hz battles with deterministic seeds; no simulated victory injection.
const Game = preload("res://scripts/game.gd")
const Story = preload("res://scripts/story_campaign.gd")
const Runtime = preload("res://scripts/campaign_runtime.gd")
const Maps = preload("res://scripts/campaign_maps.gd")
var results: Array = []
var failed := false

func _initialize() -> void:
	call_deferred("run")

func play(chapter: int, policy: String, seed_value: int) -> Dictionary:
	var game = Game.new()
	var data: Dictionary = Story.MISSIONS[chapter]
	game.campaign_index = chapter
	game.campaign_state = Runtime.new(chapter, data, {"dwarf_refugees": "open"})
	game.campaign_map_art = true
	for path in 3:
		game.campaign_path_speed[path] = 2.0 * game.WORLD_HALF_LENGTH / Maps.road_length(chapter, path)
	game.account = game.AccountProgress.new("user://campaign-playthrough.cfg")
	game.account_match_id = "qa-campaign-playthrough"
	game.selected_race = int(data["race"])
	game.bot_race = int(data["enemy"])
	game.phase = "PREP"
	game.gold = [int(data["gold"]), 950]
	game.rng.seed = seed_value
	game.campaign_state.prepare(game)
	while game.phase != "END" and game.wave <= int(data["waves"]):
		if policy in ["heist_convoy", "heist_rush"]:
			var path: int = game.campaign_state.artifact_lane()
			for _n in 2:
				game.purchase_unit(0, path, 2 if policy == "heist_convoy" else 0, 300)
			for _n in 2:
				game.purchase_unit(0, path, 1, 300)
		elif policy in ["escort_saboteurs", "escort_convoy"]:
			# Read the same announced route a player sees in the PREP HUD.
			var path: int = game.campaign_state.boss_lane(game.wave)
			for _n in (3 if policy == "escort_saboteurs" else 2):
				game.purchase_unit(0, path, 2, 300)
			for _n in 2:
				game.purchase_unit(0, path, 1 if policy == "escort_convoy" else 0, 300)
		elif policy != "wait":
			game.prepare_strategy(0, policy)
		game._bot_prepare()
		if game.phase == "END": break
		game.phase = "ATTACK"
		game.account_wave_active = true
		game.launch_wave()
		for _step in 1200:
			game._simulate(0.05)
			if game.phase == "END" or game.units.is_empty(): break
		if game.phase != "END": game._end_wave()
	var result := {"chapter": chapter + 1, "policy": policy, "seed": seed_value, "won": game.campaign_won, "wave": game.wave,
		"gold": game.gold[0], "delivered": game.campaign_delivered, "rescued": game.campaign_state.rescued,
		"boss_hp": game.campaign_state.boss_health, "spent": game.campaign_state.spent}
	if game.campaign_state.rule() in ["heist", "undying"]:
		result["artifact"] = game.campaign_state.artifact_state
		result["rebirths"] = game.campaign_state.rebirths
	game.free()
	return result

func run() -> void:
	for chapter in Story.MISSIONS.size():
		for seed_value in [13, 1701, 971]:
			var wins := 0
			var policies: Array = ["save", "rush", "turrets", "guards", "mixed", "adaptive"]
			if chapter == 4: policies.append_array(["escort_saboteurs", "escort_convoy"])
			if str(Story.MISSIONS[chapter].get("rule", "")) == "heist": policies.append_array(["heist_convoy", "heist_rush", "wait"])
			for policy in policies:
				var result: Dictionary = play(chapter, policy, seed_value)
				results.append(result)
				if result["won"]: wins += 1
				if policy == "wait" and result["won"]:
					failed = true
					push_error("The paid-lockpick objective can be completed by idle free waves")
			print("Chapter %d seed %d: %d/%d strategies succeeded" % [chapter + 1, seed_value, wins, policies.size()])
			if wins < 2:
				failed = true
				push_error("Fewer than two viable strategies: chapter %d seed %d" % [chapter + 1, seed_value])
	var path := "user://campaign-playthrough.json"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--report="): path = argument.trim_prefix("--report=")
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"battles": results, "passed": not failed}, "\t"))
	file.close()
	for suffix in ["", ".bak", ".pending"]:
		DirAccess.remove_absolute("user://campaign-playthrough.cfg" + suffix)
	if not failed: print("Campaign playthrough PASSED: all nine chapters, three seeds, at least two viable strategies per chapter/seed")
	quit(1 if failed else 0)
