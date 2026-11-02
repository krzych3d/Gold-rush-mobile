extends AudioStreamPlayer
# Original procedural fantasy menu score. No external audio assets or licensing.
const RATE := 22050.0
const LOOP_SECONDS := 32.0
const NOTES := [0, 3, 7, 10, 12, 15, 19, 22]
const CHORD_ROOTS := [0, -2, -5, -7, 0, 3, -2, -5]
var playback: AudioStreamGeneratorPlayback
var sample_index := 0
var music_enabled := true

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
	var available := mini(playback.get_frames_available(), 4096)
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
	var bar := int(floor(t / 4.0)) % 8
	var root := float(CHORD_ROOTS[bar])
	var bar_t := fposmod(t, 4.0)
	var intro := smoothstep(0.0, 3.0, t)
	var phrase := fposmod(t, LOOP_SECONDS)
	var outro := 1.0 - smoothstep(30.0, 32.0, phrase)
	var fade := intro * (0.75 + 0.25 * outro)
	# Wide, gently beating elven string choir.
	var pad := 0.0
	for interval in [0.0, 7.0, 12.0]:
		var hz := _frequency(root + interval - 12.0)
		pad += (_tone(t, hz) + 0.36 * _tone(t, hz * 1.003)) / 3.0
	pad *= 0.15 * (0.85 + 0.15 * sin(TAU * t / 8.0))
	# Airy flute melody, following a minor pentatonic/modal motif.
	var melody_step := int(floor(t * 2.0)) % 16
	var melody := [0, 2, 3, 5, 4, 3, 1, 2, 0, 4, 5, 7, 6, 4, 3, 2][melody_step]
	var note := float(NOTES[melody]) + root + 12.0
	var note_t := fposmod(t, 0.5)
	var breath := smoothstep(0.0, 0.06, note_t) * (1.0 - smoothstep(0.28, 0.49, note_t))
	var flute_hz := _frequency(note)
	var vibrato := 1.0 + 0.0025 * sin(TAU * 5.0 * t)
	var flute := (0.8 * _tone(t, flute_hz * vibrato) + 0.13 * _tone(t, flute_hz * 2.0)) * breath * 0.13
	# Sparkling harp notes and occasional fairy bells.
	var harp_step := int(floor(t * 4.0)) % 8
	var harp_hz := _frequency(root + float(NOTES[harp_step]) + 12.0)
	var harp_t := fposmod(t, 0.25)
	var harp := (_tone(t, harp_hz) + 0.27 * _tone(t, harp_hz * 2.0)) * exp(-harp_t * 18.0) * 0.075
	var bell_t := fposmod(t, 2.0)
	var bell_hz := _frequency(root + 31.0)
	var bell := (_tone(t, bell_hz) + 0.22 * _tone(t, bell_hz * 2.01)) * exp(-bell_t * 3.8) * 0.04
	# Low cinematic pulse at the start of each bar.
	var pulse := sin(TAU * 55.0 * t) * exp(-bar_t * 4.0) * 0.09
	return clampf((pad + flute + harp + bell + pulse) * fade, -0.8, 0.8)

func set_music_enabled(enabled: bool) -> void:
	music_enabled = enabled
	if enabled and not playing:
		play()
		playback = get_stream_playback() as AudioStreamGeneratorPlayback
	if not enabled:
		stop()
		playback = null
