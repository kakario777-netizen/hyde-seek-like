# 국악풍 소리 직접 합성 (저작권 걱정 없음) — 무료 에셋에서 못 구한 소리를 채운다.
# 가야금(카플러스-스트롱 현 뜯기), 대금풍 피리(숨소리 섞인 사인파), 장구·북·징 합성
# 실행: python3 tools/gen_audio.py <출력폴더>  →  wav 로 만든 뒤 ffmpeg 로 ogg 변환
import math, os, random, subprocess, sys, wave
import numpy as np

SR = 44100
OUT = sys.argv[1] if len(sys.argv) > 1 else "build/synth"
os.makedirs(OUT, exist_ok=True)
rng = np.random.default_rng(7)

# 평조(平調) 5음: 황(Eb) 태 중 임 남 — 서양식으로 대략 Eb F Ab Bb C
BASE = 311.13  # Eb4
PENTA = [0, 2, 5, 7, 9]
# 계면조 느낌(슬픈 밤): 라 도 레 미 솔 위주
KYEMYEON = [0, 3, 5, 7, 10]

def hz(deg, octave=0, scale=PENTA):
    o, d = divmod(deg, len(scale))
    return BASE * 2 ** ((scale[d] + 12 * (o + octave)) / 12)

def pluck(f, dur, bright=0.5, decay=0.996):
    n = int(SR * dur)
    period = max(2, int(SR / f))
    buf = rng.uniform(-1, 1, period) * 0.8
    buf = np.convolve(buf, np.ones(3) / 3, mode="same") * bright + buf * (1 - bright)
    out = np.zeros(n)
    idx = 0
    for i in range(n):
        v = buf[idx]
        nxt = buf[(idx + 1) % period]
        buf[idx] = decay * 0.5 * (v + nxt)
        out[i] = v
        idx = (idx + 1) % period
    # 가야금 농현(떨림): 뒤쪽 음높이를 살짝 흔들기
    t = np.arange(n) / SR
    vib = 1 + 0.004 * np.sin(2 * math.pi * 5.5 * t) * np.clip((t - 0.25) * 2, 0, 1)
    pos = np.cumsum(vib)
    pos = np.clip(pos, 0, n - 1)
    out = np.interp(pos, np.arange(n), out)
    env = np.exp(-t * 2.2)
    return out * env

def flute(f, dur, vib=0.006):
    n = int(SR * dur); t = np.arange(n) / SR
    ph = 2 * math.pi * f * (t + vib / (2 * math.pi * 5) * np.sin(2 * math.pi * 5 * t) * np.clip(t * 2, 0, 1))
    tone = np.sin(ph) + 0.25 * np.sin(2 * ph) + 0.08 * np.sin(3 * ph)
    breath = np.convolve(rng.normal(0, 1, n), np.ones(30) / 30, mode="same") * 0.25
    env = np.minimum(1, t / 0.25) * np.minimum(1, (dur - t) / 0.4)
    return (tone + breath) * np.clip(env, 0, 1) * 0.35

def drum(kind, dur=0.6):
    n = int(SR * dur); t = np.arange(n) / SR
    if kind == "buk":       # 북: 낮은 둥
        f = 80 * np.exp(-t * 6) + 55
        s = np.sin(2 * math.pi * np.cumsum(f) / SR) * np.exp(-t * 7)
        s += rng.normal(0, 1, n) * np.exp(-t * 60) * 0.3
    elif kind == "kung":    # 장구 궁편: 둥
        f = 140 * np.exp(-t * 10) + 95
        s = np.sin(2 * math.pi * np.cumsum(f) / SR) * np.exp(-t * 9)
    elif kind == "deok":    # 장구 채편: 딱
        s = np.convolve(rng.normal(0, 1, n), [1, -0.9], mode="same") * np.exp(-t * 45)
        s += np.sin(2 * math.pi * 420 * t) * np.exp(-t * 30) * 0.4
    elif kind == "jing":    # 징
        s = sum(np.sin(2 * math.pi * f0 * t + p) * a for f0, a, p in [(92, 1, 0), (183.7, .5, 1), (271, .35, 2), (402, .2, 3)])
        s *= (1 - np.exp(-t * 30)) * np.exp(-t * 0.9)
        s *= 1 + 0.25 * np.sin(2 * math.pi * 3.2 * t)  # 맥놀이
    else:
        s = np.zeros(n)
    return s

