# 한양 숨바꼭질 도트 그래픽 생성기
# 실행: python3 tools/gen_art.py  (assets/art, assets/data 에 결과 저장)
import json, math, os, random
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART = os.path.join(ROOT, "assets", "art")
DATA = os.path.join(ROOT, "assets", "data")
os.makedirs(ART, exist_ok=True)
os.makedirs(DATA, exist_ok=True)

def P(img, x, y, col):
    if 0 <= x < img.width and 0 <= y < img.height:
        img.putpixel((x, y), C(col) if isinstance(col, str) else col)

def C(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) + (255,)

# ---------------------------------------------------------------- 캐릭터 (좌우 대칭: 왼쪽 절반만 그리고 거울 복사)
def sprite(half_rows, pal, width=24, height=32):
    rows = []
    for r in half_rows:
        r = r.ljust(width // 2, ".")
        rows.append(r + r[::-1])
    while len(rows) < height:
        rows.insert(0, "." * width)
    img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch != "." and ch in pal:
                P(img, x, y, pal[ch])
    return img

BASE = {"k": "#241a18", "s": "#f2c9a0", "S": "#d39f7c", "e": "#1e1a22", "b": "#1e1a22",
        "p": "#e8968a", "t": "#b89a64", "w": "#efe8d8", "W": "#c8bfae"}

YEONI = [
    "............",
    "..........kk",
    ".........khh",
    ".........khh",
    "......kkkkhh",
    "....kkhhhhhh",
    "...kHHHHHHHH",
    "....kkkkkkkk",
    "......kbbbbb",
    ".....kbbssss",
    ".....kbsssss",
    ".....ksseSss",
    ".....kspssss",
    "......kssssS",
    ".......kksss",
    ".........kss",
    ".......kwwww",
    "......kwwwww",
    ".....kwwwwwr",
    "....kWwwwwwr",
    "....kWwwwwww",
    "....ksWwwwww",
    ".....kknnnnn",
    "......knnnnN",
    "......knnnnN",
    "......knnnNk",
    "......knnnNk",
    "......kwwwk.",
    "......kWwwk.",
    ".....ktttk..",
    ".....kkkkk..",
]
YEONI_PAL = dict(BASE, h="#d4ae62", H="#9a7a3c", r="#b8352f", n="#3b4a7a", N="#2a355a")

POJOL = [
    "...........y",
    "..........yy",
    "........kkff",
    ".......kfFff",
    "......kfffff",
    "...kkkkfffff",
    "..kFFFFFFFFF",
    "...kkkkkkkkk",
    "......kbbbbb",
    ".....kbsssss",
    ".....kseeSss",
    ".....kssssss",
    ".....kssbbbs",
    "......ksssss",
    ".......kkkss",
    "......kcccww",
    ".....kcccccw",
    "....kccccccw",
    "...kcCcccccw",
    "...kcCrrrrrr",
    "...ksCcccccc",
    "....kCcccccc",
    "....kCcccccc",
    ".....knnnnnn",
    ".....knnnnnn",
    ".....knnnnNk",
    ".....knnnnNk",
    ".....kfffk..",
    ".....kfffk..",
    ".....kfffk..",
    ".....kkkkk..",
]
POJOL_PAL = dict(BASE, f="#24222b", F="#3a3746", y="#c0392b", c="#2c3e66", C="#1f2c4a",
                 r="#a83232", n="#d8d2c4", N="#a9a294")

WALPAE = [
    "..........kk",
    ".........kbb",
    "..........kb",
    "......kkkkbb",
    ".....kbbbbbb",
    ".....kgggggg",
    ".....kbsssss",
    ".....kseeSss",
    ".....kssssss",
    ".....ksSbbSs",
    "......kSssss",
    ".......kkSss",
    ".....kkvvsss",
    "...kkvvvvsss",
    "..kvvVvvvsss",
    "..kvVvvvvsSs",
    "..ksvvvvvsss",
    "..kskvvvvsss",
    "...k.kgggggg",
    ".....knnnnnn",
    ".....knnnnnn",
    ".....knnnnNk",
    ".....knnnnNk",
    ".....knnnnNk",
    ".....kwwwwk.",
    ".....kwwwwk.",
    "....ktttttk.",
    "....kkkkkkk.",
]
WALPAE_PAL = dict(BASE, g="#7a7068", v="#6b4a32", V="#4d3322", n="#8a7d6a", N="#665b4c")

def save(img, name, scale=1):
    if scale != 1:
        img = img.resize((img.width * scale, img.height * scale), Image.NEAREST)
    img.save(os.path.join(ART, name + ".png"))

yeoni = sprite(YEONI, YEONI_PAL)
save(yeoni, "yeoni")
pojol = sprite(POJOL, POJOL_PAL)
# 포졸의 창
for y in range(2, 30):
    pojol.putpixel((1, y), C("#6e4a2e"))
for (x, y) in [(1, 0), (1, 1), (0, 1), (2, 1)]:
    pojol.putpixel((x, y), C("#c9c9d1"))
for (x, y) in [(0, 3), (1, 3), (2, 3), (1, 4)]:
    pojol.putpixel((x, y), C("#c0392b"))
save(pojol, "pojol")
save(sprite(WALPAE, WALPAE_PAL), "walpae")

# 보드용 작은 말(12x16)
MINI = [
    "....kk", "...khh", ".kkhhh", "kHHHHH", ".kkkkk", "..kbbs", "..kses", "..ksss",
    "...kss", "..kwww", ".kswwr", "..kwww", "..knnn", "..knnk", "..ktk.", "..kk..",
]
save(sprite(MINI, YEONI_PAL, 12, 16), "token_yeoni")
save(sprite(MINI, dict(BASE, h="#24222b", H="#3a3746", r="#c0392b", w="#2c3e66", n="#d8d2c4"), 12, 16), "token_pojol")
save(sprite(MINI, dict(BASE, h="#1e1a22", H="#7a7068", r="#4d3322", w="#6b4a32", n="#8a7d6a"), 12, 16), "token_walpae")

# ---------------------------------------------------------------- 작은 아이콘
def icon(rows, pal):
    h = len(rows); w = max(len(r) for r in rows)
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    for y, r in enumerate(rows):
        for x, ch in enumerate(r):
            if ch in pal:
                P(img, x, y, pal[ch])
    return img

ICONS = {
    "card_jumeok": (["................", "....kkkkkk......", "...kssssssk.....", "..kssSsSsSsk....",
                     "..kssSsSsSsk....", "..kssssssssk....", "..kkssssssssk...", "..kSkkssssssk...",
                     "...kSSkssssk....", "....kSSSSssk....", ".....kkSSSk.....", "......kwwwk.....",
                     "......kwwwk.....", "......kwwwk.....", "......kkkkk.....", "................"],
                    {"k": "#241a18", "s": "#f2c9a0", "S": "#d39f7c", "w": "#efe8d8"}),
    "card_baldda": (["................", "..........kk....", ".........knnk...", "........knnnk...",
                     ".......knnnk....", "......knnnk.....", ".....knnnk......", "....kwwwk.......",
                     "...kwwwk........", "..ktttttkk......", ".kttttttttk.....", ".kkkkkkkkkk.....",
                     "................", "..y..y..........", "...yy...........", "................"],
                    {"k": "#241a18", "n": "#3b4a7a", "w": "#efe8d8", "t": "#b89a64", "y": "#f0c040"}),
    "card_pum": (["................", "......kkkk......", "....kkbbbbkk....", "...kbbBBBBbbk...",
                  "..kbBBbbbbBBbk..", "..kbBbbyybbBbk..", "..kbBbyrrybBbk..", "..kbBbyrrybBbk..",
                  "..kbBbbyybbBbk..", "..kbBBbbbbBBbk..", "...kbbBBBBbbk...", "....kkbbbbkk....",
                  "......kkkk......", "................", "................", "................"],
                 {"k": "#241a18", "b": "#8a5a34", "B": "#b07a48", "y": "#d4a84a", "r": "#b8352f"}),
    "card_gyeot": (["................", "..........k.....", "..........kk....", "..kkkkkkkkkyk...",
                    "..kyyyyyyyyyyk..", "..kkkkkkkkkyk...", "..........kk....", "..........k.....",
                    "...ksssk........", "..kssssskkk.....", "..kSssssssSk....", "...kSSssssSk....",
                    "....kkSSSSk.....", "......kkkk......", "................", "................"],
                   {"k": "#241a18", "y": "#f0c040", "s": "#f2c9a0", "S": "#d39f7c"}),
    "card_gochu": (["................", "......kgk.......", ".......gk.......", "......krk.......",
                    ".....krrrk......", ".....krRrk......", "....krrRrk......", "....krrRrk......",
                    "...krrRrk.......", "...krRrk..r.....", "..krrrk..r.r....", "..krrk....r.r...",
                    "...kk......r....", "................", "................", "................"],
                   {"k": "#241a18", "g": "#3f7548", "r": "#c0392b", "R": "#e8604f"}),
    "card_yak": (["................", "......kkkk......", "......kcck......", ".......kk.......",
                  "......kwwk......", ".....kwwwwk.....", "....kwwwwwwk....", "...kwgggggwwk...",
                  "...kggGggggwk...", "...kgggggGgwk...", "...kggggggggk...", "....kggggggk....",
                  ".....kkkkkk.....", "................", "................", "................"],
                 {"k": "#241a18", "c": "#8a5a34", "w": "#d9e8ee", "g": "#4f9a6a", "G": "#8fd0a0"}),
    "card_step": (["................", ".....kkkk.......", "....ktttTk......", "....kttttTk.....",
                   "....kttttTk.....", ".....kttTk......", ".....kttTk......", ".....kttTk......",
                   "....kttttTk.....", "....kttttTk.....", "....ktttttTk....", ".....kkkkkk.....",
                   "................", "................", "................", "................"],
                  {"k": "#241a18", "t": "#c9a35a", "T": "#9a7a3c"}),
    "node_talk": (["............", ".kkkkkkkkkk.", "kwwwwwwwwwwk", "kwkkwkkwkkwk", "kwwwwwwwwwwk",
                   "kwkkkwkkkwwk", "kwwwwwwwwwwk", ".kkkwwkkkkk.", "...kwk......", "...kk.......", "............", "............"],
                  {"k": "#241a18", "w": "#efe3c8"}),
    "node_item": (["............", ".....kk.....", "....kggk....", "...kgGgk.kk.", "...kgGgkkggk",
                   "....kgGkgGgk", ".kk..kkgGgk.", "kggkkgk.kk..", "kgGGgk......", ".kggk.......", "..kk........", "............"],
                  {"k": "#241a18", "g": "#3f7548", "G": "#7fbf6a"}),
    "node_goal": (["............", "..kkkkkkkk..", ".kRRRRRRRRk.", "kkkkkkkkkkkk", "..kw....wk..",
                   "..kw....wk..", "..kw....wk..", "..kw....wk..", "..kw....wk..", ".kkkk..kkkk.", "............", "............"],
                  {"k": "#241a18", "R": "#b8352f", "w": "#8a5a34"}),
}
for name, (rows, pal) in ICONS.items():
    save(icon(rows, pal), name)

# ---------------------------------------------------------------- 배경 공용 그리기
def rect(d, x0, y0, x1, y1, col):
    if x1 < x0 or y1 < y0:
        return
    d.rectangle([x0, y0, x1, y1], fill=C(col))

def giwa_house(img, d, x, y, w=30, big=False):
    roof_h = 10 if not big else 13
    wall_h = 10 if not big else 13
    # 그림자
    rect(d, x + 2, y + roof_h + wall_h, x + w + 1, y + roof_h + wall_h + 2, "#7d6748")
    # 벽
    rect(d, x + 3, y + roof_h, x + w - 4, y + roof_h + wall_h - 1, "#e6ddc6")
    rect(d, x + 3, y + roof_h + wall_h - 2, x + w - 4, y + roof_h + wall_h, "#8a8378")
    for px in range(x + 3, x + w - 3, 7):
        rect(d, px, y + roof_h, px + 1, y + roof_h + wall_h - 2, "#6e4a2e")
    # 문 (창살)
    cx = x + w // 2 - 3
    rect(d, cx, y + roof_h + 2, cx + 6, y + roof_h + wall_h - 3, "#8a5d3a")
    for gx in range(cx + 1, cx + 6, 2):
        for gy in range(y + roof_h + 3, y + roof_h + wall_h - 3, 2):
            P(img, gx, gy, "#e8d6a8")
    # 지붕: 아래로 갈수록 넓어지고 양끝 처마가 살짝 들림
    for i in range(roof_h):
        inset = max(0, (roof_h - i) // 2)
        col = "#4a5160" if i % 2 else "#5d6577"
        rect(d, x + inset, y + i, x + w - 1 - inset, y + i, col)
    rect(d, x + roof_h // 2 - 1, y, x + w - roof_h // 2, y + 1, "#2c313b")
    for i in range(3):
        P(img, x + i, y + roof_h - 3 + i, "#2c313b")
        P(img, x + w - 1 - i, y + roof_h - 3 + i, "#2c313b")
    rect(d, x + 1, y + roof_h - 1, x + w - 2, y + roof_h - 1, "#2c313b")

def choga_house(img, d, x, y, w=24):
    rh, wh = 9, 9
    rect(d, x + 2, y + rh + wh, x + w + 1, y + rh + wh + 2, "#7d6748")
    rect(d, x + 3, y + rh, x + w - 4, y + rh + wh - 1, "#d8c49c")
    for px in (x + 3, x + w - 5):
        rect(d, px, y + rh, px + 1, y + rh + wh - 1, "#6e4a2e")
    rect(d, x + w // 2 - 2, y + rh + 2, x + w // 2 + 2, y + rh + wh - 1, "#5a3b24")
    for i in range(rh):
        inset = max(0, int((rh - i) * 0.9) - 2)
        col = "#c9a557" if (i % 3) else "#a8853f"
        rect(d, x + inset, y + i, x + w - 1 - inset, y + i, col)
    rect(d, x + 1, y + rh - 1, x + w - 2, y + rh - 1, "#8a6a30")

def pine(img, d, x, y):
    rect(d, x + 5, y + 11, x + 6, y + 15, "#6b4a2e")
    layers = [(0, 2, 1), (3, 4, 3), (6, 6, 5), (9, 7, 6)]
    for (oy, hw, _) in layers:
        for i in range(3):
            rect(d, x + 6 - hw + i, y + oy + i, x + 5 + hw - i, y + oy + i, "#2f5a3a" if i else "#3f7548")

def stone_wall(img, d, x, y, w, rnd):
    rect(d, x, y, x + w, y + 4, "#3b3936")
    for row in range(2):
        px = x + (row * 2)
        while px < x + w:
            sw = rnd.randint(2, 4)
            rect(d, px, y + row * 2, min(px + sw - 1, x + w), y + row * 2 + 1, rnd.choice(["#7d7a75", "#6d6a66", "#8a8680"]))
            px += sw + 1

# ---------------------------------------------------------------- 보드 지도 (180x390)
def make_board():
    W, H = 180, 390
    rnd = random.Random(7)
    img = Image.new("RGBA", (W, H), C("#a88f68"))
    d = ImageDraw.Draw(img)
    for _ in range(1600):
        x, y = rnd.randrange(W), rnd.randrange(H)
        P(img, x, y, rnd.choice(["#9a8160", "#b39a72", "#94795a"]))
    # 남산
    for x in range(W):
        top = int(26 + 10 * math.sin(x / 23.0) + 6 * math.sin(x / 9.0))
        rect(d, x, 0, x, top, "#2f5537")
        rect(d, x, top - 3, x, top, "#3d6b45")
    for _ in range(28):
        pine(img, d, rnd.randrange(-4, W - 8), rnd.randrange(-6, 18))

    way = [(90, 318), (44, 308), (26, 280), (52, 260), (104, 264), (150, 252), (158, 222),
           (126, 204), (76, 208), (32, 192), (26, 160), (58, 144), (108, 148), (150, 136),
           (158, 106), (122, 88), (90, 74), (90, 58)]
    # 위아래 UI에 가리지 않도록 경로를 화면 가운데로 압축
    way = [(x, round(70 + (y - 58) * 220 / 260)) for (x, y) in way]
    # 경로 길이에 따라 칸 배치
    seg = []
    total = 0.0
    for a, b in zip(way, way[1:]):
        L = math.dist(a, b); seg.append((a, b, L)); total += L
    n = 24
    nodes = []
    for i in range(n):
        t = total * i / (n - 1)
        for a, b, L in seg:
            if t <= L or (a, b, L) == seg[-1]:
                f = min(1.0, t / L)
                nodes.append((round(a[0] + (b[0] - a[0]) * f), round(a[1] + (b[1] - a[1]) * f)))
                break
            t -= L

    def near_path(px, py, m):
        for a, b, L in seg:
            ax, ay = a; bx, by = b
            f = max(0, min(1, ((px - ax) * (bx - ax) + (py - ay) * (by - ay)) / (L * L)))
            if math.dist((px, py), (ax + (bx - ax) * f, ay + (by - ay) * f)) < m:
                return True
        return False

    # 집·나무 배치
    placed = []
    things = []
    cands = [(x, y) for x in range(-6, W - 10, 5) for y in range(36, 372, 5)]
    rnd.shuffle(cands)
    for (x, y) in cands:
        kind = rnd.choice(["giwa", "giwa", "choga", "pine", "pine", "wall"])
        w, h = {"giwa": (30, 22), "choga": (24, 20), "pine": (12, 16), "wall": (22, 5)}[kind]
        box = (x - 2, y - 2, x + w + 2, y + h + 4)
        if any(not (box[2] < p[0] or box[0] > p[2] or box[3] < p[1] or box[1] > p[3]) for p in placed):
            continue
        pts = [(box[0], box[1]), (box[2], box[1]), (box[0], box[3]), (box[2], box[3]),
               ((box[0] + box[2]) // 2, (box[1] + box[3]) // 2), ((box[0] + box[2]) // 2, box[3]), ((box[0] + box[2]) // 2, box[1])]
        if any(near_path(px, py, 9) for px, py in pts):
            continue
        if math.dist((x + w / 2, y + h / 2), (90, 48)) < 32:
            continue
        placed.append(box); things.append((y + h, kind, x, y))

    # 길 (돌길)
    for a, b, L in seg:
        steps = int(L)
        for s in range(steps + 1):
            px = a[0] + (b[0] - a[0]) * s / max(1, steps)
            py = a[1] + (b[1] - a[1]) * s / max(1, steps)
            d.ellipse([px - 6, py - 6, px + 6, py + 6], fill=C("#8c7a5a"))
    for a, b, L in seg:
        steps = int(L)
        for s in range(steps + 1):
            px = a[0] + (b[0] - a[0]) * s / max(1, steps)
            py = a[1] + (b[1] - a[1]) * s / max(1, steps)
            d.ellipse([px - 5, py - 5, px + 5, py + 5], fill=C("#cdbd9c"))
    for _ in range(900):
        x, y = rnd.randrange(W), rnd.randrange(H)
        if img.getpixel((x, y)) == C("#cdbd9c"):
            P(img, x, y, rnd.choice(["#b8a784", "#dccdb0"]))

    for _, kind, x, y in sorted(things):
        if kind == "giwa": giwa_house(img, d, x, y)
        elif kind == "choga": choga_house(img, d, x, y)
        elif kind == "pine": pine(img, d, x, y)
        else: stone_wall(img, d, x, y, 22, rnd)
    # 목적지: 허 의원의 별채
    giwa_house(img, d, 70, 30, w=40, big=True)
    stone_wall(img, d, 52, 60, 26, rnd)
    stone_wall(img, d, 102, 60, 26, rnd)
    img.save(os.path.join(ART, "board_map.png"))

    types = ["empty"] * n
    types[0] = "start"; types[-1] = "goal"
    for i in (5, 15): types[i] = "walpae"
    for i in (10, 19): types[i] = "pojol"
    for i in (3, 8, 13, 17): types[i] = "talk"
    for i in (7, 12, 21): types[i] = "item"
    with open(os.path.join(DATA, "board1.json"), "w", encoding="utf-8") as f:
        json.dump({"size": [W, H], "nodes": [{"x": x, "y": y, "type": t} for (x, y), t in zip(nodes, types)]},
                  f, ensure_ascii=False, indent=1)

# ---------------------------------------------------------------- 밤 골목 (전투 배경, 180x200)
def make_alley():
    W, H = 180, 200
    rnd = random.Random(3)
    img = Image.new("RGBA", (W, H), C("#1d2340"))
    d = ImageDraw.Draw(img)
    for y in range(0, 90):
        if y > 30: rect(d, 0, y, W, y, "#232a4a" if y < 60 else "#2a3254")
    for _ in range(40):
        P(img, rnd.randrange(W), rnd.randrange(70), "#c8cde0")
    d.ellipse([128, 12, 146, 30], fill=C("#efe6c0")); d.ellipse([132, 14, 148, 30], fill=C("#1d2340"))
    # 먼 지붕 실루엣
    for x0 in range(-10, W, 34):
        for i in range(12):
            rect(d, x0 + i // 2, 78 + i, x0 + 32 - i // 2, 78 + i, "#151a30")
    # 양쪽 돌담 + 지붕
    for side in (0, 1):
        for y in range(70, 175):
            depth = (y - 70) // 2
            x0 = 0 if side == 0 else W - 1 - (18 + depth)
            x1 = 18 + depth if side == 0 else W - 1
            rect(d, x0, y, x1, y, "#3b3936")
        for row in range(70, 175, 4):
            depth = (row - 70) // 2
            span = (0, 18 + depth) if side == 0 else (W - 1 - (18 + depth), W - 1)
            px = span[0] + (row // 4 % 2) * 2
            while px < span[1]:
                sw = rnd.randint(3, 6)
                rect(d, px, row, min(px + sw - 1, span[1]), row + 2, rnd.choice(["#5e5b57", "#53504c", "#68645f"]))
                px += sw + 1
        for i in range(14):
            y = 58 + i
            if side == 0: rect(d, 0, y, 30 + i * 2, y, "#2c313b" if i % 2 else "#3a4150")
            else: rect(d, W - 31 - i * 2, y, W, y, "#2c313b" if i % 2 else "#3a4150")
    # 바닥
    for y in range(120, H):
        rect(d, 0, y, W, y, "#4a3c30" if y % 3 else "#54453a")
    for y in range(120, 175):
        depth = (y - 70) // 2
        rect(d, 0, y, 18 + depth, y, "#3b3936")
        rect(d, W - 1 - (18 + depth), y, W, y, "#3b3936")
    d.ellipse([60, 160, 110, 172], fill=C("#2a3254")); d.ellipse([66, 162, 100, 169], fill=C("#36406a"))
    for _ in range(300):
        x, y = rnd.randrange(W), rnd.randrange(130, H)
        P(img, x, y, rnd.choice(["#3e3228", "#5c4c3e"]))
    # 등불
    for lx in (30, 150):
        rect(d, lx, 92, lx + 4, 100, "#e8d6a8"); rect(d, lx - 1, 91, lx + 5, 91, "#6e4a2e"); rect(d, lx - 1, 101, lx + 5, 101, "#6e4a2e")
    img.save(os.path.join(ART, "bg_alley.png"))

# ---------------------------------------------------------------- 약방 (스토리 배경, 180x200)
def make_yakbang():
    W, H = 180, 200
    rnd = random.Random(5)
    img = Image.new("RGBA", (W, H), C("#3a2a20"))
    d = ImageDraw.Draw(img)
    rect(d, 0, 0, W, 120, "#5a4030")
    # 약장
    rect(d, 10, 14, 120, 112, "#4a3020")
    for r in range(6):
        for c in range(7):
            x0, y0 = 13 + c * 15, 17 + r * 15
            rect(d, x0, y0, x0 + 13, y0 + 13, "#8a5a34")
            rect(d, x0, y0, x0 + 13, y0, "#a8744a")
            rect(d, x0 + 5, y0 + 6, x0 + 8, y0 + 7, "#d4a84a")
            if rnd.random() < 0.18:
                rect(d, x0 + 1, y0 + 9, x0 + 12, y0 + 13, "#2a1a12")
    # 창호지 창문과 달빛
    rect(d, 132, 20, 172, 80, "#6e4a2e")
    rect(d, 134, 22, 170, 78, "#cfd6e8")
    for gx in range(134, 171, 6): rect(d, gx, 22, gx, 78, "#6e4a2e")
    for gy in range(22, 79, 8): rect(d, 134, gy, 170, gy, "#6e4a2e")
    # 마루
    for y in range(120, H):
        rect(d, 0, y, W, y, "#7a5232" if (y // 6) % 2 else "#6d4a2c")
    for x in range(0, W, 30): rect(d, x, 120, x, H, "#4e331e")
    ov = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(ov).polygon([(134, 80), (170, 80), (150, 199), (96, 199)], fill=(207, 214, 232, 38))
    img.alpha_composite(ov)
    # 깨진 약병, 엎어진 약재
    for (x, y) in [(60, 150), (66, 154), (72, 148), (58, 158), (80, 156)]:
        rect(d, x, y, x + 2, y + 1, "#a9d4e0")
    for _ in range(40):
        P(img, rnd.randrange(40, 110), rnd.randrange(160, 185), rnd.choice(["#8a6a30", "#5a7a40", "#b8352f"]))
    rect(d, 128, 150, 140, 168, "#2a1a12"); rect(d, 130, 140, 138, 150, "#e8b04a"); rect(d, 132, 136, 136, 140, "#fff0b0")
    img.save(os.path.join(ART, "bg_yakbang.png"))

def make_icon():
    img = Image.new("RGBA", (64, 64), C("#2a1d1a"))
    t = sprite(MINI, YEONI_PAL, 12, 16).resize((36, 48), Image.NEAREST)
    img.alpha_composite(t, (14, 10))
    img.resize((192, 192), Image.NEAREST).save(os.path.join(ROOT, "icon.png"))

make_board(); make_alley(); make_yakbang(); make_icon()
print("done")
