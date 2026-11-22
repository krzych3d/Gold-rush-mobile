extends RefCounted
## Pure analytics: reads combat events, never changes gold or balance.
var current: Dictionary = {}

func begin_wave(number: int, starting_gold: Array) -> void:
	current = {"wave": number, "start": starting_gold.duplicate(), "delivered": [0, 0], "raiders_lost": [0, 0], "defenders_lost": [0, 0]}

func record_delivery(side: int, amount: int) -> void:
	if current.is_empty() or side < 0 or side > 1 or amount <= 0:
		return
	var deliveries: Array = current["delivered"]
	deliveries[side] += amount

func record_fallen(side: int, is_guard: bool) -> void:
	if current.is_empty() or side < 0 or side > 1:
		return
	var key: String = "defenders_lost" if is_guard else "raiders_lost"
	var losses: Array = current[key]
	losses[side] += 1

func finish(before_interest: Array, interest: Array, pressure: int, ending_gold: Array) -> Dictionary:
	if current.is_empty():
		return {}
	var result: Dictionary = current.duplicate(true)
	result["before_interest"] = before_interest.duplicate()
	result["interest"] = interest.duplicate()
	result["pressure"] = pressure
	result["ending"] = ending_gold.duplicate()
	result["net"] = [int(ending_gold[0]) - int(result["start"][0]), int(ending_gold[1]) - int(result["start"][1])]
	current.clear()
	return result
