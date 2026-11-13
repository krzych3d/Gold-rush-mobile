extends SceneTree
## Saved map selection, five distinct artworks, unchanged match and themed codex.
const Settings = preload("res://scripts/mobile_settings.gd")
var game

func _initialize() -> void:
	call_deferred("_run")

func require(value: bool, reason: String) -> bool:
	if not value:
		push_error(reason)
		quit(1)
	return value

func _run() -> void:
	DirAccess.remove_absolute("user://qa-battlefields.cfg")
	root.size = Vector2i(720, 1280)
	game = load("res://main.tscn").instantiate()
	game.presentation = Settings.new("user://qa-battlefields.cfg")
	game.presentation.language = "pl"
	root.add_child(game)
	await process_frame
	await process_frame
	if not require(game.presentation.battlefield == "standard" and game.epic_battlefield_texture.resource_path.ends_with("battlefield_clean.jpg"), "New player no longer starts on the original standard map"):
		return
	game._open_race_selection()
	var screen = game.selection_layer
	var picker: OptionButton = screen.find_child("BattlefieldChoice", true, false)
	if not require(picker != null and picker.item_count == 5 and picker.get_node_or_null("EpicButtonSurface") != null, "Five illustrated map choices missing from real selection screen"):
		return
	var paths: Array[String] = []
	var saved_gold: Array = game.gold.duplicate()
	for race in 4:
		screen.select_race(race)
		for index in 5:
			picker.selected = index
			picker.item_selected.emit(index)
			var texture: Texture2D = game.epic_battlefield_texture
			if not require(texture != null and texture.get_width() >= 1600 and texture.get_height() >= 700 and texture.get_width() <= 2048, "Map is missing or exceeds the mobile texture budget"):
				return
			if race == 0:
				paths.append(texture.resource_path)
			if not require(game.selected_race == race and game.gold == saved_gold and screen.battlefield_preview.texture == texture, "Map preview changes race/economy or shows the wrong artwork"):
				return
	if not require(paths.size() == 5 and paths[0] != paths[1] and paths[1] != paths[2] and paths[2] != paths[3] and paths[3] != paths[4], "Race maps reuse the same image"):
		return
	var restored = Settings.new("user://qa-battlefields.cfg")
	if not require(restored.battlefield == "void", "Map selection does not survive restart"):
		return
	game._back_from_race_selection()
	game._show_codex("carrier")
	var book = game.codex_overlay
	for option in [book.category_filter, book.race_filter, book.find_child("PreviewAction", true, false)]:
		if not require(option.get_node_or_null("EpicButtonSurface") != null and option.get_popup().has_theme_stylebox_override("panel"), "Book dropdowns still use stock Godot styling"):
			return
	for dimensions in [Vector2i(720, 1280), Vector2i(1280, 720), Vector2i(1560, 720), Vector2i(720, 1280)]:
		root.size = dimensions
		game.size = Vector2(dimensions)
		for _frame in 4:
			await process_frame
		if not require(book.codex_pages.vertical == (dimensions.x < dimensions.y) and book.detail_scroll.size.y >= 150 and book.footer.get_global_rect().end.y <= dimensions.y + 2, "Book does not reflow into reachable pages after rotation"):
			return
	game._close_codex()
	game._choose_faction(0)
	if not require(game.epic_battlefield_texture.resource_path.ends_with("battlefield_void.png"), "Starting a match resets selected map to faction default"):
		return
	# Loading a bad saved key must fall back without a missing-resource crash.
	var config := ConfigFile.new()
	config.set_value("display", "battlefield", "invalid")
	config.save("user://qa-battlefields-invalid.cfg")
	var invalid = Settings.new("user://qa-battlefields-invalid.cfg")
	if not require(invalid.battlefield == "standard", "Invalid map preference lacks a safe fallback"):
		return
	for path in ["user://qa-battlefields.cfg", "user://qa-battlefields-invalid.cfg"]:
		DirAccess.remove_absolute(path)
	print("Battlefield choices PASSED: original default, 4 races × 5 maps, preview, persistence, no balance changes and responsive themed book")
	game.queue_free()
	await process_frame
	quit(0)
