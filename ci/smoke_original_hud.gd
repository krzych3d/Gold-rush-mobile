extends SceneTree
## Contract test for genuine ImageGen UI assets, fallback and real buttons.

func _initialize() -> void:
	call_deferred("_test")

func _fatal(reason: String) -> void:
	push_error(reason)
	quit(1)

func _test() -> void:
	var resource := load("res://main.tscn") as PackedScene
	var game = resource.instantiate()
	root.add_child(game)
	game.size = Vector2(720, 1280)
	await process_frame
	await process_frame

	var files_available: bool = ResourceLoader.exists("res://assets/ui/direct/title.png")
	if game.original_png_ui != files_available:
		_fatal("Game does not detect the actual premium HUD assets correctly")
		return
	game._choose_faction(3)
	if files_available:
		for i in range(3):
			var hero: Button = game.controls[3 + i]
			var trap: Button = game.controls[6 + i]
			var hero_bg: StyleBoxTexture = hero.get_theme_stylebox("normal") as StyleBoxTexture
			var trap_bg: StyleBoxTexture = trap.get_theme_stylebox("normal") as StyleBoxTexture
			if hero_bg == null or hero_bg.texture == null or trap_bg == null or trap_bg.texture == null:
				_fatal("The premium PNG illustrations are missing from the in-game cards")
				return
			if (hero.get_node("Artwork") as TextureRect).visible or (trap.get_node("Artwork") as TextureRect).visible:
				_fatal("Old low-res artwork overlaps the original illustrated PNG card")
				return
		var bank_overlay: Label = game.invest_button.get_node_or_null("OriginalDynamicText") as Label
		var raid_overlay: Label = game.raid_button.get_node_or_null("OriginalDynamicText") as Label
		if bank_overlay == null or raid_overlay == null or bank_overlay.text.is_empty() or raid_overlay.text.is_empty():
			_fatal("Original HUD bank and raid prices are not dynamic")
			return
		if game.controls[9].text != "":
			_fatal("Native CTA label overlaps baked illustrated CTA lettering")
			return
		# Every faction must display its own characters whenever the matching
		# illustration PNG exists. Never substitute a Voidborn assassin.
		for race in range(4):
			game.selected_race = race
			game._refresh_unit_icons()
			for index in 3:
				var hero_name: String = ["runner", "carrier", "saboteur"][index]
				var wanted_name: String = game._race_art_name(hero_name)
				var has_premium: bool = game.ornate_ui.original_texture(wanted_name) != null
				var hero_button: Button = game.controls[3 + index]
				var live_atlas: TextureRect = hero_button.get_node("Artwork") as TextureRect
				var hero_bg: StyleBoxTexture = hero_button.get_theme_stylebox("normal") as StyleBoxTexture
				if live_atlas.visible == has_premium:
					_fatal("Wrong portrait overlay for faction %d, role %s" % [race, hero_name])
					return
				if has_premium and (hero_bg == null or hero_bg.texture != game.ornate_ui.original_texture(wanted_name)):
					_fatal("Faction %d is not using its own original PNG for %s" % [race, hero_name])
					return
			var ability_name: String = game._race_art_name("ability")
			if game.ornate_ui.original_texture(ability_name) != null:
				if game.ability_button.get_theme_stylebox("normal").texture != game.ornate_ui.original_texture(ability_name):
					_fatal("Faction ability art does not match active race")
					return
		game.selected_race = 3
		game._refresh_unit_icons()
		print("Premium PNG HUD: all original illustrations, prices and faction switching verified")
	else:
		print("Premium PNG HUD not yet imported: non-breaking fallback verified")
	# Real tap handlers must survive decoration.
	game.controls[1].pressed.emit()
	if game.lane != 1:
		_fatal("Premium skin disconnected lane selection")
		return
	game.controls[3].pressed.emit()
	if game.orders[0].is_empty():
		_fatal("Premium skin disconnected unit purchase")
		return
	print("Original illustrated HUD smoke PASSED")
	game.queue_free()
	quit(0)
