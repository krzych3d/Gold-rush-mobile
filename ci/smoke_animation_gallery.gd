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
	if viewer.atlases.size() != 7:
		push_error("Expected seven animated characters")
		quit(1)
		return
	for atlas in viewer.atlases:
		if atlas == null or atlas.get_width() != 1024 or atlas.get_height() != 768:
			push_error("Every six-row character atlas must be 1024x768")
			quit(1)
			return
	viewer._change_unit(1)
	viewer._change_action(1)
	viewer._flip()
	if viewer.selected_unit != 5 or viewer.selected_action != 1 or viewer.facing_right:
		push_error("Animation navigation or direction flip failed")
		quit(1)
		return
	await process_frame
	print("Animation studio smoke test: 7 characters, 6+ actions, facing flip OK")
	viewer.queue_free()
	# Regression: a real melee hit must trigger the attacking unit's animation.
	var main_scene := load("res://main.tscn") as PackedScene
	var game = main_scene.instantiate()
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
	game.queue_free()
	quit(0)
