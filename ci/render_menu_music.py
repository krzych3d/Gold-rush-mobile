#!/usr/bin/env python3
"""Render an original 24-second fantasy menu theme once during APK build.
No runtime GDScript audio synthesis; standard library only."""
import math
import struct
import wave
from pathlib import Path

RATE = 16000
DURATION = 24
OUT = Path("assets/audio/enchanted_vault_theme.wav")
# D minor / F major, 6 bars at 60 bpm, spacious modal melody.
CHORDS = [(50, 57, 62, 65), (46, 53, 58, 62), (43, 50, 55, 58),
          (48, 55, 60, 64), (50, 57, 62, 65), (46, 53, 58, 62)]
MELODY = [74, 77, 81, 79, 77, 74, 72, 69, 70, 74, 77, 74,
          67, 70, 74, 72, 76, 79, 77, 74, 74, 72, 69, 74]
TAU = math.tau

def freq(midi):
    return 440.0 * (2.0 ** ((midi - 69) / 12.0))

def osc(t, f):
    return math.sin(TAU * f * t)

def env(t, duration, attack=0.08, release=0.2):
    return min(1.0, max(0.0, t / attack), max(0.0, (duration - t) / release))

# Precompute the note frequencies and avoid exponentiation inside the sample loop.
chords = [[freq(n) for n in c] for c in CHORDS]
melody = [freq(n) for n in MELODY]
harp = [[freq(n + 12) for n in (c[0], c[2], c[1], c[3])] for c in CHORDS]
OUT.parent.mkdir(parents=True, exist_ok=True)
with wave.open(str(OUT), "wb") as wav:
    wav.setnchannels(1)
    wav.setsampwidth(2)
    wav.setframerate(RATE)
    batch = bytearray()
    for i in range(RATE * DURATION):
        t = i / RATE
        bar = min(5, int(t / 4))
        local = t - 4 * bar
        chord = chords[bar]
        # Soft string ensemble: harmonics with a slow swell.
        swell = 0.70 + 0.30 * math.sin(math.pi * local / 4)
        strings = sum(osc(t, f) * 0.55 + osc(t, f * 2.0) * 0.12 for f in chord) * 0.035 * swell
        # Breath flute: one sustained, gently fading note per second.
        beat = min(23, int(t))
        bt = t - beat
        mf = melody[beat]
        flute = (osc(t, mf) + 0.12 * osc(t, mf * 2.0)) * env(bt, 0.95, 0.13, 0.32) * 0.095
        # Harp plucks: one note every half second.
        eighth = min(7, int(local * 2))
        ht = local * 2 - eighth
        hf = harp[bar][eighth % 4]
        pluck = (osc(t, hf) + 0.20 * osc(t, hf * 2)) * math.exp(-ht * 6.0) * 0.085
        # Subtle horn / bass on downbeats.
        bass = osc(t, chord[0] / 2) * math.exp(-local * 0.65) * 0.075
        # Gentle crossfade at the loop boundary; keep last chord resolving into first.
        edge = min(1.0, t / 0.3, (DURATION - t) / 0.3)
        sample = max(-1.0, min(1.0, (strings + flute + pluck + bass) * edge))
        batch.extend(struct.pack("<h", int(sample * 26000)))
        if len(batch) >= 65536:
            wav.writeframesraw(batch)
            batch.clear()
    wav.writeframes(batch)
print(f"Rendered {OUT}: {OUT.stat().st_size} bytes")