def add(*xs):
    L = max(len(x) for x in xs); o = np.zeros(L)
    for x in xs:
        o[:len(x)] += x
    return o

def mix_at(track, snd, at, gain=1.0):
    i = int(at * SR)
    if i >= len(track):
        return
    j = min(len(track), i + len(snd))
    track[i:j] += snd[: j - i] * gain

def reverb(x, wet=0.25):
    out = x.copy()
    for d, g in [(0.031, .5), (0.047, .4), (0.071, .33), (0.113, .27), (0.173, .2), (0.251, .14)]:
        k = int(d * SR)
        out[k:] += x[:-k] * g * wet
    return out

def save(name, x, stereo=True):
    x = x / (np.max(np.abs(x)) + 1e-9) * 0.85
    path = os.path.join(OUT, name + ".wav")
    data = (x * 32767).astype(np.int16)
    with wave.open(path, "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(data.tobytes())
    return path

def seamless(track, fade=2.0):
    """끝부분을 앞부분에 겹쳐 끊김 없는 반복"""
    k = int(fade * SR)
    head = track[:k].copy(); tail = track[-k:].copy()
    ramp = np.linspace(0, 1, k)
    track = track[:-k].copy()
    track[:k] = head * ramp + tail * (1 - ramp)
    return track

# ── 배경음 ─────────────────────────────────────────────
def bgm_calm(name, scale, tempo, seconds, melody_seed, flute_on=True, drum_on=False, dark=False):
    r = random.Random(melody_seed)
    tr = np.zeros(int(SR * (seconds + 4)))
    beat = 60 / tempo
    t = 0.0; deg = 5
    while t < seconds - 2:
        # 가야금 선율: 느린 3박 장단(세마치/중모리 느낌), 쉼 많이
        step = r.choice([-2, -1, -1, 0, 1, 1, 2])
        deg = max(0, min(9, deg + step))
        f = hz(deg, -1 if dark else 0, scale)
        mix_at(tr, pluck(f, 2.6, bright=0.35 if dark else 0.55), t, 0.55)
        if r.random() < 0.3:
            mix_at(tr, pluck(f * 2, 1.5, 0.6), t + beat * 0.5, 0.18)
        if r.random() < 0.25:   # 아래 옥타브 받쳐 주기
            mix_at(tr, pluck(hz(deg % 5, -1, scale), 3.0, 0.3), t, 0.35)
        t += beat * r.choice([1, 1, 2, 2, 3])
    if flute_on:
        t = 2.0
        while t < seconds - 4:
            d = r.choice([3.0, 4.0, 5.0])
            mix_at(tr, flute(hz(r.choice([2, 3, 4, 5, 7]), -1, scale), d), t, 0.35 if not dark else 0.25)
            t += d + r.choice([2.0, 4.0, 6.0])
    if drum_on:
        t = 0.0
        while t < seconds:
            mix_at(tr, drum("kung"), t, 0.25)
            mix_at(tr, drum("deok", 0.2), t + beat * 1.5, 0.12)
            t += beat * 3
    tr = reverb(tr, 0.35)[: int(SR * seconds)]
    return seamless(tr, 2.5)

def bgm_battle(seconds=48):
    tempo = 132; beat = 60 / tempo
    tr = np.zeros(int(SR * (seconds + 2)))
    r = random.Random(11)
    t = 0.0; bar = 0
    # 휘모리풍 장구 + 북
    while t < seconds:
        mix_at(tr, drum("buk"), t, 0.7)
        mix_at(tr, drum("deok", 0.2), t + beat * 0.5, 0.35)
        mix_at(tr, drum("kung"), t + beat, 0.45)
        mix_at(tr, drum("deok", 0.2), t + beat * 1.5, 0.35)
        mix_at(tr, drum("deok", 0.2), t + beat * 1.75, 0.25)
        if bar % 4 == 3:
            mix_at(tr, drum("kung"), t + beat * 1.25, 0.35)
        t += beat * 2; bar += 1
    # 긴박한 가야금 반복 음형 (계면조)
    t = 0.0; deg = 4
    while t < seconds:
        for k in [0, 1, 2, 1]:
            mix_at(tr, pluck(hz(deg + k, -1, KYEMYEON), 0.6, 0.7, 0.993), t, 0.35)
            t += beat / 2
        deg = r.choice([3, 4, 5, 4])
    t = 4.0
    while t < seconds - 3:
        mix_at(tr, flute(hz(r.choice([5, 6, 7]), 0, KYEMYEON), 2.2, 0.01), t, 0.22)
        t += 6.0
    tr = reverb(tr, 0.18)[: int(SR * seconds)]
    return seamless(tr, 1.0)

# ── 효과음 ─────────────────────────────────────────────
def noise(n):
    return rng.normal(0, 1, n)

def sfx_punch(heavy=False):
    n = int(SR * (0.35 if heavy else 0.25)); t = np.arange(n) / SR
    body = np.sin(2 * math.pi * np.cumsum(110 * np.exp(-t * 18) + 50) / SR) * np.exp(-t * (14 if heavy else 22))
    slap = np.convolve(noise(n), np.ones(6) / 6, mode="same") * np.exp(-t * 70)
    return body * (1.3 if heavy else 1.0) + slap * 0.8

def sfx_kick():
    n = int(SR * 0.4); t = np.arange(n) / SR
    sw = np.convolve(noise(n), np.ones(20) / 20, mode="same") * np.clip(t / 0.08, 0, 1) * np.exp(-np.clip(t - 0.08, 0, 1) * 40) * 0.6
    hit = np.zeros(n); h = sfx_punch(True); hit[int(0.09 * SR):int(0.09 * SR) + len(h)] = h[: n - int(0.09 * SR)]
    return sw + hit

def sfx_block():
    n = int(SR * 0.3); t = np.arange(n) / SR
    wood = sum(np.sin(2 * math.pi * f * t) * a for f, a in [(310, 1), (720, .5), (1150, .3)]) * np.exp(-t * 28)
    return wood + noise(n) * np.exp(-t * 90) * 0.3

def sfx_hurt(heavy=False):
    a = sfx_punch(heavy)
    n = len(a); t = np.arange(n) / SR
    return a + np.sin(2 * math.pi * 70 * t) * np.exp(-t * 10) * (0.8 if heavy else 0.4)

def sfx_whoosh(dur=0.35):
    n = int(SR * dur); t = np.arange(n) / SR
    x = np.convolve(noise(n), np.ones(12) / 12, mode="same")
    return x * np.sin(math.pi * t / dur) ** 2

def sfx_paper(dur=0.25):
    n = int(SR * dur); t = np.arange(n) / SR
    x = np.diff(noise(n + 1)) * 0.5
    grains = (rng.random(n) < 0.02) * rng.normal(0, 1, n)
    return (x * 0.4 + grains) * np.sin(math.pi * t / dur)

def sfx_coin():
    n = int(SR * 0.6); t = np.arange(n) / SR
    s = sum(np.sin(2 * math.pi * f * t) * a for f, a in [(2093, 1), (2637, .6), (3520, .3)]) * np.exp(-t * 9)
    s2 = np.zeros(n); k = int(0.07 * SR); s2[k:] = s[: n - k] * 0.6
    return s + s2

def sfx_chime(notes, gap=0.11, dur=1.2):
    n = int(SR * (dur + gap * len(notes))); tr = np.zeros(n)
    for i, f in enumerate(notes):
        tt = np.arange(int(SR * dur)) / SR
        tone = (np.sin(2 * math.pi * f * tt) + 0.3 * np.sin(2 * math.pi * f * 2.76 * tt)) * np.exp(-tt * 4)
        mix_at(tr, tone, i * gap)
    return reverb(tr, 0.3)

def sfx_step():
    n = int(SR * 0.18); t = np.arange(n) / SR
    return np.convolve(noise(n), np.ones(40) / 40, mode="same") * np.exp(-t * 35) * 3 + np.sin(2 * math.pi * 90 * t) * np.exp(-t * 40) * 0.5

def sfx_click():
    n = int(SR * 0.08); t = np.arange(n) / SR
    return sum(np.sin(2 * math.pi * f * t) * a for f, a in [(900, 1), (1900, .4)]) * np.exp(-t * 80)

def sfx_gulp():
    n = int(SR * 0.7); tr = np.zeros(n)
    for i in range(3):
        tt = np.arange(int(SR * 0.15)) / SR
        b = np.sin(2 * math.pi * np.cumsum(300 + 500 * tt / 0.15) / SR) * np.sin(math.pi * tt / 0.15)
        mix_at(tr, b, 0.05 + i * 0.18, 0.6)
    return add(tr, sfx_chime([hz(5, 1), hz(7, 1)], 0.1, 0.6) * 0.4)

def sfx_scroll():
    a = sfx_paper(0.45); n = len(a); t = np.arange(n) / SR
    return a + np.sin(2 * math.pi * 120 * t) * np.exp(-t * 20) * 0.3

def build(out_dir):
    items = {
        "bgm/title": bgm_calm("title", PENTA, 66, 64, 1),
        "bgm/story": bgm_calm("story", PENTA, 72, 56, 2, flute_on=True),
        "bgm/travel": bgm_calm("travel", PENTA, 92, 48, 3, flute_on=False, drum_on=True),
        "bgm/night": bgm_calm("night", KYEMYEON, 58, 56, 4, flute_on=True, dark=True),
        "bgm/battle": bgm_battle(48),
        "sfx/punch": sfx_punch(), "sfx/punch_heavy": sfx_punch(True), "sfx/kick": sfx_kick(),
        "sfx/block": sfx_block(), "sfx/hurt": sfx_hurt(), "sfx/hurt_heavy": sfx_hurt(True),
        "sfx/whoosh": sfx_whoosh(), "sfx/powder": add(sfx_whoosh(0.5), sfx_paper(0.5) * 0.5),
        "sfx/page": sfx_paper(0.22), "sfx/card_draw": sfx_paper(0.15), "sfx/card_play": add(sfx_whoosh(0.22), sfx_paper(0.22)),
        "sfx/scroll": sfx_scroll(), "sfx/coin": sfx_coin(), "sfx/item": sfx_chime([hz(2, 1), hz(4, 1)]),
        "sfx/good": sfx_chime([hz(0, 1), hz(2, 1), hz(4, 1)]), "sfx/upgrade": sfx_chime([hz(0, 1), hz(2, 1), hz(4, 1), hz(5, 1)], 0.08),
        "sfx/bad": add(sfx_hurt() * 0.6, drum("buk", 0.6) * 0.8), "sfx/alarm": add(drum("buk", 0.6), np.concatenate([np.zeros(int(0.18 * SR)), drum("buk", 0.6)])),
        "sfx/step": sfx_step(), "sfx/click": sfx_click(), "sfx/potion": sfx_gulp(),

        "sfx/gong": drum("jing", 3.5), "sfx/drum_start": np.concatenate([drum("buk", 0.25), drum("buk", 0.25), drum("buk", 0.9)]),
        "sfx/save": sfx_chime([hz(4, 1)], 0.1, 0.5),
    }
    v = sfx_chime([hz(0, 1), hz(2, 1), hz(4, 1), hz(5, 1), hz(7, 1)], 0.12, 1.6)
    g = drum("jing", 2.4) * 0.5
    L = max(len(v), len(g)); vv = np.zeros(L); vv[:len(v)] += v; vv[:len(g)] += g
    items["sfx/victory"] = vv
    for k, x in items.items():
        os.makedirs(os.path.join(out_dir, os.path.dirname(k)), exist_ok=True)
        wav = save(k, x)
        ogg = os.path.join(out_dir, k + ".ogg")
        q = "4" if k.startswith("bgm") else "5"
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", wav, "-c:a", "libvorbis", "-q:a", q, ogg], check=True)
        os.remove(wav)
        print(k, round(len(x) / SR, 1), "s")

if __name__ == "__main__":
    build(OUT)
