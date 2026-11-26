extends RefCounted
## Campaign-only illustrations and authored lane centerlines in image UV space.
## UVs use the complete, uncropped 1672 x 941 artwork; both factions share
## exactly the same road, reversing progress rather than mirroring the terrain.
const SIZE := Vector2(2400.0, 1350.0)
const ASSETS := [
	"res://assets/epic/world/campaign_vargheim.jpg",
	"res://assets/epic/world/campaign_breathing_mountain.jpg"
]
const X_START := 0.105
const X_END := 0.905
# Seven equally spaced horizontal stations. Feet, not sprite centers, follow
# the road. The center routes pass below the painted funeral bier; the mountain
# bottom route stays on the stone ledge above the permanent geological chasm.
const ROAD_Y := [
	[
		[0.455, 0.422, 0.410, 0.400, 0.404, 0.411, 0.452],
		[0.585, 0.585, 0.615, 0.602, 0.581, 0.573, 0.555],
		[0.704, 0.734, 0.750, 0.747, 0.746, 0.729, 0.665]
	],
	[
		[0.414, 0.388, 0.389, 0.382, 0.374, 0.375, 0.420],
		[0.552, 0.551, 0.574, 0.554, 0.540, 0.532, 0.540],
		[0.650, 0.677, 0.664, 0.628, 0.611, 0.612, 0.635]
	]
]

static func texture(index: int) -> Texture2D:
	if index < 0 or index >= ASSETS.size():
		return null
	var path: String = ASSETS[index]
	return load(path) as Texture2D if ResourceLoader.exists(path) else null

static func point(index: int, lane: int, progress: float, side: int) -> Vector2:
	var t: float = progress if side == 0 else 1.0 - progress
	var rows: Array = ROAD_Y[clampi(index, 0, ROAD_Y.size() - 1)][clampi(lane, 0, 2)]
	var station: float = clampf(t, 0.0, 1.0) * float(rows.size() - 1)
	var i: int = mini(int(floor(station)), rows.size() - 2)
	var fraction: float = station - float(i)
	# Ease between authored points with continuous tangents. Keep x monotonic
	# so an attacker faces right/left throughout and flips only on return.
	var y: float = lerpf(float(rows[i]), float(rows[i + 1]), smoothstep(0.0, 1.0, fraction))
	var uv := Vector2(lerpf(X_START, X_END, t), y)
	return (uv - Vector2(0.5, 0.5)) * SIZE

static func road_length(index: int, lane: int) -> float:
	var result := 0.0
	var last := point(index, lane, 0.0, 0)
	for step in range(1, 25):
		var next := point(index, lane, float(step) / 24.0, 0)
		result += last.distance_to(next)
		last = next
	return result
