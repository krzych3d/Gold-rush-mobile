extends SceneTree
## Offline packaging only; artwork and poses are authored by image_gen.
## godot --headless --path . --script res://ci/pack_campaign_skins.gd -- SOURCE_DIR
func _init() -> void:
	var arguments := OS.get_cmdline_user_args()
	if arguments.size() != 1:
		push_error("Expected the directory containing original generated PNG files")
		quit(1)
		return
	var metadata = JSON.parse_string(FileAccess.get_file_as_string("res://art_sources/campaign-skins-2026-11-28.json"))
	var staged := {}
	for asset in metadata["assets"]:
		var source_path: String = arguments[0].path_join(str(asset["source"]))
		if FileAccess.get_sha256(source_path) != str(asset["source_sha256"]):
			push_error("Source hash differs: " + source_path)
			quit(1)
			return
		var original := Image.load_from_file(source_path)
		if original == null or original.get_size() != Vector2i(1448, 1086) or original.detect_alpha() == Image.ALPHA_NONE:
			push_error("Expected registered 8x6 transparent source atlas: " + source_path)
			quit(1)
			return
		var packed := Image.create(1024, 768, false, Image.FORMAT_RGBA8)
		for row in 6:
			for column in 8:
				var frame := original.get_region(Rect2i(column * 181, row * 181, 181, 181))
				frame.resize(128, 128, Image.INTERPOLATE_LANCZOS)
				packed.blit_rect(frame, Rect2i(0, 0, 128, 128), Vector2i(column * 128, row * 128))
		staged[str(asset["path"])] = packed
	for path in staged:
		if staged[path].save_png("res://" + path) != OK:
			push_error("Could not write " + path)
			quit(1)
			return
	print("Campaign costume atlases packed: ", staged.size())
	quit()
