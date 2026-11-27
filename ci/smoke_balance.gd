extends SceneTree
const Game = preload("res://scripts/game.gd")
const Rules = preload("res://scripts/balance_rules.gd")
const Story = preload("res://scripts/story_campaign.gd")
const CampaignMaps = preload("res://scripts/campaign_maps.gd")
const Profile = preload("res://scripts/account_progress.gd")
var failures: Array[String] = []

func require(ok: bool, label: String) -> void:
	if not ok:
		failures.append(label)
		push_error(label)

func fixture(race: int = 0, enemy: int = 0):
	var game = Game.new()
	game.selected_race = race
	game.bot_race = enemy
	game.phase = "PREP"
	game.rng.seed = 12345
	return game

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	# Every faction, role, training level and ability uses the same rules on both sides.
	var game = fixture()
	for race in 4:
		game.selected_race = race
		game.bot_race = race
		for ability in [false, true]:
			game.ability_used = ability
			game.bot_ability_used = ability
			for level in 4:
				game.raid_boost = level
				game.bot_raid_boost = level
				for kind in [-1, 0, 1, 2]:
					game.units.clear()
					game._spawn(0, 0, kind, 0)
					game._spawn(1, 0, kind, 0)
					for stat in ["health", "max_health", "speed", "capacity", "shadow_evasion", "frenzy"]:
						require(game.units[0][stat] == game.units[1][stat], "Unequal side stats: %d/%d/%s" % [race, kind, stat])
	game.free()
	# Upgrade prices increase for both players; neither side can buy a fourth tier.
	game = fixture(2, 2)
	game.gold = [5000, 5000]
	for side in 2:
		for cost in [120, 200, 280]:
			var before_gold: int = game.gold[side]
			require(game.purchase_training(side), "Training purchase rejected")
			require(before_gold - game.gold[side] == cost, "Training price fails to escalate")
		require(not game.purchase_training(side), "Fourth training tier is purchasable")
	game.phase = "ATTACK"
	game._end_wave()
	require(game.gold[0] == game.gold[1] and game.interest_last == [180, 180], "Real settlement uses different rules per side or uncapped savings")
	game.free()
	for race in 4:
		for level in 6:
			require(Rules.interest_payout(1000, race, level) == Rules.interest_payout(1000000, race, level), "Unbounded compound interest")
			require(Rules.interest_payout(0, race, level) == 0, "Empty vault receives rescue interest")
	# A paid one-wave shield must neither heal nor permanently raise max HP.
	game = fixture()
	game.purchase_guard(0, 1)
	var guard: Dictionary = game.guards[0]
	guard["health"] = 100.0
	require(game.activate_ability(0), "Iron Wall not purchasable with a defender")
	require(not game.activate_ability(0), "Ability can be activated twice in one wave")
	game._damage_guard(guard, 30)
	require(guard["health"] == 100 and guard["shield"] == 30 and guard["max_health"] == game.GUARD_HP, "Shield heals or changes permanent HP")
	game.phase = "ATTACK"
	game._end_wave()
	require(guard["health"] == 100 and guard["shield"] == 0, "Shield survives end of wave")
	game.activate_ability(0)
	require(guard["health"] == 100 and guard["shield"] == 60 and guard["max_health"] == game.GUARD_HP, "Iron Wall stacks across waves")
	game.free()
	# Frenzy is a real melee bonus, and a stun suppresses retaliation.
	game = fixture(1, 0)
	game.purchase_guard(1, 1)
	game.ability_used = true
	game.phase = "ATTACK"
	game._spawn(0, 1, 1, 0.8)
	game._simulate(0.05)
	require(game.units[0]["frenzy"] and float(game.units[0]["strike_cooldown"]) < 0.45, "Goblin Frenzy does not accelerate actual melee strikes")
	var guard_before: float = game.guards[0]["health"]
	game.units[0]["stunned"] = 2.5
	game.units[0]["strike_cooldown"] = 0.0
	game._simulate(0.05)
	require(game.guards[0]["health"] == guard_before, "Stunned raider can attack")
	game.free()
	game = fixture()
	var start: int = game.gold[0]
	require(not game.activate_ability(0) and game.gold[0] == start, "Empty Iron Wall wastes gold")
	for side in 2:
		for cost in [75, 90, 105, 120]:
			var before_gold: int = game.gold[side]
			game.purchase_unit(side, 0, 0, 1)
			require(before_gold - game.gold[side] == cost, "Same-kind recruitment does not increase its price")
		require(game.recruit_price(side, 1) == 140, "One role increases another role's recruitment price")
		require(not game.purchase_unit(side, 0, 0, 1), "Lane purchase cap differs by side")
		game.purchase_unit(side, 1, 0, 1)
		game.purchase_unit(side, 1, 0, 1)
		require(not game.purchase_unit(side, 2, 0, 1), "Wave purchase cap differs by side")
	game.phase = "ATTACK"
	game._end_wave()
	require(game.recruit_price(0, 0) == 75 and game.recruit_price(1, 0) == 75, "Recruitment premiums survive between waves")
	game.free()
	# Towers have a concrete counter and sabotage is limited to one structure.
	for side in 2:
		game = fixture(1, 1)
		game.purchase_trap(1 - side, 1, 2)
		game.purchase_trap(1 - side, 1, 2)
		game.phase = "ATTACK"
		game._spawn(side, 1, 2, 0.5)
		game._simulate(0.05)
		require(game.traps[1 - side].size() == 1 and game.units[0]["disarmed"], "Sabotage cannot counter a turret")
		game._simulate(0.05)
		require(game.traps[1 - side].size() == 1 and game.units[0]["health"] < game.units[0]["max_health"], "Saboteur disarms more than once or ignores second tower")
		game.free()
	# A reloading turret cannot consume Shadow Step; the next shot still hurts.
	game = fixture(1, 1)
	game.purchase_trap(1, 1, 2)
	game.phase = "ATTACK"
	game._spawn(0, 1, -1, 0.6)
	game._spawn(0, 1, 1, 0.5)
	game._simulate(0.05)
	require(game.units[0]["health"] == game.units[0]["max_health"] and game.units[1]["health"] == game.units[1]["max_health"] - 32, "Turret does not prioritize and counter heavy carriers")
	game.free()
	game = fixture(3, 1)
	game.ability_used = true
	game.purchase_trap(1, 1, 2)
	game.traps[1][0]["cooldown"] = 0.2
	game.phase = "ATTACK"
	game._spawn(0, 1, 1, 0.5)
	game._simulate(0.05)
	var unit: Dictionary = game.units[0]
	require(unit["shadow_evasion"], "Reload consumes Shadow Step")
	for _tick in 4:
		game._simulate(0.05)
	require(not unit["shadow_evasion"] and unit["health"] == unit["max_health"], "Shadow Step fails to evade exactly one real shot")
	for _tick in 14:
		game._simulate(0.05)
	require(unit["health"] < unit["max_health"], "Shadow Step grants permanent turret immunity")
	game.free()
	# Both single-use traps must visibly fire without changing the old damage or stun.
	game = fixture(0, 0)
	require(game.purchase_trap(1, 1, 0), "Spike trap purchase rejected")
	game.traps[1][0]["charges"] = 1
	game.phase = "ATTACK"
	game._spawn(0, 1, 1, 0.5)
	var carrier_hp: float = float(game.units[0]["health"])
	game._simulate(0.05)
	require(game.traps[1].is_empty() and game.trap_bursts.size() == 1,
		"Last spike charge failed to leave its impact on screen")
	require(is_equal_approx(float(game.units[0]["health"]), carrier_hp - game.TRAP_DAMAGE[0]),
		"Spikes visual animation changed damage")
	require(Game._trap_impulse(0.46) == 0.0 and Game._trap_impulse(0.36) > 0.8 and Game._trap_impulse(0.0) == 0.0,
		"Spike and snare trigger keyframes have invalid timing")
	for step in 11:
		game._simulate(0.05)
	require(game.trap_bursts.is_empty(), "Expired trap particle events remain in memory")
	game.free()
	game = fixture(0, 0)
	require(game.purchase_trap(1, 1, 1), "Snare purchase rejected")
	game.phase = "ATTACK"
	game._spawn(0, 1, 0, 0.5)
	game._simulate(0.05)
	require(game.trap_bursts.size() == 1 and float(game.traps[1][0]["fire_time"]) > 0.0,
		"Snare trigger does not animate")
	require(float(game.units[0]["stunned"]) > 2.0, "Snare effect lost its stun")
	game.free()
	# Snares stop a frenzy unit, and guards engage raiders instead of being run through.
	game = fixture(1, 1)
	game.purchase_trap(1, 1, 1)
	game.ability_used = true
	game.phase = "ATTACK"
	game._spawn(0, 1, 0, 0.5)
	game._simulate(0.05)
	require(game.units[0]["stunned"] > 2.0, "Frenzy ignores a snare")
	game.free()
	game = fixture(1, 1)
	game.purchase_guard(1, 1)
	game.phase = "ATTACK"
	game._spawn(0, 1, 1, 0.8)
	var before: float = game.units[0]["position"]
	game._simulate(0.05)
	require(game.units[0]["position"] == before and game.guards[0]["health"] < game.GUARD_HP, "Raider runs through a defender or cannot retaliate")
	game.free()
	# Process simultaneous theft symmetrically, regardless of insertion order.
	for first in 2:
		game = fixture(1, 1)
		game.gold = [25, 25]
		game.phase = "ATTACK"
		game._spawn(first, 0, 0, 0.999)
		game._spawn(1 - first, 0, 0, 0.999)
		game._simulate(0.05)
		require(game.gold == [0, 0] and game.phase == "END", "Simultaneous final theft favors insertion order")
		game.free()
	# No rescue after the late pressure empties both vaults; all expired loot is returned.
	game = fixture()
	game.phase = "ATTACK"
	game.wave = 6
	game.gold = [40, 40]
	game._end_wave()
	require(game.gold == [0, 0] and game.phase == "END", "Pressure revives an empty vault")
	game.free()
	game = fixture()
	game.phase = "ATTACK"
	game.gold = [900, 800]
	game._spawn(0, 0, 0, 0.5)
	game.units[0]["carried"] = 100
	game._end_wave()
	require(game.gold[1] == 1116, "Undelivered loot was lost or credited to attacker")
	game.free()
	# The bot must not inspect this wave's queued human purchases or bankrupt itself.
	var bot_a = fixture(0, 3)
	var bot_b = fixture(0, 3)
	bot_b.orders[0] = [{"kind": 2, "lane": 0}, {"kind": 1, "lane": 2}]
	bot_a._bot_prepare()
	bot_b._bot_prepare()
	require(bot_a.orders[1] == bot_b.orders[1] and bot_a.traps[1] == bot_b.traps[1] and bot_a.gold[1] == bot_b.gold[1], "Bot reads unlaunched purchases")
	bot_a.free()
	bot_b.free()
	_test_campaign()
	_test_campaign_routes()
	if failures.is_empty():
		print("Balance regression PASSED: side parity, bounded income, temporary shields, purchase caps, sabotage, evasion, melee, simultaneous theft, pressure and honest bot")
	quit(0 if failures.is_empty() else 1)


