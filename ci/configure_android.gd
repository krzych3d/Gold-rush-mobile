extends SceneTree

# Run with: godot --headless --editor --path . --script res://ci/configure_android.gd
func _initialize() -> void:
	var settings := EditorInterface.get_editor_settings()
	var sdk := OS.get_environment("ANDROID_HOME")
	var java := OS.get_environment("JAVA_HOME")
	if sdk.is_empty() or java.is_empty():
		push_error("ANDROID_HOME or JAVA_HOME is missing")
		quit(1)
		return
	settings.set_setting("export/android/android_sdk_path", sdk)
	settings.set_setting("export/android/java_sdk_path", java)
	print("Configured Godot Android SDK: ", sdk)
	print("Configured Godot Java SDK: ", java)
	quit()
