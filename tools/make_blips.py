# Generates the launcher's UI blips: 44.1 kHz 16-bit mono WAVs.  python3 blips.py <out dir>
import sys, wave, struct, math
RATE = 44100
OUT = sys.argv[1]

def tone(segments, volume=0.35, shape='sine'):
    """segments: [(freq_start, freq_end, seconds)] played in a row, each with a fast attack and exp decay."""
    out = []
    for f0, f1, dur in segments:
        n = int(RATE * dur); phase = 0.0
        for i in range(n):
            t = i / n
            f = f0 + (f1 - f0) * t
            phase += 2 * math.pi * f / RATE
            s = math.sin(phase)
            if shape == 'soft':   # a touch of 3rd harmonic: a bit "digital" without being harsh
                s = 0.8 * s + 0.2 * math.sin(3 * phase)
            env = min(1.0, i / (RATE * 0.004)) * math.exp(-4.5 * t)
            out.append(s * env * volume)
    return out

def write(name, samples):
    with wave.open(f'{OUT}/{name}.wav', 'w') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(RATE)
        w.writeframes(b''.join(struct.pack('<h', int(max(-1, min(1, s)) * 32767)) for s in samples))

write('move',   tone([(1750, 1650, 0.035)], 0.18, 'soft'))
write('select', tone([(660, 660, 0.05), (990, 990, 0.08)], 0.30, 'soft'))
write('back',   tone([(990, 990, 0.05), (620, 620, 0.08)], 0.26, 'soft'))
write('type',   tone([(2400, 2300, 0.012)], 0.08, 'soft'))
write('pass',   tone([(523, 523, 0.09), (659, 659, 0.09), (784, 784, 0.09), (1047, 1047, 0.32)], 0.30))
write('fail',   tone([(196, 165, 0.20), (147, 110, 0.38)], 0.38, 'soft'))
