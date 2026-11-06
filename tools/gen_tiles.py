# 작은 맵(쿼터뷰)용 타일·장식 그림 생성 — assets/ui/tiles/
import math, os, random
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "ui", "tiles")
os.makedirs(OUT, exist_ok=True)
TW, TH, SIDE = 160, 80, 44     # 마름모 너비·높이, 옆면 두께
S = 256                        # 윗면 원본 정사각 크기

def C(h, a=255):
    h = h.lstrip("#"); return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) + (a,)

def noise(seed, size, blur):
    r = np.random.default_rng(seed)
    return np.asarray(Image.fromarray((r.random((size, size)) * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(blur))).astype(np.float32) / 255

def top_cobble(seed, base, var, mortar):
    rnd = random.Random(seed)
    im = Image.new("RGB", (S, S), C(mortar)[:3]); d = ImageDraw.Draw(im)
    n = 7
    for gy in range(n):
        for gx in range(n):
            cx = (gx + 0.5 + rnd.uniform(-0.15, 0.15)) * S / n + (S / n / 2 if gy % 2 else 0)
            cy = (gy + 0.5 + rnd.uniform(-0.15, 0.15)) * S / n
            r = S / n * 0.44
            pts = [(cx + math.cos(a) * r * rnd.uniform(0.8, 1.05), cy + math.sin(a) * r * rnd.uniform(0.8, 1.05)) for a in np.linspace(0, 2 * math.pi, 9)[:-1]]
            f = rnd.uniform(1 - var, 1 + var); col = tuple(min(255, int(c * f)) for c in C(base)[:3])
            for dx in (-S, 0, S):
                d.polygon([(x + dx, y) for x, y in pts], fill=col)
                d.line([(x + dx, y) for x, y in pts[:4]], fill=tuple(min(255, c + 25) for c in col), width=2)
    return im

def top_planks(seed, base):
    rnd = random.Random(seed)
    im = Image.new("RGB", (S, S)); d = ImageDraw.Draw(im)
    w = S // 6
    for i in range(6):
        col = tuple(int(c * rnd.uniform(0.85, 1.1)) for c in C(base)[:3])
        d.rectangle([i * w, 0, (i + 1) * w - 3, S], fill=col)
        for k in range(14):
            y = rnd.randrange(S); d.line([(i * w + 3, y), ((i + 1) * w - 6, y + rnd.randint(-3, 3))], fill=tuple(c - 18 for c in col), width=1)
        d.rectangle([(i + 1) * w - 3, 0, (i + 1) * w, S], fill=(40, 26, 16))
    return im

def top_ground(seed, base, speck, tufts=None):
    n1 = noise(seed, S, 6); n2 = noise(seed + 1, S, 1.2)
    b = np.array(C(base)[:3], np.float32)
    arr = b[None, None, :] * (0.82 + 0.3 * n1[..., None]) + (n2[..., None] - 0.5) * 30
    im = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8)); d = ImageDraw.Draw(im)
    rnd = random.Random(seed)
    for _ in range(90):
        x, y = rnd.randrange(S), rnd.randrange(S); r = rnd.choice([1, 2, 2, 3])
        d.ellipse([x - r, y - r, x + r, y + r], fill=C(speck)[:3])
    if tufts:
        for _ in range(26):
            x, y = rnd.randrange(S), rnd.randrange(S)
            for k in range(4):
                d.line([(x, y), (x + rnd.randint(-5, 5), y - rnd.randint(5, 11))], fill=C(tufts)[:3], width=2)
    return im

def to_iso(top, side_col, edge):
    """정사각 윗면 → 마름모 + 옆면"""
    big = top.resize((S, S)).rotate(45, resample=Image.BICUBIC, expand=True)
    big = big.resize((TW, TH), Image.LANCZOS)
    mask = Image.new("L", (TW, TH), 0)
    ImageDraw.Draw(mask).polygon([(TW / 2, 0), (TW, TH / 2), (TW / 2, TH), (0, TH / 2)], fill=255)
    out = Image.new("RGBA", (TW, TH + SIDE), (0, 0, 0, 0))
    d = ImageDraw.Draw(out)
    sc = C(side_col)
    left = [(0, TH / 2), (TW / 2, TH), (TW / 2, TH + SIDE), (0, TH / 2 + SIDE)]
    right = [(TW / 2, TH), (TW, TH / 2), (TW, TH / 2 + SIDE), (TW / 2, TH + SIDE)]
    d.polygon(left, fill=tuple(int(c * 0.78) for c in sc[:3]) + (255,))
    d.polygon(right, fill=tuple(int(c * 0.58) for c in sc[:3]) + (255,))
    # 옆면 돌 줄눈
    for k in range(1, 3):
        y = SIDE * k / 3
        d.line([(0, TH / 2 + y), (TW / 2, TH + y)], fill=(0, 0, 0, 60), width=2)
        d.line([(TW / 2, TH + y), (TW, TH / 2 + y)], fill=(0, 0, 0, 60), width=2)
    d.line([(TW / 2, TH), (TW / 2, TH + SIDE)], fill=(0, 0, 0, 90), width=2)
    topl = big.convert("RGBA"); topl.putalpha(mask)
    out.alpha_composite(topl, (0, 0))
    d.line([(0, TH / 2), (TW / 2, 0), (TW, TH / 2)], fill=C(edge, 160), width=2)
    d.line([(0, TH / 2), (TW / 2, TH), (TW, TH / 2)], fill=(0, 0, 0, 120), width=2)
    return out

