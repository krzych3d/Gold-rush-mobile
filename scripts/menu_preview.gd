extends Control
const L10n = preload("res://scripts/localization.gd")
const Epic = preload("res://scripts/epic_theme.gd")
## One lightweight live preview. Uses the same atlases as the battlefield.
## Trap diagrams explain mechanics; they never run or purchase actual game units.
var game
var entry: Dictionary = {}
var atlas: Texture2D
var object_art: Texture2D
var elapsed := 0.0
var redraw_elapsed := 0.0
var playing := true
var action := -1
var frame := 0
var row := 0
var facing := 1.0
var preview_mode := "unit"
var race := 0
var role := 0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	resized.connect(queue_redraw)

func configure(owner_game, data: Dictionary) -> void:
	game = owner_game
	entry = data
	race = int(data.get("race", 0))
	role = int(data.get("role", 0))
	preview_mode = str(data.get("demo", "unit"))
	var key: String = game._character_key_for_race(race, role, preview_mode == "defender" or (preview_mode == "ability" and race == 0))
	atlas = game._character_atlas(key)
	object_art = null
	match preview_mode:
		"spikes": object_art = game.spikes_texture
		"snare": object_art = game.snare_texture
		"turret": object_art = game.turret_texture
		"bank": object_art = game.VAULT_TIER_ART[0]
	elapsed = 0.0
	redraw_elapsed = 0.0
	action = -1
	playing = not game.presentation.reduced_motion
	_update_pose()
	queue_redraw()

func set_action(index: int) -> void:
	action = index
	elapsed = 0.0
	_update_pose()
	queue_redraw()

func toggle_playback() -> void:
	playing = not playing
	queue_redraw()

func _process(delta: float) -> void:
	if game == null or not playing or not is_visible_in_tree():
		return
	elapsed += delta
	redraw_elapsed += delta
	if redraw_elapsed >= 1.0 / game.presentation.preview_fps():
		redraw_elapsed = 0.0
		_update_pose()
		queue_redraw()

func _update_pose() -> void:
	var cycle: float = fmod(elapsed, 7.0)
	facing = -1.0 if cycle >= 3.5 and action == -1 else 1.0
	row = action if action >= 0 else 1 if cycle < 2.7 or cycle >= 3.5 and cycle < 6.2 else 5
	if preview_mode == "race" and action < 0:
		row = 0 if cycle < 2.0 else 2 if cycle < 3.5 else 1
	if preview_mode == "defender" or preview_mode == "ability":
		row = 2 if action < 0 else action
	frame = int(floor(elapsed * (5.0 if row == 0 else 10.0))) % 8
	if row == 4:
		frame = mini(7, int(fmod(elapsed, 2.0) * 10.0))

func _caption() -> String:
	if not playing:
		return L10n.t("Podgląd wstrzymany")
	if action >= 0:
		return [L10n.t("Spoczynek"), L10n.t("Ruch"), L10n.t("Atak"), L10n.t("Trafienie"), L10n.t("Upadek"), L10n.t("Oddanie złota")][action]
	match preview_mode:
		"spikes": return L10n.t("Kolce • 40 obrażeń • 3 ładunki")
		"snare": return L10n.t("Sidła • zatrzymanie na 2,5 s")
		"turret": return L10n.t("Wieżyczka • strzał co 0,6 s")
		"bank": return L10n.t("Rozwój skarbca • poziom %d / 5") % (1 + int(elapsed / 2.0) % 5)
		"raid": return L10n.t("Trening • więcej PŻ i szybszy ruch")
		"defender": return L10n.t("Obrońca • pilnuje swojej alejki")
		"ability": return L10n.t(str(game.ABILITY_NAMES[race]))
		"race": return L10n.t("Poznaj styl swojej rasy")
	return L10n.t("Wyprawa po złoto") if fmod(elapsed, 7.0) < 3.5 else L10n.t("Powrót z łupem")

