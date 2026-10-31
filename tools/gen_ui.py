# 조선풍 UI 에셋 생성기 — 원본(assets_src/raw, assets-raw 브랜치)을 가공해 assets/ui 에 저장
# 원본 출처: 종이·나무 질감 ambientCG(CC0), 아이콘 game-icons.net(CC BY 3.0), 수선전도(퍼블릭 도메인)
import json, math, os, random, subprocess, sys
import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageEnhance, ImageOps

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "assets_src", "raw")
UI = os.path.join(ROOT, "assets", "ui")
os.makedirs(os.path.join(UI, "icons"), exist_ok=True)
rnd = random.Random(11)

def C(h, a=255):
    h = h.lstrip("#"); return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) + (a,)

def tint(img, col):
    g = ImageOps.grayscale(img).convert("RGB")
    return ImageChops.multiply(g, Image.new("RGB", g.size, col[:3]))

# ── 한지 ────────────────────────────────────────────────
def make_hanji(size=1024, base="#f3e7cc", seed=1):
    r = random.Random(seed)
    src = Image.open(os.path.join(RAW, "textures", "Paper001_Color.jpg")).convert("RGB")
    src = src.crop((0, 0, 1536, 1536)).resize((size, size), Image.LANCZOS)
    src = ImageEnhance.Contrast(src).enhance(2.2)
    mott = Image.open(os.path.join(RAW, "textures", "Paper003_Color.jpg")).convert("L").resize((size, size), Image.LANCZOS)
    mott = ImageEnhance.Contrast(mott).enhance(1.6)
    img = tint(src, C(base))
    arr = np.asarray(img).astype(np.float32)
    m = (np.asarray(mott).astype(np.float32) / 255.0 - 0.8) * 26
    arr += m[..., None]
    img = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8))
    # 닥나무 섬유 결
    fib = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(fib)
    for _ in range(int(size * 0.9)):
        x, y = r.uniform(0, size), r.uniform(0, size)
        ang = r.uniform(0, math.pi * 2); L = r.uniform(10, 70)
        pts = []
        for k in range(8):
            ang += r.uniform(-0.35, 0.35)
            x += math.cos(ang) * L / 8; y += math.sin(ang) * L / 8
            pts.append((x, y))
        dark = r.random() < 0.55
        d.line(pts, fill=(120, 95, 60, r.randint(18, 45)) if dark else (255, 252, 240, r.randint(40, 90)), width=1)
    fib = fib.filter(ImageFilter.GaussianBlur(0.4))
    img = img.convert("RGBA"); img.alpha_composite(fib)
    # 작은 티끌
    d = ImageDraw.Draw(img)
    for _ in range(size // 6):
        x, y = r.randrange(size), r.randrange(size); s = r.choice([1, 1, 1, 2])
        d.ellipse([x, y, x + s, y + s], fill=(110, 85, 55, r.randint(40, 110)))
    return img

def vignette(img, strength=0.35, col=(120, 85, 45)):
    w, h = img.size
    y, x = np.ogrid[:h, :w]
    dist = np.sqrt(((x - w / 2) / (w / 2)) ** 2 + ((y - h / 2) / (h / 2)) ** 2)
    a = np.clip((dist - 0.55) / 0.6, 0, 1) ** 1.6 * strength
    over = Image.new("RGBA", (w, h), col + (0,))
    over.putalpha(Image.fromarray((a * 255).astype(np.uint8)))
    out = img.convert("RGBA"); out.alpha_composite(over); return out

# ── 나무 테두리 + 놋쇠 장석 (9-patch) ──────────────────────
def wood_tex(size, name="Wood026", col=None):
    w = Image.open(os.path.join(RAW, "textures", name + "_Color.jpg")).convert("RGB").resize((size, size), Image.LANCZOS)
    if col:
        w = Image.blend(w, tint(w, C(col)), 0.5)
    return w.convert("RGBA")

def brass_corner(s, flip_x=False, flip_y=False):
    """ㄱ자 놋쇠 장석, 크기 s"""
    im = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    t = int(s * 0.36)
    shape = [(0, 0), (s, 0), (s, t * 0.55), (t * 1.15, t), (t, t * 1.15), (t * 0.55, s), (0, s)]
    shape = [(int(x), int(y)) for x, y in shape]
    d.polygon(shape, fill=C("#7a5a1c"))
    inner = [(max(0, x - 0), y) for x, y in shape]
    # 놋쇠 그라데이션
    grad = Image.new("RGBA", (s, s))
    ga = np.zeros((s, s, 4), np.uint8)
    yy, xx = np.mgrid[:s, :s]
    v = 1 - (xx + yy) / (2 * s)
    base = np.array([201, 162, 74]); hi = np.array([240, 214, 140]); lo = np.array([140, 105, 40])
    colr = (lo + (hi - lo) * np.clip(v * 1.4, 0, 1)[..., None]).astype(np.uint8)
    ga[..., :3] = colr; ga[..., 3] = 255
    grad = Image.fromarray(ga)
    mask = Image.new("L", (s, s), 0); ImageDraw.Draw(mask).polygon(shape, fill=255)
    mask = mask.filter(ImageFilter.MinFilter(5))
    im.paste(grad, (0, 0), mask)
    # 장식 구멍(박쥐 문양 대신 원형 투각) + 못
    for (cx, cy) in [(t * 0.5, t * 0.5), (s * 0.78, t * 0.32), (t * 0.32, s * 0.78)]:
        r = s * 0.055
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=C("#5a4010"))
        d.ellipse([cx - r * 0.55, cy - r * 0.55, cx + r * 0.2, cy + r * 0.2], fill=C("#f6e0a0"))
    d.line([(int(t * 1.0), int(t * 0.2)), (int(t * 0.2), int(t * 1.0))], fill=C("#8a6a20"), width=max(2, s // 40))
    if flip_x: im = ImageOps.mirror(im)
    if flip_y: im = ImageOps.flip(im)
    return im

def frame(w, h, border, corner, hanji, wood="Wood026", inner_line=True, hanji_col=None):
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    wt = wood_tex(max(w, h) * 2, wood)
    out.paste(wt.crop((0, 0, w, h)), (0, 0))
    # 깎은 모서리 입체감 (반투명은 반드시 덧그림 레이어에)
    sh = Image.new("RGBA", (w, h), (0, 0, 0, 0)); sd = ImageDraw.Draw(sh)
    for i in range(border // 3):
        sd.line([(i, h - 1 - i), (w - 1 - i, h - 1 - i), (w - 1 - i, i)], fill=(30, 15, 5, max(0, 140 - i * 10)))
        sd.line([(i, h - 1 - i), (i, i), (w - 1 - i, i)], fill=(255, 220, 170, max(0, 80 - i * 6)))
    # 안쪽 홈(목각 선)
    g = border - max(4, border // 4)
    sd.rectangle([g, g, w - 1 - g, h - 1 - g], outline=(40, 20, 8, 210), width=max(2, border // 10))
    sd.rectangle([g + 2, g + 2, w - 3 - g, h - 3 - g], outline=(255, 215, 160, 60), width=1)
    out.alpha_composite(sh)
    # 한지 안쪽
    hj = hanji.crop((0, 0, w - 2 * border, h - 2 * border))
    if hanji_col:
        hj = Image.blend(hj.convert("RGB"), tint(hj, C(hanji_col)), 0.6).convert("RGBA")
    out.paste(hj, (border, border))
    ins = Image.new("RGBA", (w, h), (0, 0, 0, 0)); idr = ImageDraw.Draw(ins)
    for i in range(10):
        idr.rectangle([border + i, border + i, w - 1 - border - i, h - 1 - border - i], outline=(90, 55, 20, 70 - i * 7))
    out.alpha_composite(ins)
    if inner_line:
        m = border + max(8, border // 3)
        ln = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        ImageDraw.Draw(ln).rectangle([m, m, w - 1 - m, h - 1 - m], outline=(150, 50, 40, 110), width=2)
        out.alpha_composite(ln)
    if corner:
        for fx, fy, x, y in [(0, 0, 0, 0), (1, 0, w - corner, 0), (0, 1, 0, h - corner), (1, 1, w - corner, h - corner)]:
            out.alpha_composite(brass_corner(corner, fx, fy), (x, y))
    return out

# ── 붉은 현판(이름표) ─────────────────────────────────────
def plaque(w, h):
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    d.rounded_rectangle([0, 0, w - 1, h - 1], 10, fill=C("#5a1612"))
    d.rounded_rectangle([4, 4, w - 5, h - 5], 8, fill=C("#9a2c22"))
    d.rounded_rectangle([10, 10, w - 11, h - 11], 5, outline=C("#d9b45a"), width=3)
    noise = Image.effect_noise((w, h), 18).convert("L")
    tex = Image.new("RGBA", (w, h), (0, 0, 0, 0)); tex.putalpha(noise.point(lambda v: max(0, v - 110) // 4))
    im.alpha_composite(tex)
    return im

# ── 상소문(카드) ──────────────────────────────────────────
def sangso(w, h, hanji, line_col=(178, 52, 40)):
    im = hanji.crop((40, 40, 40 + w, 40 + h)).copy()
    lines = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(lines)
    top, bot = int(h * 0.12), int(h * 0.88)
    for y in (top - 10, top, bot, bot + 10):
        d.line([(14, y), (w - 15, y)], fill=line_col + (150,), width=3 if y in (top, bot) else 1)
    cols = 7
    for k in range(1, cols):
        x = int(14 + (w - 28) * k / cols)
        d.line([(x, top), (x, bot)], fill=line_col + (55,), width=1)
    d.rectangle([14, top - 10, w - 15, bot + 10], outline=line_col + (150,), width=1)
    im.alpha_composite(lines)
    # 접힌 자국
    for k in (1, 2):
        x = int(w * k / 3)
        sh = Image.new("RGBA", (w, h), (0, 0, 0, 0)); sd = ImageDraw.Draw(sh)
        for i in range(10):
            sd.line([(x + i, 0), (x + i, h)], fill=(90, 60, 30, 26 - i * 2))
            sd.line([(x - i, 0), (x - i, h)], fill=(255, 250, 235, 30 - i * 3))
        im.alpha_composite(sh)
    # 가장자리 그림자, 살짝 해진 모서리
    im = vignette(im, 0.3)
    mask = Image.new("L", (w, h), 255); md = ImageDraw.Draw(mask)
    for _ in range(140):
        side = rnd.randrange(4); p = rnd.randrange(max(w, h)); r = rnd.uniform(1, 3.5)
        x, y = [(p, 0), (p, h), (0, p), (w, p)][side]
        md.ellipse([x - r, y - r, x + r, y + r], fill=0)
    im.putalpha(ImageChops.multiply(im.getchannel("A"), mask))
    return im

# ── 먹 붓 아이콘 ─────────────────────────────────────────
def ink_icon(svg, size=256, col="#231a14", seed=0):
    tmp = "/tmp/_icon.png"
    subprocess.run(["rsvg-convert", "-w", str(size), "-h", str(size), svg, "-o", tmp], check=True)
    im = Image.open(tmp).convert("RGBA")
    a = np.asarray(im)
    # game-icons: 검은 배경 사각형 + 흰 그림 → 흰 부분만 사용
    lum = a[..., :3].mean(axis=2) * (a[..., 3] / 255.0)
    alpha = Image.fromarray(np.clip(lum, 0, 255).astype(np.uint8))
    r = np.random.default_rng(seed)
    alpha = alpha.filter(ImageFilter.GaussianBlur(1.6))
    n = Image.fromarray((r.random((size, size)) * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.2))
    an = np.asarray(alpha).astype(np.float32) + (np.asarray(n).astype(np.float32) - 128) * 0.9
    an = np.clip((an - 90) * 2.4, 0, 255)
    # 마른 붓 결
    streak = Image.fromarray((r.random((size // 6, size)) * 255).astype(np.uint8)).resize((size, size)).filter(ImageFilter.GaussianBlur(0.8))
    an *= (0.82 + 0.18 * np.asarray(streak).astype(np.float32) / 255.0)
    out = Image.new("RGBA", (size, size), C(col))
    out.putalpha(Image.fromarray(an.astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.5)))
    return out

def seal(size, text_icon=None):
    im = Image.new("RGBA", (size, size), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    d.rounded_rectangle([4, 4, size - 5, size - 5], size // 10, outline=C("#b8352f"), width=max(3, size // 16))
    rough = Image.fromarray((np.random.default_rng(3).random((size, size)) * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1))
    a = np.asarray(im.getchannel("A")).astype(np.float32) * (np.asarray(rough) > 60)
    im.putalpha(Image.fromarray(a.astype(np.uint8)))
    return im

# ── 엽전 칸 표식 ─────────────────────────────────────────
def yeopjeon(size, metal=("#d8b260", "#8a6420"), hole="#2a1d1a", mark=None):
    im = Image.new("RGBA", (size, size), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    d.ellipse([2, 6, size - 3, size - 1], fill=(30, 15, 5, 120))
    yy, xx = np.mgrid[:size, :size]
    v = 1 - (xx + yy) / (2 * size)
    hi, lo = np.array(C(metal[0])[:3]), np.array(C(metal[1])[:3])
    g = np.zeros((size, size, 4), np.uint8); g[..., :3] = (lo + (hi - lo) * np.clip(v * 1.5, 0, 1)[..., None]).astype(np.uint8); g[..., 3] = 255
    mask = Image.new("L", (size, size), 0); ImageDraw.Draw(mask).ellipse([2, 2, size - 3, size - 5], fill=255)
    im.paste(Image.fromarray(g), (0, 0), mask)
    d.ellipse([2, 2, size - 3, size - 5], outline=C(metal[1]), width=max(2, size // 22))
    d.ellipse([size * 0.14, size * 0.13, size * 0.86, size * 0.82], outline=C(metal[1], 160), width=max(1, size // 40))
    hs = size * 0.13; cx, cy = size / 2, size / 2 - 1
    d.rectangle([cx - hs, cy - hs, cx + hs, cy + hs], fill=C(hole), outline=C(metal[1]), width=2)
    return im

def main():
    hanji = make_hanji(1024)
    vignette(hanji, 0.25).save(os.path.join(UI, "hanji.png"))
    make_hanji(1024, "#e9dab8", seed=4).save(os.path.join(UI, "hanji_dark.png"))
    frame(320, 320, 30, 72, hanji).save(os.path.join(UI, "panel.png"))
    frame(220, 140, 12, 34, hanji, inner_line=False).save(os.path.join(UI, "button.png"))
    frame(220, 140, 12, 34, make_hanji(512, "#d9c296", 7), inner_line=False).save(os.path.join(UI, "button_pressed.png"))
    frame(320, 200, 16, 44, hanji, wood="Wood051", inner_line=False, hanji_col="#4a2c18").save(os.path.join(UI, "bar.png"))
    plaque(200, 80).save(os.path.join(UI, "plaque.png"))
    sangso(360, 600, hanji).save(os.path.join(UI, "sangso.png"))
    sangso(360, 600, make_hanji(1024, "#ead39a", seed=9), (150, 90, 20)).save(os.path.join(UI, "sangso_gold.png"))
    sangso(360, 600, make_hanji(1024, "#ecc4b4", seed=10), (150, 30, 30)).save(os.path.join(UI, "sangso_red.png"))
    yeopjeon(96).save(os.path.join(UI, "node.png"))
    yeopjeon(96, ("#e0705a", "#7a1e16")).save(os.path.join(UI, "node_enemy.png"))
    yeopjeon(120, ("#f6e09a", "#a07818"), "#9a2c22").save(os.path.join(UI, "node_goal.png"))
    yeopjeon(96, ("#a8b8a0", "#4a5a40")).save(os.path.join(UI, "node_done.png"))
    yeopjeon(96, ("#9fd0b0", "#2e6a4a")).save(os.path.join(UI, "node_buff.png"))
    yeopjeon(96, ("#a890b8", "#4a2e5a")).save(os.path.join(UI, "node_debuff.png"))
    yeopjeon(96, ("#9aa8c8", "#2e3a6a")).save(os.path.join(UI, "node_story.png"))

    ICONS = {
        "jumeok": "skoll__fist.svg", "baldda": "delapouite__high-kick.svg", "pum": "willdabeast__round-shield.svg",
        "gyeot": "lorc__punch-blast.svg", "gochu": "delapouite__chili-pepper.svg", "nalchi": "darkzaitzev__robber-hand.svg",
        "yak": "lorc__round-bottom-flask.svg", "step": "lorc__footprint.svg", "talk": "lorc__conversation.svg",
        "item": "delapouite__mortar.svg", "shop": "delapouite__shop.svg", "goal": "delapouite__house.svg",
        "coin": "delapouite__two-coins.svg", "bag": "lorc__scroll-unfurled.svg", "pojol": "lorc__spear-hook.svg",
        "walpae": "skoll__spiked-bat.svg", "lantern": "lorc__paper-lantern.svg",
        "buff": "lorc__sun.svg", "debuff": "lorc__moon.svg", "trap": "lorc__foot-trip.svg",
        "rest": "delapouite__tavern-sign.svg", "story": "delapouite__scroll-quill.svg", "potion": "lorc__corked-tube.svg",
    }
    for k, (name, fn) in enumerate(ICONS.items()):
        col = "#a8261c" if name in ("gochu", "pojol", "walpae", "trap") else ("#2e6a4a" if name == "buff" else ("#4a2e5a" if name == "debuff" else "#231a14"))
        ink_icon(os.path.join(RAW, "icons", fn), 256, col, seed=k).save(os.path.join(UI, "icons", name + ".png"))

    # 보드: 수선전도(首善全圖)
    m = Image.open(os.path.join(RAW, "maps", "Suseonjeondo.jpg.jpg")).convert("RGB")
    crop = m.crop((150, 560, 1720, 2600))      # 도성 안쪽 ~ 남산
    crop = ImageEnhance.Color(crop).enhance(1.15)
    crop = Image.blend(crop, tint(crop, C("#e8d4a8")), 0.35)
    crop = crop.resize((1400, round(1400 * crop.height / crop.width)), Image.LANCZOS)
    vignette(crop, 0.5, (70, 45, 20)).convert("RGB").save(os.path.join(UI, "board_map.jpg"), quality=88)
    print("ui done", crop.size)

def make_board_path():
    """수선전도 위 이동 경로: 북촌 약방 → 종로(운종가) → 청계천 → 남산 아래 별채 (0~1 좌표)"""
    way = [(0.56, 0.13), (0.34, 0.17), (0.16, 0.27), (0.30, 0.38), (0.56, 0.40), (0.84, 0.44), (0.86, 0.55),
           (0.62, 0.58), (0.38, 0.56), (0.13, 0.60), (0.14, 0.72), (0.38, 0.77), (0.66, 0.74), (0.62, 0.86)]
    seg, total = [], 0.0
    for a, b in zip(way, way[1:]):
        L = math.dist(a, b); seg.append((a, b, L)); total += L
    n = 24; nodes = []
    for i in range(n):
        t = total * i / (n - 1)
        for a, b, L in seg:
            if t <= L + 1e-9 or (a, b, L) == seg[-1]:
                f = min(1.0, t / L)
                nodes.append((round(a[0] + (b[0] - a[0]) * f, 4), round(a[1] + (b[1] - a[1]) * f, 4))); break
            t -= L
    types = ["empty"] * n
    types[0] = "start"; types[-1] = "goal"
    for i in (5, 15): types[i] = "walpae"
    for i in (10, 19): types[i] = "pojol"
    for i in (3, 8, 13, 17): types[i] = "talk"
    for i in (7, 12, 21): types[i] = "item"
    types[11] = "shop"
    with open(os.path.join(ROOT, "assets", "data", "board1.json"), "w", encoding="utf-8") as f:
        json.dump({"map": "board_map.jpg", "nodes": [{"x": x, "y": y, "type": t} for (x, y), t in zip(nodes, types)]},
                  f, ensure_ascii=False, indent=1)

if __name__ == "__main__":
    main()