func _test_campaign() -> void:
	var path := "user://campaign_smoke_" + Crypto.new().generate_random_bytes(8).hex_encode() + ".cfg"
	var profile = Profile.new(path)
	require(Story.unlocked(profile, 0), "First dwarf chapter must be available at level one")
	require(not Story.unlocked(profile, 1), "Second chapter unlocked before first victory")
	require(not Story.unlocked(profile, 99), "Invalid campaign index allowed")
	require(Story.hazard_lane(1, 1) == 0 and Story.hazard_lane(1, 2) == 1 and Story.hazard_lane(1, 3) == 2, "Fissure does not rotate")
	require(Story.speed_factor(-1, 1, 0) == 1.0 and Story.speed_factor(0, 1, 0) == 1.0 and Story.speed_factor(1, 1, 0) == 0.55, "Campaign speed rule leaks into ordinary matches")
	var game = fixture()
	game.account = profile
	game.campaign_index = 0
	game.phase = "ATTACK"
	game.gold = [1000, 0]
	require(not game._check_vaults() and game.gold[1] == 600, "Enemy vault exhaustion ends survival chapter prematurely")
	game.account_battle_seconds = 1.0
	game.wave = 3
	game.account_finished_waves = 2
	game._end_wave()
	require(game.phase == "END" and profile.campaign_completed.has("dwarf_bells"), "Three-wave victory did not complete chapter")
	require(Story.unlocked(profile, 1), "Second chapter not unlocked on victory")
	var old_xp: int = profile.total_xp
	require(profile.claim_campaign("dwarf_bells", 3, 1.0)["gained"] == 0 and profile.total_xp == old_xp, "Repeated chapter gives additional XP")
	game.free()
	profile = Profile.new(path)
	require(profile.campaign_completed.has("dwarf_bells") and profile.total_xp == old_xp, "Chapter and XP did not persist")
	game = fixture()
	game.account = profile
	game.campaign_index = 1
	game.phase = "ATTACK"
	game.wave = 4
	game.campaign_delivered = 179
	game._end_wave()
	require(game.phase == "END" and not profile.campaign_completed.has("dwarf_mountain"), "Missing delivery target counts as victory")
	game.free()
	game = fixture()
	game.account = profile
	game.campaign_index = 1
	game.phase = "ATTACK"
	game.account_battle_seconds = 1.0
	game.campaign_delivered = 170
	game._spawn(0, 2, 0, 0.001)
	game.units[0]["returning"] = true
	game.units[0]["carried"] = 10
	game._simulate(0.05)
	require(game.campaign_delivered == 180, "Delivered loot does not count toward memory objective")
	game._end_wave()
	require(game.phase == "END" and profile.campaign_completed.has("dwarf_mountain"), "Delivery victory did not complete chapter")
	game.free()
	for suffix in ["", ".bak", ".pending"]:
		if FileAccess.file_exists(path + suffix):
			DirAccess.remove_absolute(path + suffix)


