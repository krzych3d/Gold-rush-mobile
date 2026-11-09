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
	game.presentation.language = "pl"
	root.add_child(game)
	game.size = Vector2(720, 1280)
	await process_frame
	await process_frame
	game._choose_faction(0)
	game.battle_shell.set_drawer_open(true, false)
	await process_frame
	await process_frame
	# Visual layout regression: catch portrait letterboxing, crushed cards and
	# the oversized battle container visible in the November screenshots.
	var expected_stretch = ProjectSettings.get_setting("display/window/stretch/aspect")
	if expected_stretch != "expand":
		_fail("Android must use expand aspect to avoid black letterbox bars")
		return
	var arena_panel: PanelContainer = game.arena.get_parent() as PanelContainer
	if arena_panel == null or arena_panel.size.y < game.size.y - 2.0:
		_fail("Full-screen battle must fill the available phone canvas")
		return
	var character_button: Button = game.controls[3]
	if character_button.size.y < 120.0:
		_fail("Character portrait too small to read in portrait layout")
		return
	var character_icon: TextureRect = character_button.get_node("Artwork") as TextureRect
	if character_icon.size.y < 75.0:
		_fail("Sprite cropped too tightly inside the character button")
		return
	var game_controls: Control = game.gameplay_panel.get_parent()
	if game_controls.size.y < 470.0:
		_fail("Gameplay commands did not occupy the free vertical space")
		return
	# Gold + phase HUD, arena, and command area should be fitted inside viewport.
	if game_controls.get_global_rect().end.y > game.size.y + 2.0:
		_fail("Main command controls overflow below phone viewport")
		return
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
	# The UI must use generated fantasy texture art, not the old flat
	# StyleBoxFlat controls that looked like stock Godot buttons.
	for button_index in game.controls.size():
		var skinned_button: Button = game.controls[button_index]
		var artwork_style := skinned_button.get_theme_stylebox("normal")
		if not (artwork_style is StyleBoxTexture):
			_fail("Button %d lacks an illustrated nine-patch skin" % button_index)
			return
		var art_tex: Texture2D = (artwork_style as StyleBoxTexture).texture
		# Original ImageGen cards have authentic 292px PNG source width,
		# whereas SVG fallback skin was intentionally >300px.
		if art_tex == null or art_tex.get_width() < 180:
			_fail("Illustrated control art did not import from SVG %d" % button_index)
			return
	for key in ["IllustratedTitle", "ResourceArtwork", "PhaseArtwork", "MessageArtwork"]:
		var plaque: PanelContainer = game.find_child(key, true, false) as PanelContainer
		if plaque == null or not (plaque.get_theme_stylebox("panel") is StyleBoxTexture):
			_fail("Missing fantasy artwork panel: " + key)
			return
	for button_index in range(3, 9):
		var card: Button = game.controls[button_index]
		var coin: TextureRect = card.get_node_or_null("GoldCoin") as TextureRect
		var price: Label = card.get_node_or_null("Price") as Label
		var aura: TextureRect = card.get_node_or_null("ArtGlow") as TextureRect
		if coin == null or coin.texture == null or price == null or aura == null:
			_fail("Missing dynamic currency or decorated hero art on card %d" % button_index)
			return
		if price.text != str(game.COSTS[button_index - 3] if button_index < 6 else game.TRAP_COSTS[button_index - 6]):
			_fail("Price text is disconnected from game economy at card %d" % button_index)
			return
	print("Illustrated UI QA: gold-frame image skins, live prices and four plaques loaded")
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
