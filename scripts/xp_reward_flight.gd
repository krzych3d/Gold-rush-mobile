extends Control
## One canvas item draws a bounded set of gold motes. It never changes saved XP.
signal delivered(fraction: float)
signal finished
const COIN = preload("res://assets/ui/ornate/coin.svg")
const DURATION := 1.9
var target: Control
var origin: Control
var budget := 12
var elapsed := 0.0
var delay := 0.8
var active := true

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	budget = clampi(budget, 6, 16)

func target_visible() -> bool:
	if not is_instance_valid(target) or not target.is_visible_in_tree():
		return false
	var bounds: Rect2 = target.get_global_rect()
	if not get_viewport_rect().encloses(bounds):
		return false
	var ancestor := target.get_parent()
	while ancestor is CanvasItem:
		if ancestor is ScrollContainer and not ancestor.get_global_rect().encloses(bounds):
			return false
		ancestor = ancestor.get_parent()
	return true

func _process(delta: float) -> void:
	advance(delta)

func advance(delta: float) -> void:
	if not active:
		return
	if not target_visible():
		# CanvasLayer drawing does not inherit a hidden menu's visibility.
		# Remove the last frame of motes as well as pausing their clock.
		hide()
		return
	show()
	elapsed += maxf(0, delta)
	var progress: float = clampf((elapsed - delay) / DURATION, 0, 1)
	# Motes first arrive after the opening part of the arc.
	delivered.emit(clampf((progress - 0.46) / 0.54, 0, 1))
	queue_redraw()
	if progress >= 1:
		active = false
		set_process(false)
		finished.emit()

func _draw() -> void:
	if not active or elapsed < delay or not is_instance_valid(target) or not target_visible():
		return
	var bounds: Rect2 = target.get_global_rect()
	var start: Vector2 = origin.get_global_rect().get_center() if is_instance_valid(origin) else bounds.get_center() + Vector2(0, 95)
	var progress: float = clampf((elapsed - delay) / DURATION, 0, 1)
	for index in budget:
		var offset: float = float(index) / float(budget) * 0.54
		var t: float = clampf((progress - offset) / 0.46, 0, 1)
		if t <= 0 or t >= 1:
			continue
		var end := Vector2(bounds.position.x + 16 + (bounds.size.x - 32) * (0.35 + float(index % 5) * 0.12), bounds.get_center().y)
		var from := start + Vector2(float(index % 5 - 2) * 10, float(index % 3) * 5)
		var bend := from.lerp(end, 0.5) + Vector2(float(index % 2 * 2 - 1) * 45, -65)
		var at: Vector2 = from * (1 - t) * (1 - t) + bend * 2 * (1 - t) * t + end * t * t
		var alpha: float = minf(1, (1 - t) * 8)
		var side: float = 15 + float(index % 3) * 2
		draw_circle(at, side * 0.70, Color(1, 0.64, 0.18, alpha * 0.13))
		draw_texture_rect(COIN, Rect2(at - Vector2.ONE * side * 0.5, Vector2.ONE * side), false, Color(1, 1, 1, alpha))
		draw_line(at - Vector2(5, 0), at + Vector2(5, 0), Color(1, 0.95, 0.69, alpha * 0.75), 1, true)
		draw_line(at - Vector2(0, 5), at + Vector2(0, 5), Color(1, 0.95, 0.69, alpha * 0.75), 1, true)
