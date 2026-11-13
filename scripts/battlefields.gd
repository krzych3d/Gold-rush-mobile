extends RefCounted
## Art-only choices: all maps use the same world bounds and gameplay lanes.
const IDS := ["standard", "dwarves", "goblins", "elves", "void"]
const TITLES := ["Standard", "Twierdze krasnoludów", "Goblińskie ostępy", "Księżycowe ogrody", "Szczelina Pustki"]
const PATHS := [
	"res://assets/epic/world/battlefield_clean.jpg",
	"res://assets/epic/world/battlefield_dwarves.png",
	"res://assets/epic/world/battlefield_goblins.png",
	"res://assets/epic/world/battlefield_elves.png",
	"res://assets/epic/world/battlefield_void.png"
]

static func index(id: String) -> int:
	return maxi(0, IDS.find(id))

static func texture(id: String) -> Texture2D:
	# Load only the chosen background. Do not keep four unused full maps in VRAM.
	return load(PATHS[index(id)]) as Texture2D
