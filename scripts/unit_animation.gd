extends RefCounted
## Visual event clocks. Combat timers, damage and the 20 Hz simulator are unchanged.
const HIT_SECONDS := 0.40

static func trigger(actor: Dictionary, event: String, seconds: float) -> void:
	actor[event + "_time"] = seconds
	actor[event + "_pose_age"] = 0.0
	actor[event + "_pose_duration"] = maxf(seconds, HIT_SECONDS) if event == "hit" else seconds

static func advance(actor: Dictionary, dt: float) -> void:
	for event in ["attack", "hit"]:
		var key: String = event + "_pose_age"
		if actor.has(key):
			actor[key] = minf(float(actor[key]) + dt, float(actor[event + "_pose_duration"]) + 0.1)

static func age(actor: Dictionary, event: String, render_delta: float, duration: float) -> float:
	if actor.has(event + "_pose_age"):
		return maxf(0.0, float(actor[event + "_pose_age"]) + render_delta)
	# Legacy fixtures and previews still support the old remaining-time fields.
	return maxf(0.0, duration - float(actor.get(event + "_time", 0.0)) + render_delta)

static func duration(actor: Dictionary, event: String, guard: bool = false) -> float:
	return float(actor.get(event + "_pose_duration", HIT_SECONDS if event == "hit" else 0.38 if guard else 0.45))

static func active(actor: Dictionary, event: String, delta: float, guard: bool = false) -> bool:
	if actor.has(event + "_pose_age"):
		var seconds: float = duration(actor, event, guard)
		return age(actor, event, delta, seconds) < seconds
	return float(actor.get(event + "_time", 0.0)) > 0.0

static func row(actor: Dictionary, guard: bool, attacking: bool, delta: float) -> int:
	if active(actor, "hit", delta, guard) or float(actor.get("stunned", 0.0)) > 0.0:
		return 3
	if active(actor, "attack", delta, guard):
		return 2
	if float(actor.get("steal_timer", 0.0)) > 0.0:
		return 5
	if not guard and attacking and not bool(actor.get("blocked", false)):
		return 1
	return 0

static func once(elapsed: float, seconds: float, count: int = 8) -> int:
	return clampi(int(floor(maxf(0.0, elapsed) / maxf(seconds, 0.001) * count)), 0, count - 1)

static func frame(actor: Dictionary, action: int, guard: bool, delta: float, offset: float = 0.0, count: int = 8, loop_fps: float = 10.0, fallback_clock: float = 0.0) -> int:
	if action in [2, 3]:
		var event := "attack" if action == 2 else "hit"
		var seconds: float = duration(actor, event, guard)
		return once(age(actor, event, delta, seconds), seconds, count)
	if action == 5:
		return once(0.65 - float(actor.get("steal_timer", 0.0)) + delta, 0.65, count)
	var fps: float = 5.0 if action == 0 else loop_fps
	return posmod(int(floor((float(actor.get("action_time", fallback_clock)) + delta) * fps + offset)), count)

static func recoil(seconds_remaining: float, duration: float, minimum: float = 0.91, peak: float = 1.06) -> float:
	# Continuous deployment/recovery, instead of four snapped scale states.
	if seconds_remaining <= 0.0:
		return 1.0
	var t: float = clampf(1.0 - seconds_remaining / duration, 0.0, 1.0)
	if t < 0.25:
		return lerpf(1.0, minimum, smoothstep(0.0, 0.25, t))
	if t < 0.55:
		return lerpf(minimum, peak, smoothstep(0.25, 0.55, t))
	return lerpf(peak, 1.0, smoothstep(0.55, 1.0, t))

static func special_row(key: String, action: int, moving: bool, carrying: bool) -> int:
	if action == 2:
		return -1 if key == "dwarf_carrier" else 3 if key == "arcane_mage" else 2
	if moving and action == 1:
		return 2 if key == "dwarf_carrier" and carrying else 0
	return -1
