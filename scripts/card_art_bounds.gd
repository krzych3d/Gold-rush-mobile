extends RefCounted
## First-pose alpha bounds, padded by 2px and clamped to the original 128px cell.
## Authored once: no GPU readback, image scan or new texture allocation per frame.
const UNITS := {
	"dwarf_defender": Rect2(3, 16, 124, 100),
	"dwarf_carrier": Rect2(10, 13, 106, 109),
	"elf_ranger": Rect2(5, 7, 121, 114),
	"arcane_mage": Rect2(5, 16, 123, 104),
	"goblin_raider": Rect2(7, 13, 121, 109),
	"goblin_saboteur": Rect2(11, 25, 109, 94),
	"shadow_wolf": Rect2(0, 24, 128, 93),
	"void_sentinel": Rect2(0, 12, 128, 109),
	"void_stalker": Rect2(9, 21, 115, 102),
	"void_collector": Rect2(6, 9, 113, 118),
	"void_weaver": Rect2(1, 12, 127, 112)
}