MATS = {
    "stone": (lambda: top_cobble(1, "#a8a090", 0.12, "#5a5246"), "#7a7266", "#e8e0cc"),
    "palace": (lambda: top_cobble(2, "#c8c0ac", 0.06, "#8a8270"), "#9a3a2c", "#fff4dc"),
    "dirt": (lambda: top_ground(3, "#a07a50", "#6e5236", "#7a8a40"), "#6e5236", "#d8b888"),
    "grass": (lambda: top_ground(4, "#6a8a48", "#4a6a30", "#9ab860"), "#6e5236", "#c8e0a0"),
    "wood": (lambda: top_planks(5, "#8a6040"), "#4a3020", "#d8b088"),
    "cave": (lambda: top_cobble(6, "#5a5058", 0.15, "#2a2428"), "#3a3236", "#9a8a90"),
    "brick": (lambda: top_cobble(7, "#a86a50", 0.08, "#5a3a2a"), "#7a4a36", "#e8b898"),
}

def deco_spikes():
    im = Image.new("RGBA", (TW, 110), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    rnd = random.Random(3)
    for row in range(3):
        for k in range(4):
            x = 34 + k * 26 + row * 6 - 8; y = 70 + row * 12 - k * 2
            h = rnd.randint(42, 58)
            d.polygon([(x - 6, y), (x + 6, y), (x + 1, y - h)], fill=C("#7a9a48"))
            d.polygon([(x - 6, y), (x - 1, y), (x + 1, y - h)], fill=C("#5a7a30"))
            d.line([(x - 5, y - h * 0.4), (x + 5, y - h * 0.4)], fill=C("#3a5020"), width=2)
    return im

def deco_herb():
    im = Image.new("RGBA", (90, 110), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    glow = Image.new("RGBA", (90, 110), (0, 0, 0, 0)); ImageDraw.Draw(glow).ellipse([10, 30, 80, 100], fill=(255, 230, 140, 120))
    im.alpha_composite(glow.filter(ImageFilter.GaussianBlur(10)))
    d.line([(45, 95), (45, 40)], fill=C("#4a7a30"), width=4)
    for a, l in [(-60, 26), (-20, 30), (20, 30), (60, 26), (-90, 18), (90, 18)]:
        rad = math.radians(a - 90)
        x2, y2 = 45 + math.cos(rad) * l, 50 + math.sin(rad) * l
        d.ellipse([x2 - 9, y2 - 5, x2 + 9, y2 + 5], fill=C("#6aa840"))
        d.line([(45, 50), (x2, y2)], fill=C("#3a6a20"), width=2)
    d.ellipse([39, 22, 51, 34], fill=C("#d0302a")); d.ellipse([47, 28, 57, 38], fill=C("#d0302a"))
    return im

def deco_gate():
    """도착문: 단청 일주문 + 금빛 후광 (4배로 그려 줄여서 매끈하게, 결과 320x340)"""
    from PIL import ImageFilter
    import math
    K = 8; W, H = 160 * K // 2, 170 * K // 2  # 640x680
    s = lambda v: int(v * K / 2)
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0)); g = ImageDraw.Draw(glow)
    for r in range(s(78), 0, -s(3)):
        a = int(110 * (1 - r / s(78)) ** 1.6)
        g.ellipse([W / 2 - r, s(98) - r * 1.1, W / 2 + r, s(98) + r * 1.1], fill=(255, 214, 120, a))
    im.alpha_composite(glow.filter(ImageFilter.GaussianBlur(s(4))))
    d = ImageDraw.Draw(im)
    OUT_ = C("#2a1610")
    # 돌계단
    for k, (w, y) in enumerate([(70, 160), (62, 154), (54, 148)]):
        d.rounded_rectangle([W / 2 - s(w), s(y), W / 2 + s(w), s(y + 7)], s(2), fill=C(["#8f8a80", "#a49e92", "#b9b3a6"][k]), outline=OUT_, width=s(1))
    # 기둥 (붉은 칠 + 밝은 면)
    for x in (34, 112):
        d.rounded_rectangle([s(x), s(58), s(x + 14), s(150)], s(3), fill=C("#b0302a"), outline=OUT_, width=s(1.2))
        d.rectangle([s(x + 2), s(60), s(x + 5), s(148)], fill=C("#d9574a"))
        d.rounded_rectangle([s(x - 3), s(140), s(x + 17), s(150)], s(2), fill=C("#9a948a"), outline=OUT_, width=s(1))
    # 문 안쪽: 은은한 빛
    inner = Image.new("RGBA", (W, H), (0, 0, 0, 0)); ig = ImageDraw.Draw(inner)
    ig.rectangle([s(48), s(70), s(112), s(148)], fill=(255, 236, 170, 150))
    im.alpha_composite(inner.filter(ImageFilter.GaussianBlur(s(3))))
    d = ImageDraw.Draw(im)
    # 창방·단청 띠
    d.rectangle([s(26), s(54), s(134), s(64)], fill=C("#2f7a5e"), outline=OUT_, width=s(1))
    for i in range(9):
        x = s(30 + i * 12)
        d.ellipse([x, s(55.5), x + s(7), s(62.5)], fill=C("#e8c35a"), outline=C("#c0392b"), width=s(0.8))
    d.rectangle([s(26), s(64), s(134), s(68)], fill=C("#2b5f9e"), outline=OUT_, width=s(0.8))
    # 공포(받침)
    for x in (30, 58, 88, 116):
        d.rectangle([s(x), s(46), s(x + 14), s(54)], fill=C("#3a8a6a"), outline=OUT_, width=s(0.8))
        d.rectangle([s(x + 3), s(48), s(x + 11), s(51)], fill=C("#e05a4a"))
    # 기와지붕 (처마 끝이 치켜 올라감)
    roof = [(s(2), s(40)), (s(14), s(46)), (s(80), s(44)), (s(146), s(46)), (s(158), s(40)),
            (s(150), s(30)), (s(122), s(18)), (s(38), s(18)), (s(10), s(30))]
    d.polygon(roof, fill=C("#34404e"), outline=OUT_, width=s(1.4))
    for i in range(1, 14):
        x = s(10 + i * 10.4)
        d.line([(x, s(20)), (x + s(1), s(44))], fill=C("#4b5a6c"), width=s(1.6))
    d.line([(s(14), s(46)), (s(80), s(44)), (s(146), s(46))], fill=C("#1d242c"), width=s(2))
    d.rounded_rectangle([s(34), s(12), s(126), s(20)], s(3), fill=C("#283240"), outline=OUT_, width=s(1))
    for x in (34, 126):
        d.ellipse([s(x - 4), s(10), s(x + 4), s(18)], fill=C("#283240"), outline=OUT_, width=s(1))
    d.line([(s(16), s(31)), (s(60), s(22))], fill=C("#7f93a8"), width=s(1.2))
    # 현판
    d.rounded_rectangle([s(62), s(66), s(98), s(80)], s(1.5), fill=C("#1e1a22"), outline=C("#d9b45a"), width=s(1.2))
    d.line([(s(68), s(73)), (s(92), s(73))], fill=C("#f0d27a"), width=s(1.6))
    # 반짝이
    for (x, y, r) in [(20, 80, 2.2), (142, 70, 2.6), (128, 120, 1.8), (30, 128, 1.6), (80, 6, 2.0)]:
        cx, cy, rr = s(x), s(y), s(r)
        d.polygon([(cx, cy - rr * 2), (cx + rr * 0.5, cy), (cx, cy + rr * 2), (cx - rr * 0.5, cy)], fill=(255, 240, 180, 230))
        d.polygon([(cx - rr * 2, cy), (cx, cy - rr * 0.5), (cx + rr * 2, cy), (cx, cy + rr * 0.5)], fill=(255, 240, 180, 230))
    return im.resize((320, 340), Image.LANCZOS)

def deco_coin_pile():
    im = Image.new("RGBA", (70, 60), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    for i, (x, y) in enumerate([(14, 34), (30, 38), (46, 34), (22, 26), (38, 26), (30, 18)]):
        d.ellipse([x, y, x + 20, y + 12], fill=C("#d8b260"), outline=C("#8a6420"))
        d.rectangle([x + 8, y + 4, x + 12, y + 7], fill=C("#5a4010"))
    return im

if __name__ == "__main__":
    for name, (fn, side, edge) in MATS.items():
        to_iso(fn(), side, edge).save(os.path.join(OUT, f"tile_{name}.png"))
    deco_spikes().save(os.path.join(OUT, "deco_spike.png"))
    deco_herb().save(os.path.join(OUT, "deco_herb.png"))
    deco_gate().save(os.path.join(OUT, "deco_gate.png"))
    deco_coin_pile().save(os.path.join(OUT, "deco_coin.png"))
    print("tiles done")
