# 작은 맵(스테이지) 생성: 쿼터뷰 격자 위 지그재그 길 + 감시꾼·함정·약초
import json, os, random

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "data", "stages")
os.makedirs(OUT, exist_ok=True)

def make(sid, name, tile, bg, length, seed, watchers=2, blockers=1, spikes=2, herbs=3, events=None, boss=None):
    r = random.Random(seed)
    path = [(0, 0)]
    d = r.choice([0, 1])
    while len(path) < length:
        run = r.randint(2, 4)
        dx, dy = ((-1, 0), (0, -1))[d]
        for _ in range(run):
            if len(path) >= length:
                break
            x, y = path[-1]; path.append((x + dx, y + dy))
        d = 1 - d
    n = len(path)
    types = ["empty"] * n
    types[0] = "start"; types[-1] = "goal"
    free = list(range(3, n - 2))
    r.shuffle(free)
    used = set()
    def take(cond=lambda i: True):
        for i in free:
            if i not in used and cond(i) and all(abs(i - u) > 1 for u in used):
                used.add(i); return i
        for i in free:
            if i not in used:
                used.add(i); return i
    tiles = [{"x": x, "y": y, "type": t} for (x, y), t in zip(path, types)]
    if boss:
        i = n - 5; used.add(i); tiles[i].update({"type": "boss", **boss})
    for _ in range(blockers):
        i = take(); tiles[i]["type"] = r.choice(["walpae", "pojol"])
    for ev in (events or []):
        i = take(); tiles[i]["type"] = ev
    for _ in range(spikes):
        i = take(); tiles[i]["type"] = "spike"
    herb_at = []
    for _ in range(herbs):
        i = take(); tiles[i]["herb"] = True; herb_at.append(i)
    # 감시꾼: 길 옆 칸에 서서 길 2~3칸을 붉게 지킨다 (그 칸에서 멈추면 싸움)
    onpath = set(path); guards = []
    cand = list(range(4, n - 3)); r.shuffle(cand)
    for i in cand:
        if len(guards) >= watchers:
            break
        if any(abs(i - g["at"]) < 5 for g in guards):
            continue
        x, y = path[i]
        side = [(x + 1, y), (x, y + 1), (x - 1, y), (x, y - 1)]
        side = [p for p in side if p not in onpath]
        if not side:
            continue
        gx, gy = r.choice(side)
        zone = [k for k in range(max(1, i - 1), min(n - 1, i + 2)) if tiles[k]["type"] in ("empty", "spike") or tiles[k].get("herb")]
        guards.append({"x": gx, "y": gy, "at": i, "zone": zone, "kind": r.choice(["walpae", "pojol"])})
    turns = (n + 2) // 3 + 2
    data = {"id": sid, "name": name, "tile": tile, "bg": bg, "turns": turns, "tiles": tiles, "guards": guards}
    json.dump(data, open(os.path.join(OUT, sid + ".json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(sid, "tiles", n, "turns", turns, "guards", len(guards))

S = [
    ("s1_1", "운종가를 지나 도망치기", "stone", "jangteo", 22, 11, {"events": ["talk", "item"]}),
    ("s1_2", "문경새재 넘기", "dirt", "street_ink", 24, 12, {"events": ["talk", "buff", "debuff"]}),
    ("s1_3", "백운 노인 찾아가기", "grass", "byeolchae", 24, 13, {"events": ["rest", "trap", "talk"]}),
    ("s2_1", "검문소 피해 가기", "dirt", "street_ink", 22, 21, {"events": ["talk", "buff"], "watchers": 3}),
    ("s2_2", "열병 마을 지나기", "grass", "street_ink", 22, 22, {"events": ["shop", "debuff", "talk"]}),
    ("s2_3", "한양 약방으로", "stone", "yakbang", 24, 23, {"events": ["rest", "trap", "talk"], "blockers": 2}),
    ("s3_1", "청계천 약재 심부름", "wood", "stream", 22, 31, {"events": ["talk", "item", "buff"]}),
    ("s3_2", "종로 뒷골목", "stone", "alley", 24, 32, {"events": ["shop", "trap", "talk"], "watchers": 3}),
    ("s3_3", "남산 아래 결투", "dirt", "title", 24, 33, {"events": ["rest", "debuff"], "boss": {"battle": "seohwi2", "pre": "C3_BOSS", "post": "C3_BOSS_WIN"}}),
    ("s4_1", "비 오는 청계천", "stone", "stream", 22, 41, {"events": ["talk", "debuff", "item"]}),
    ("s4_2", "군산 포구 뒤지기", "wood", "street_ink", 24, 42, {"events": ["shop", "trap", "talk"], "watchers": 3}),
    ("s4_3", "도적의 소굴 찾아가기", "cave", "vault", 26, 43, {"events": ["rest", "trap", "buff"], "blockers": 2, "spikes": 3}),
    ("s5_1", "내의원 환자 돌보기", "palace", "palace", 20, 51, {"events": ["talk", "item"], "watchers": 1, "blockers": 0}),
    ("s5_2", "종로에서 약재 구하기", "stone", "jangteo", 22, 52, {"events": ["shop", "talk", "debuff"]}),
    ("s5_3", "궁궐 담장 아래", "palace", "palace", 22, 53, {"events": ["rest", "buff"], "watchers": 3}),
    ("s5_4", "허 의원 약방으로", "stone", "yakbang", 24, 54, {"events": ["trap", "item", "talk"], "blockers": 2, "spikes": 3}),
    ("s7_1", "역병 도는 마을", "brick", "holland", 22, 71, {"events": ["talk", "item", "talk"]}),
    ("s7_2", "풍차 언덕 약초밭", "grass", "holland", 24, 72, {"events": ["rest", "shop", "debuff"], "herbs": 4}),
]
for sid, name, tile, bg, ln, seed, kw in S:
    make(sid, name, tile, bg, ln, seed, **kw)
