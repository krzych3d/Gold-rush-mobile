extends RefCounted
## Saved presentation preferences. Simulation rules never depend on this profile.
const CONFIG_PATH := "user://presentation.cfg"
const MODES := ["auto", "battery", "balanced", "high"]
var quality := "auto"
var effective_quality := "balanced"
var reduced_motion := false
var music_enabled := true
var show_fps := false
var sample_time := 0.0
var slow_samples := 0
var config_path := CONFIG_PATH

func _init(path: String = CONFIG_PATH) -> void:
	config_path = path
	var config := ConfigFile.new()
	if config.load(config_path) == OK:
		quality = str(config.get_value("display", "quality", "auto"))
		reduced_motion = bool(config.get_value("display", "reduced_motion", false))
		music_enabled = bool(config.get_value("audio", "music", true))
		show_fps = bool(config.get_value("display", "show_fps", false))
	if not MODES.has(quality):
		quality = "auto"
	resolve_profile()

func resolve_profile() -> void:
	effective_quality = quality
	if quality == "auto":
		# Start conservatively on smaller CPUs. Sustained measured FPS can lower
		# this further; CPU count alone is not treated as a GPU benchmark.
		effective_quality = "battery" if OS.get_processor_count() <= 4 else "balanced"
	sample_time = 0.0
	slow_samples = 0
	apply_frame_limit()

func apply_frame_limit() -> void:
	Engine.max_fps = 30 if effective_quality == "battery" else 60

func save() -> void:
	var config := ConfigFile.new()
	config.set_value("display", "quality", quality)
	config.set_value("display", "reduced_motion", reduced_motion)
	config.set_value("display", "show_fps", show_fps)
	config.set_value("audio", "music", music_enabled)
	config.save(config_path)

func observe_fps(delta: float, fps: float) -> bool:
	if quality != "auto" or effective_quality == "battery":
		return false
	sample_time += delta
	if sample_time < 4.0:
		return false
	sample_time = 0.0
	slow_samples = slow_samples + 1 if fps > 0.0 and fps < 25.0 else 0
	if slow_samples < 3:
		return false
	effective_quality = "battery"
	apply_frame_limit()
	return true

func battlefield_fps() -> float:
	return 12.0 if effective_quality == "battery" else 30.0 if effective_quality == "high" else 20.0

func preview_fps() -> float:
	return 12.0 if effective_quality == "battery" else 30.0 if effective_quality == "high" else 20.0

func ambient_count() -> int:
	return 0 if reduced_motion or effective_quality == "battery" else 6 if effective_quality == "high" else 3
