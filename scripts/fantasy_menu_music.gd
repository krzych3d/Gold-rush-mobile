extends AudioStreamPlayer
# Original procedural fantasy menu score. No external audio assets or licensing.
const RATE := 11025.0
const LOOP_SECONDS := 32.0
const NOTES := [0, 3, 7, 10, 12, 15, 19, 22]
const CHORD_ROOTS := [0, -2, -5, -7, 0, 3, -2, -5]
var playback: AudioStreamGeneratorPlayback
var sample_index := 0
var music_enabled := true
var cached_bar := -1
var cached_melody_step := -1
var cached_harp_step := -1
var pad_frequencies := PackedFloat32Array()
var flute_frequency := 440.0
var harp_frequency := 440.0
var bell_frequency := 880.0

func _ready() -> void:
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = RATE
	generator.buffer_length = 0.5
	stream = generator
	volume_db = -15.0
	play()
	playback = get_stream_playback() as AudioStreamGeneratorPlayback
	set_process(true)

func _process(_delta: float) -> void:
	if not music_enabled or playback == null:
		return
	var available := mini(playback.get_frames_available(), 1024)
	for i in available:
		var t := float(sample_index) / RATE
		var sample := _sample_music(t)
		playback.push_frame(Vector2(sample, sample * 0.96))
		sample_index += 1

func _frequency(semitones: float) -> float:
	return 220.0 * pow(2.0, semitones / 12.0)

func _tone(t: float, frequency: float) -> float:
	return sin(TAU * frequency * t)

func _sample_music(t: float) -> float:
	var bar: int = int(t / 4.0) % 8
	var root: float = float(CHORD_ROOTS[bar])
	if bar != cached_bar:
		cached_bar = bar
		pad_frequencies.clear()
		for interval in [0.0, 7.0, 12.0]:
			pad_frequencies.append(_frequency(root + interval - 12.0))
		bell_frequency = _frequency(root + 31.0)
		cached_melody_step = -1
		cached_harp_step = -1
	var melody_step: int = int(t * 2.0) % 16
	if melody_step != cached_melody_step:
		cached_melody_step = melody_step
		var melody: int = [0, 2, 3, 5, 4, 3, 1, 2, 0, 4, 5, 7, 6, 4, 3, 2][melody_step]
		flute_frequency = _frequency(float(NOTES[melody]) + root + 12.0)
	var harp_step: int = int(t * 4.0) % 8
	if harp_step != cached_harp_step:
		cached_harp_step = harp_step
		harp_frequency = _frequency(root + float(NOTES[harp_step]) + 12.0)
	var pad := 0.0
	for hz in pad_frequencies:
		pad += sin(TAU * hz * t)
	pad *= 0.047
	var note_t: float = fposmod(t, 0.5)
	var breath: float = smoothstep(0.0, 0.06, note_t) * (1.0 - smoothstep(0.28, 0.49, note_t))
	var flute: float = sin(TAU * flute_frequency * t) * breath * 0.13
	var harp_t: float = fposmod(t, 0.25)
	var harp: float = sin(TAU * harp_frequency * t) * exp(-harp_t * 18.0) * 0.075
	var bell_t: float = fposmod(t, 2.0)
	var bell: float = sin(TAU * bell_frequency * t) * exp(-bell_t * 3.8) * 0.04
	var bar_t: float = fposmod(t, 4.0)
	var pulse: float = sin(TAU * 55.0 * t) * exp(-bar_t * 4.0) * 0.09
	var fade: float = smoothstep(0.0, 3.0, t)
	return clampf((pad + flute + harp + bell + pulse) * fade, -0.8, 0.8)

func set_music_enabled(enabled: bool) -> void:
	music_enabled = enabled
	if enabled and not playing:
		play()
		playback = get_stream_playback() as AudioStreamGeneratorPlayback
	if not enabled:
		stop()
		playback = null
