extends RefCounted
## Convert Android's unobscured area into logical canvas coordinates.
static func safe_rect(node: Control) -> Rect2:
	var full := Rect2(Vector2.ZERO, node.size)
	if not OS.has_feature("android"):
		return full
	var safe := DisplayServer.get_display_safe_area()
	if safe.size.x <= 0 or safe.size.y <= 0:
		return full
	# canvas_items + expand keep the short side at 720 in either orientation.
	var inverse := node.get_screen_transform().affine_inverse()
	var canvas_safe: Rect2 = inverse * Rect2(safe)
	return full.intersection(canvas_safe)
