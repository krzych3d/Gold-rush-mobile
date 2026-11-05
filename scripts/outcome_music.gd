extends RefCounted
## Original short orchestral-style outcome cues. Fully offline; no licensed
## recordings, no API calls, and no per-frame audio synthesis during battle.
const RATE := 16000
const DURATION := 5.6

static func render(victory: bool, draw: bool = false) -> AudioStreamWAV:
	var chords: Array = [[60, 64, 67], [65, 69, 72], [67, 71, 74], [72, 76, 79]] if victory else [[57, 60, 64], [53, 57, 60], [50, 53, 57], [45, 48, 52]]
	var melody: Array = [72, 74, 76, 79, 84, 79, 76, 84] if victory else [72, 69, 65, 64, 60, 57, 52, 45]
	if draw:
		chords = [[57, 60, 64], [60, 64, 67], [57, 60, 64], [60, 64, 67]]
	var buffer := PackedByteArray()
	var frames: int = int(DURATION * float(RATE))
	buffer.resize(frames * 2)
	var phases: Array = [0.0, 0.0, 0.0]
	var lead_phase := 0.0
	var first: float = 0.0
	for i in frames:
		var t: float = float(i) / float(RATE)
		var chord_index: int = mini(3, int(t / 1.4))
		var total: float = 0.0
		for voice in 3:
			var semitone: float = float(chords[chord_index][voice])
			var hz: float = 440.0 * pow(2.0, (semitone - 69.0) / 12.0)
			phases[voice] = fposmod(float(phases[voice]) + TAU * hz / float(RATE), TAU)
			var phase: float = float(phases[voice])
			# Warm ensemble of low brass and strings, with a gently animated
			# harmonic spectrum rather than buzzy square-wave polyphony.
			total += (sin(phase) + 0.25 * sin(2.0 * phase) + 0.10 * sin(3.0 * phase)) * 0.084
		var step: int = mini(melody.size() - 1, int(t / 0.7))
		var lead_hz: float = 440.0 * pow(2.0, (float(melody[step]) - 69.0) / 12.0)
		lead_phase = fposmod(lead_phase + TAU * lead_hz / float(RATE), TAU)
		var step_t: float = fposmod(t, 0.7)
		var lead_env: float = minf(1.0, step_t / 0.10) * (1.0 - smoothstep(0.43, 0.70, step_t))
		total += (sin(lead_phase) + 0.17 * sin(2.0 * lead_phase)) * lead_env * (0.17 if victory else 0.12)
		var strike_t: float = fposmod(t, 1.4)
		# Damped ceremonial drum impacts / distant bass.
		var impact: float = sin(TAU * (73.0 if victory else 52.0) * t)
		total += impact * exp(-strike_t * (13.0 if victory else 7.0)) * 0.30
		var shimmer: float = sin(TAU * 1246.0 * t) * exp(-strike_t * 6.0)
		if victory:
			total += shimmer * 0.025
		var envelope: float = smoothstep(0.0, 0.18, t) * (1.0 - smoothstep(4.8, DURATION, t))
		var pcm: int = int(round(clampf(total * envelope, -0.86, 0.86) * 32767.0))
		if pcm < 0:
			pcm += 65536
		buffer[i * 2] = pcm & 255
		buffer[i * 2 + 1] = (pcm >> 8) & 255
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	stream.data = buffer
	return stream
