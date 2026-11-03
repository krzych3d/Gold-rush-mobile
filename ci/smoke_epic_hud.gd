extends SceneTree
## Integration QA for actual tappable native HUD, spending controls and turret shots.

func _initialize() -> void:
	call_deferred("_run")

func _fail(reason: String) -> void:
	push_error(reason)
	quit(1)

func _run() -> void:
	var main_scene := load("res://main.tscn") as PackedScene
	if main_scene == null:
		_fail("Cannot load main game scene")
		return
	var game = main_scene.instantiate()
	root.add_child(game)
	game.size = Vector2(720, 1280)
	await process_frame
	await process_frame
	if game.controls.size() != 10:
		_fail("Expected 3 lanes + 3 units + 3 traps + start controls")
		return
	if not (game.gameplay_panel.get_parent() is PanelContainer):
		_fail("The native battle command panel was not created")
		return
	for index in range(3, 9):
		var button: Button = game.controls[index]
		var icon: TextureRect = button.get_node_or_null("Artwork") as TextureRect
		var label: Label = button.get_node_or_null("Caption") as Label
		if icon == null or icon.texture == null or label == null or button.pressed.get_connections().is_empty():
			_fail("Missing tap handler, image or caption on card %d" % index)
			return
		if button.size.y < 65.0:
			_fail("Card tap target too small at index %d" % index)
			return
	# Choose Voidborn, verifying the card artwork changes to an actual role atlas.
	game._choose_faction(3)
	if game.last_icon_race != 3:
		_fail("Selecting Voidborn did not update the icon strip")
		return
	var icon0: AtlasTexture = (game.controls[3].get_node("Artwork") as TextureRect).texture as AtlasTexture
	if icon0 == null or icon0.atlas != game._character_atlas("void_stalker"):
		_fail("Voidborn runner card displays an unrelated character")
		return
	# Verify lane and purchases through the actual button signal rather than a
	# direct game method call; this checks the user's real menu wiring.
	game.controls[2].pressed.emit()
	if game.lane != 2:
		_fail("Lane 3 button not connected")
		return
	var start_gold: int = game.gold[0]
	game.controls[3].pressed.emit()
	if game.orders[0].size() != 1 or game.gold[0] != start_gold - game.COSTS[0]:
		_fail("Runner purchase button did not spend gold and queue a unit")
		return
	var after_runner: int = game.gold[0]
	game.controls[8].pressed.emit()
	if game.traps[0].size() != 1 or int(game.traps[0][0]["kind"]) != 2 or game.gold[0] != after_runner - game.TRAP_COSTS[2]:
		_fail("Turret card did not buy a tower on selected lane")
		return
	var before_defender: int = game.guards.size()
	game.guard_button.pressed.emit()
	if game.guards.size() != before_defender + 1:
		_fail("Defender bar is not interactive")
		return
	var before_ability: bool = game.ability_used
	game.ability_button.pressed.emit()
	if not game.ability_used or before_ability:
		_fail("Race ability bar is not interactive")
		return
	game.invest_button.pressed.emit()
	if game.bank_level != 1:
		_fail("Bank upgrade is not interactive")
		return
	game.raid_button.pressed.emit()
	if game.raid_boost != 1:
		_fail("Raid upgrade is not interactive")
		return
	if game.controls[9].disabled:
		_fail("Start raid button is incorrectly disabled in preparation")
		return
	game.controls[9].pressed.emit()
	if game.phase != "ATTACK" or not game.controls[9].disabled:
		_fail("Start raid button did not switch phase and lock purchases")
		return
	for index in range(3, 9):
		if not game.controls[index].disabled:
			_fail("Purchases remain enabled during a running battle")
			return
	# Guarantee a target in turret range and confirm a visible shot is created.
	var target: Dictionary = {}
	for unit in game.units:
		if int(unit["side"]) == 1 and int(unit["lane"]) == 2:
			target = unit
			break
	if target.is_empty():
		_fail("Failed to spawn enemy on turret's lane")
		return
	target["position"] = 0.61
	target["stunned"] = 0.0
	var hp_before: float = float(target["health"])
	game._simulate(0.05)
	if game.turret_bolts.is_empty() or float(target["health"]) >= hp_before:
		_fail("Turret did not fire a projectile and apply damage")
		return
	var bolt_count: int = game.turret_bolts.size()
	game._simulate(0.05)
	if game.turret_bolts.size() > bolt_count:
		_fail("Turret ignored its per-tower reload cooldown")
		return
	print("Epic HUD regression PASSED: tap controls, 4-race card art, phase locks, animated turret")
	game.queue_free()
	quit(0)
