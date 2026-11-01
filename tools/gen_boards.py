# 제2~5장 보드 칸 배치 생성 (제1장 board1.json 은 tools/gen_board.py)
import json, math, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def layout(way, n):
    seg, total = [], 0.0
    for a, b in zip(way, way[1:]):
        L = math.dist(a, b); seg.append((a, b, L)); total += L
    pts = []
    for i in range(n):
        t = total * i / (n - 1)
        for a, b, L in seg:
            if t <= L + 1e-9 or (a, b, L) == seg[-1]:
                f = min(1.0, t / L)
                pts.append((a[0] + (b[0] - a[0]) * f, a[1] + (b[1] - a[1]) * f)); break
            t -= L
    return pts, total

def build(name, mapfile, size, scale, way, n, special, places):
    pts, total = layout(way, n)
    W, H = size
    types = ["empty"] * n
    types[0] = "start"; types[-1] = "goal"
    nodes = []
    for i, (x, y) in enumerate(pts):
        node = {"x": round(x / W, 4), "y": round(y / H, 4), "type": types[i]}
        if i in special:
            v = special[i]
            if isinstance(v, dict):
                node.update(v)
            else:
                node["type"] = v
        if i in places:
            node["name"] = places[i]
        nodes.append(node)
    with open(os.path.join(ROOT, "assets", "data", name + ".json"), "w", encoding="utf-8") as f:
        json.dump({"map": mapfile, "scale": scale, "nodes": nodes}, f, ensure_ascii=False, indent=1)
    print(name, "nodes", n, "spacing(map px)", round(total / (n - 1), 1), "screen", round(total / (n - 1) * scale, 1))

KOREA = ("korea_map.jpg", (1024, 1536))
HANYANG = ("board_map.jpg", (1400, 1819))

# 제2장: 화엄골 → (경상 내륙·충청) → 한양
build("board2", *KOREA, 1.9,
      [(540, 1208), (600, 1180), (650, 1140), (690, 1090), (650, 1040), (590, 1010), (540, 1040), (480, 1030),
       (430, 990), (470, 940), (540, 930), (600, 900), (580, 850), (520, 860), (470, 880), (430, 850), (460, 800), (507, 742)],
      40,
      {3: "talk", 5: "item", 7: "walpae", 9: "buff", 11: {"type": "story", "sid": "C2_DOGYEOL"}, 13: "trap", 15: "pojol",
       17: "rest", 19: "debuff", 21: "talk", 23: {"type": "story", "sid": "C2_PLAGUE"}, 25: "shop", 27: "walpae", 29: "buff",
       31: "pojol", 33: "trap", 34: "talk", 36: "item", 37: "walpae"},
      {0: "지리산 화엄골", 6: "함양", 11: "상주 검문소", 18: "청주", 23: "열병 마을", 25: "천안 장터", 33: "수원", 39: "한양 약방"})

# 제3장: 한양 안 (수선전도) — 청계천 소굴에서 출발해 도성을 한 바퀴
build("board3", *HANYANG, 1.25,
      [(790, 900), (620, 880), (420, 860), (230, 760), (260, 560), (460, 470), (680, 420), (900, 380), (1120, 470),
       (1210, 680), (1150, 900), (1020, 1080), (800, 1150), (560, 1120), (360, 1250), (520, 1400), (780, 1380), (900, 1180), (790, 960)],
      42,
      {2: "talk", 4: "item", 6: "walpae", 8: {"type": "story", "sid": "C3_DOGYEOL"}, 10: "buff", 12: "pojol", 14: "talk",
       16: "trap", 18: "shop", 20: "walpae", 22: {"type": "story", "sid": "C3_TRUTH"}, 24: "debuff", 26: "talk", 28: "pojol",
       30: "rest", 32: "item", 34: {"type": "boss", "battle": "seohwi2", "pre": "C3_BOSS", "post": "C3_BOSS_WIN"}, 36: "walpae",
       38: "talk", 39: "trap"},
      {0: "청계천 소굴", 5: "서대문", 9: "경복궁 앞", 13: "창덕궁 앞", 18: "종로 시전", 22: "종로 뒷골목", 30: "남대문 주막",
       34: "남산 아래", 41: "왈패 소굴"})

# 제4장: 한양 → 서해안 길 → 화엄골
build("board4", *KOREA, 1.9,
      [(507, 742), (450, 770), (400, 800), (360, 850), (395, 900), (360, 950), (330, 1000), (380, 1030), (350, 1080),
       (330, 1130), (380, 1160), (430, 1140), (470, 1180), (420, 1230), (470, 1250), (540, 1208)],
      34,
      {2: {"type": "story", "sid": "C4_STREAM"}, 4: "talk", 6: "walpae", 8: "buff", 10: "pojol", 12: "trap",
       14: {"type": "story", "sid": "C4_CLUE"}, 16: "rest", 18: "walpae", 20: "talk", 22: "debuff", 23: "shop", 25: "trap",
       27: "walpae", 29: "item", 31: "buff"},
      {0: "한양", 2: "청계천", 8: "아산만", 14: "군산 포구", 20: "나주", 27: "구례", 33: "화엄골 지하"})

# 제5장: 경복궁 → 한양 곳곳 약재 → 허 의원 약방
build("board5", *HANYANG, 1.25,
      [(640, 330), (460, 420), (300, 560), (380, 760), (600, 700), (820, 640), (1050, 560), (1180, 760), (1060, 960),
       (840, 1000), (620, 1000), (420, 1080), (300, 1280), (520, 1420), (760, 1330), (700, 1150)],
      38,
      {2: "talk", 4: "item", 6: "walpae", 8: {"type": "story", "sid": "C5_SEOHWI"}, 10: "buff", 12: "pojol", 14: "talk",
       16: "trap", 18: "shop", 20: "walpae", 22: "rest", 24: {"type": "story", "sid": "C5_DOGYEOL"}, 26: "debuff", 28: "item",
       30: "walpae", 32: "talk", 34: "pojol", 35: "buff"},
      {0: "경복궁 내의원", 8: "종로", 13: "창경궁 앞", 18: "운종가", 24: "궁궐 담장", 30: "남산", 37: "허 의원 약방"})
