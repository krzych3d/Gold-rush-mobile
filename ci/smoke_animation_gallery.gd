extends SceneTree
## Headless test: assets load, the animation viewer renders, direction and actions change.

func _initialize() -> void:
	call_deferred("_run_smoke")

func _run_smoke() -> void:
	var gallery_script = load("res://scripts/animation_gallery.gd")
	if gallery_script == null:
		push_error("Animation gallery script could not be loaded")
		quit(1)
		return
	var viewer = gallery_script.new()
	root.add_child(viewer)
	viewer.size = Vector2(720, 1280)
	await process_frame
	if viewer.atlases.size() != 11:
		push_error("Expected 11 animated characters, including all 4 Voidborn roles")
		quit(1)
		return
	for atlas in viewer.atlases:
		if atlas == null or atlas.get_width() != 1024 or atlas.get_height() != 768:
			push_error("Every six-row character atlas must be 1024x768")
			quit(1)
			return
	# If the generated art has been imported, verify the six extra actions load
	# for each of the three applicable characters before producing an APK.
	for hero_index in viewer.SPECIAL_PATHS.keys():
		var extra_path: String = viewer.SPECIAL_PATHS[hero_index]
		if ResourceLoader.exists(extra_path):
			if not viewer.special_atlases.has(hero_index):
				push_error("Imported special sheet failed to load: " + extra_path)
				quit(1)
				return
			viewer.selected_unit = hero_index
			viewer.selected_action = 7
			viewer._refresh_labels()
			if viewer._action_count() != 13:
				push_error("Imported special actions not available: " + extra_path)
				quit(1)
				return
	viewer.selected_unit = 4
	viewer.selected_action = 0
	viewer._change_unit(1)
	viewer._change_action(1)
	viewer._flip()
	if viewer.selected_unit != 5 or viewer.selected_action != 1 or viewer.facing_right:
		push_error("Animation navigation or direction flip failed")
		quit(1)
		return
	await process_frame
	viewer._select_faction_preview(3)
	if viewer.selected_unit != 7 or viewer.unit_label.text != viewer.L10n.t("VOID SENTINEL"):
		push_error("Voidborn race quick selection did not show Void Sentinel")
		quit(1)
		return
	for i in range(7, 11):
		if ResourceLoader.exists(viewer.SHEET_PATHS[i]) and viewer.atlases[i] == null:
			push_error("Imported Voidborn atlas failed to load: " + viewer.SHEET_PATHS[i])
			quit(1)
			return
	print("Animation studio smoke test: 11 characters, Voidborn entry, specials and facing flip OK")
	viewer.queue_free()
	# Regression: a real melee hit must trigger the attacking unit's animation.
	var main_scene := load("res://main.tscn") as PackedScene
	var game = main_scene.instantiate()
	game.presentation.language = "pl"
	root.add_child(game)
	game.size = Vector2(720, 1280)
	await process_frame
	game._choose_faction(1)
	game._buy_guard()
	game._begin_attack()
	var target_unit: Dictionary = {}
	for unit in game.units:
		if int(unit["side"]) == 1 and int(unit["lane"]) == 1:
			target_unit = unit
			break
	if target_unit.is_empty():
		push_error("Unable to spawn enemy for melee regression")
		quit(1)
		return
	# Enemy approaches the allied guard from the opposite end of the lane.
	target_unit["position"] = 0.81
	game._guard_combat(0.05)
	if float(target_unit.get("attack_time", 0.0)) <= 0.0:
		push_error("Melee damage did not trigger the attacker animation")
		quit(1)
		return
	print("Combat smoke test: melee strike drives sprite animation")
	# Confirm every playable role has a texture, including all four unique Voidborn roles.
	for race in range(4):
		game.selected_race = race
		for kind in [-1, 0, 1, 2]:
			var is_guard: bool = kind == -1
			var key: String = game._character_key(0, kind, is_guard)
			var atlas: Texture2D = game._character_atlas(key)
			if atlas == null or atlas.get_size() != Vector2(1024, 768):
				push_error("Missing animation for race=%d role=%d key=%s" % [race, kind, key])
				quit(1)
				return
	game.selected_race = 3
	var keys: Array = [
		game._character_key(0, 0, true),
		game._character_key(0, 0, false),
		game._character_key(0, 1, false),
		game._character_key(0, 2, false)
	]
	if keys != ["void_sentinel", "void_stalker", "void_collector", "void_weaver"]:
		push_error("Voidborn roles are not assigned independent artwork")
		quit(1)
		return
	for side in [0, 1]:
		for returning in [false, true]:
			var expected: float = (1.0 if side == 0 else -1.0) * (-1.0 if returning else 1.0)
			var facing: float = game._travel_facing(side, returning)
			var transform: Transform2D = game._directional_sprite_transform(Vector2(0, 0), facing)
			if facing != expected or signf(transform.x.x) != signf(expected):
				push_error("Sprite is not mirrored on return: side=%d returning=%s" % [side, returning])
				quit(1)
				return
	print("Role coverage: 4 races × 4 roles; outbound/return facing verified")
	game.queue_free()
	quit(0)