func _test_campaign_routes() -> void:
	for mission in 2:
		var art: Texture2D = CampaignMaps.texture(mission)
		require(art != null, "Missing imported original campaign art: %d" % mission)
		if art != null:
			require(art.get_width() == 1672 and art.get_height() == 941, "Campaign art cropped or resized unexpectedly")
		for lane in 3:
			var last: Vector2 = CampaignMaps.point(mission, lane, 0.0, 0)
			require(CampaignMaps.road_length(mission, lane) > 1800.0, "Campaign route too short")
			for step in range(1, 101):
				var t: float = float(step) / 100.0
				var p: Vector2 = CampaignMaps.point(mission, lane, t, 0)
				require(p.x > last.x and absf(p.x) < CampaignMaps.SIZE.x * 0.5 and absf(p.y) < CampaignMaps.SIZE.y * 0.5, "Campaign route out of map or non-monotonic")
				require(p.is_equal_approx(CampaignMaps.point(mission, lane, 1.0 - t, 1)), "Factions do not share the same reversed road")
				last = p
			for step in range(21):
				var t: float = float(step) / 20.0
				if lane < 2:
					require(CampaignMaps.point(mission, lane, t, 0).y < CampaignMaps.point(mission, lane + 1, t, 0).y, "Campaign lanes cross")
	var game = fixture()
	var old: Vector2 = game._point(1, 0.5, 0)
	require(game._battlefield_world_size() == Vector2(2400.0, 1060.0), "Normal map dimensions changed")
	game.campaign_index = 1
	game.campaign_map_art = true
	require(game._point(1, 0.5, 0).is_equal_approx(CampaignMaps.point(1, 1, 0.5, 0)), "Game actor path not connected to authored route")
	require(game._battlefield_world_size() == CampaignMaps.SIZE, "Campaign art loses aspect ratio")
	game.campaign_map_art = false
	require(game._point(1, 0.5, 0) == old, "Campaign route leaks into regular match")
	game.free()