func _draw_actor(at: Vector2, scale_factor: float = 1.0, actor_row: int = -1) -> void:
	if atlas == null:
		return
	# Keep the complete cell above the caption, even in a short phone panel.
	var side: float = minf(maxf(32.0, size.y - 54.0), 270.0) * scale_factor
	draw_set_transform(at, 0.0, Vector2(facing, 1.0))
	draw_texture_rect_region(atlas, Rect2(Vector2(-side * 0.5, -side), Vector2(side, side)), Rect2(Vector2(frame * 128, (row if actor_row < 0 else actor_row) * 128), Vector2(128, 128)))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw() -> void:
	if game == null or entry.is_empty():
		return
	var tint: Color = game.RACE_COLORS[race]
	draw_style_box(_stage_style(tint), Rect2(Vector2.ZERO, size))
	var ground: float = size.y - 39.0
	draw_line(Vector2(16, ground), Vector2(size.x - 16, ground), Color(tint, 0.26), 2.0)
	var center := Vector2(size.x * 0.5, ground)
	draw_set_transform(center, 0.0, Vector2(1.0, 0.28))
	draw_circle(Vector2.ZERO, minf(size.x * 0.32, 86.0), Color(tint, 0.09))
	draw_arc(Vector2.ZERO, minf(size.x * 0.32, 86.0), 0, TAU, 32, Color(tint, 0.5), 2.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if preview_mode == "bank":
		var level: int = int(elapsed / 2.0) % 5
		var side: float = minf(size.y - 40.0, size.x * 0.8)
		draw_texture_rect(game.VAULT_TIER_ART[level], Rect2(Vector2((size.x - side) * 0.5, ground - side), Vector2(side, side)), false)
	elif preview_mode in ["spikes", "snare", "turret"]:
		var object_pos := Vector2(size.x * 0.28, ground)
		var side: float = minf(size.y * 0.56, 130.0)
		draw_texture_rect(object_art, Rect2(object_pos - Vector2(side * 0.5, side), Vector2(side, side)), false)
		var actor_pos := Vector2(size.x * 0.72, ground)
		var cycle: float = fmod(elapsed, 4.0)
		_draw_actor(actor_pos, 0.75, 3 if cycle > 2.0 and cycle < 2.6 else 1)
		if preview_mode == "turret":
			var shot: float = fmod(elapsed, 0.6) / 0.6
			var origin := object_pos - Vector2(0, side * 0.73)
			var target := actor_pos - Vector2(0, 50)
			var projectile := origin.lerp(target, shot)
			draw_line(projectile - Vector2(12, 0), projectile, Color("a1eaff"), 3)
			draw_circle(projectile, 4, Color("f5fcff"))
		elif cycle > 2.0:
			draw_arc(actor_pos - Vector2(0, 35), 31, 0, TAU, 24, Color("d9afff", 0.8), 3)
	else:
		var offset := Vector2.ZERO
		if preview_mode in ["unit", "raid"] and action < 0:
			offset.x = sin(elapsed * TAU / 7.0) * minf(size.x * 0.18, 55.0)
		_draw_actor(center + offset)
		if preview_mode == "ability" or preview_mode == "raid":
			var pulse: float = 0.5 + 0.5 * sin(elapsed * 4.0)
			draw_arc(center - Vector2(0, 60), 49.0 + pulse * 7, 0.0, TAU, 32, Color(tint, 0.6), 3)
		if preview_mode in ["unit", "raid"] and fmod(elapsed, 7.0) >= 3.5 and action < 0:
			var coin := center + offset + Vector2(23, -45)
			draw_circle(coin, 10, Color("e5ac42"))
			draw_circle(coin, 6, Color("ffe3a0"))
	var font := ThemeDB.fallback_font
	var caption: String = _caption()
	var text_size: int = 16
	while text_size > 11 and font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size).x > size.x - 16.0:
		text_size -= 1
	var width: float = font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size).x
	draw_string(font, Vector2((size.x - width) * 0.5, size.y - 12.0), caption, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, Color("e3d8bc"))

var cached_style: StyleBoxTexture
func _stage_style(_tint: Color) -> StyleBoxTexture:
	if cached_style == null:
		cached_style = Epic.panel(0)
	return cached_style
