extends RefCounted
## Shared by live combat, the guide and the seeded strategy tournament.
const COSTS := [75, 140, 110]
const LOOTS := [50, 80, 40]
const HP := [45.0, 120.0, 75.0]
const SPEED := [0.21, 0.105, 0.15]
const TRAP_COSTS := [55, 75, 155]
const TRAP_DAMAGE := [50.0, 25.0, 16.0]
const TRAP_CHARGES := [3, 2, 999]
const GUARD_COST := 130
const GUARD_HP := 140.0
const ABILITY_COST := 120
const RAID_COST := 120
const RAID_STEP_COST := 80
const BANK_BASE_COST := 180
const BANK_STEP_COST := 110
const INTEREST_PRINCIPAL := 1000
const IRON_SHIELD := 60.0
const PRESSURE_START := 6
const PRESSURE_STEP := 75
const RACE_HEALTH := [1.25, 1.0, 1.10, 1.0]
const RACE_SPEED := [1.0, 1.20, 1.0, 1.05]
const RACE_CAPACITY := [1.0, 1.05, 1.05, 1.08]

static func raider_stats(kind: int, race: int, ability: bool, training: int) -> Dictionary:
	var health: float = 60.0 if kind == -1 else HP[kind]
	var speed: float = 0.145 if kind == -1 else SPEED[kind]
	var capacity: float = 25.0 if kind == -1 else float(LOOTS[kind])
	if race >= 0 and race < 4:
		health *= RACE_HEALTH[race]
		speed *= RACE_SPEED[race]
		capacity *= RACE_CAPACITY[race]
		if ability:
			match race:
				1: speed *= 1.25
				2: capacity *= 1.35
				3: speed *= 1.12
	var level: int = clampi(training, 0, 3)
	health *= 1.0 + float(level) * 0.12
	speed *= 1.0 + float(level) * 0.08
	return {"health": health, "speed": speed, "capacity": roundi(capacity)}

static func interest_rate(race: int, level: int) -> float:
	return (0.24 if race == 0 else 0.18) + float(clampi(level, 0, 5)) * 0.04

static func interest_payout(gold: int, race: int, level: int) -> int:
	if gold <= 0:
		return 0
	return maxi(20, floori(float(mini(gold, INTEREST_PRINCIPAL)) * interest_rate(race, level)))

static func training_cost(level: int) -> int:
	return RAID_COST + clampi(level, 0, 3) * RAID_STEP_COST

static func recruit_cost(kind: int, already_queued: int) -> int:
	return roundi(float(COSTS[kind]) * (1.0 + 0.20 * float(already_queued)))

static func vault_pressure(wave: int) -> int:
	return maxi(0, wave - PRESSURE_START + 1) * PRESSURE_STEP

static func free_units(wave: int) -> int:
	return wave + 1 if wave < 5 else 7
