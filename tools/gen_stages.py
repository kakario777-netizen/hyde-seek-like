# 작은 맵(스테이지) 생성: 쿼터뷰 격자 위 지그재그 길 + 감시꾼·함정·약초
import json, os, random

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "data", "stages")
os.makedirs(OUT, exist_ok=True)

def make(sid, name, tile, bg, length, seed, watchers=3, blockers=2, spikes=2, herbs=4, events=None, boss=None):
    length += 8   # 이로운 칸 4 + 해로운 칸 4 자리만큼 길을 늘림
    events = list(events or []) + ["buff"] * 4 + ["debuff"] * 4
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
        i = int(n * 0.62); used.add(i); tiles[i].update({"type": "boss", **boss})
    for _ in range(blockers):
        i = take(); tiles[i]["type"] = r.choice(["walpae", "pojol"])
    for ev in (events or []):
        i = take(); tiles[i]["type"] = ev
    for _ in range(spikes):
        i = take(); tiles[i]["type"] = "spike"
    herb_at = []
    for _ in range(herbs):
        i = take(); tiles[i]["herb"] = True; herb_at.append(i)
    # 감시꾼: 주인공이 가는 길 위에 서 있다. 지나가려면 멈춰서 싸워야 하고, 앞뒤 붉은 칸에 멈춰도 들킨다
    guards = []
    cand = [i for i in range(4, n - 3) if tiles[i]["type"] == "empty" and i not in used]
    r.shuffle(cand)
    for i in cand:
        if len(guards) >= watchers:
            break
        if any(abs(i - g["at"]) < 5 for g in guards):
            continue
        used.add(i)
        x, y = path[i]
        zone = [k for k in (i - 1, i, i + 1) if tiles[k]["type"] in ("empty", "spike") or tiles[k].get("herb")]
        guards.append({"x": x, "y": y, "at": i, "zone": zone, "kind": r.choice(["walpae", "pojol"]), "on_path": True})
    turns = (n + 2) // 3 + 2
    data = {"id": sid, "name": name, "tile": tile, "bg": bg, "turns": turns, "tiles": tiles, "guards": guards}
    json.dump(data, open(os.path.join(OUT, sid + ".json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(sid, "tiles", n, "turns", turns, "guards", len(guards))

DG = lambda pre, post: {"battle": "dogyeol", "pre": pre, "post": post}
SH = lambda pre, post: {"battle": "shadow_s", "pre": pre, "post": post}
BM = lambda pre, post: {"battle": "baegun_mask", "pre": pre, "post": post}
S = [
    ("s1_1", "운종가를 지나 도망치기", "stone", "jangteo", 40, 11, {"events": ["talk", "item", "shop", "talk", "buff"]}),
    ("s1_2", "문경새재 넘기", "dirt", "mungyeong_pass", 42, 12, {"events": ["talk", "buff", "debuff", "shop", "rest"]}),
    ("s1_3", "백운 노인 찾아가기", "grass", "byeolchae", 42, 13, {"events": ["rest", "trap", "talk", "shop", "talk"]}),
    ("s2_1", "검문소 피해 가기", "dirt", "checkpoint_road", 40, 21, {"events": ["talk", "buff", "shop", "trap"], "watchers": 4}),
    ("s2_2", "새재 너머 주막거리", "grass", "jumak_street", 42, 22, {"events": ["shop", "debuff", "talk", "item", "talk"]}),
    ("s2_3", "한양 약방으로", "stone", "yakbang", 44, 23, {"events": ["rest", "trap", "talk", "shop"], "blockers": 2, "boss": DG("C2_DG_FIGHT", "C2_DG_FLEE")}),
    ("s3_0", "서휘와 흑룡파 몰아내기", "stone", "alley", 40, 30, {"events": ["talk", "shop", "item", "rest"], "watchers": 4, "blockers": 2, "boss": {"battle": "heukdu1", "pre": "C3_HK1_PRE", "post": "C3_HK1_POST"}}),
    ("s3_k", "소금 창고의 아이들", "wood", "den", 38, 131, {"events": ["trap", "shop", "rest", "item"], "watchers": 4, "blockers": 2, "boss": {"battle": "heukdu2", "pre": "C3_HK2_PRE", "post": "C3_HK2_POST"}}),
    ("s3_1", "청계천 약재 심부름", "wood", "stream", 40, 31, {"events": ["talk", "item", "buff", "shop"], "boss": DG("C3_DG_FIGHT", "C3_DG_AFTER")}),
    ("s3_2", "종로 뒷골목", "stone", "alley", 42, 32, {"events": ["shop", "trap", "talk", "rest"], "watchers": 4, "boss": SH("C3_SHADOW", "C3_SHADOW_FLEE")}),
    ("s3_3", "남산 아래 결투", "dirt", "namsan_night", 42, 33, {"events": ["rest", "debuff", "shop", "talk"], "boss": {"battle": "seohwi2", "pre": "C3_BOSS", "post": "C3_BOSS_WIN"}}),
    ("s4_0", "성 밖 병든 마을", "grass", "village_outside", 38, 40, {"events": ["talk", "item", "rest", "shop"], "watchers": 3, "herbs": 5}),
    ("s4_1", "비 오는 청계천", "stone", "stream", 40, 41, {"events": ["talk", "debuff", "item", "shop"]}),
    ("s4_2", "군산 포구 뒤지기", "wood", "gunsan_port", 42, 42, {"events": ["shop", "trap", "talk", "rest"], "watchers": 4, "boss": BM("C4_MASK1", "C4_MASK1_FLEE")}),
    ("s4_3", "화엄골 가는 길", "dirt", "stream", 40, 43, {"events": ["rest", "trap", "talk", "shop"], "spikes": 3, "boss": BM("C4_MASK2", "C4_MASK2_FLEE")}),
    ("s4_f1", "백운의 성 1층 · 창고", "wood", "vault", 34, 141, {"events": ["item", "shop", "trap"], "watchers": 3, "blockers": 2, "boss": {"battle": "gatekeeper", "pre": "C4_F1_PRE", "post": "C4_F1_POST"}}),
    ("s4_f2", "백운의 성 2층 · 독안개 회랑", "cave", "corridor", 36, 142, {"events": ["debuff", "trap", "shop", "rest"], "watchers": 3, "spikes": 5, "boss": {"battle": "heukdu", "pre": "C4_F2_PRE", "post": "C4_F2_POST"}}),
    ("s4_f3", "백운의 성 3층 · 약 공방", "brick", "corridor", 36, 143, {"events": ["talk", "item", "shop", "debuff"], "watchers": 4, "herbs": 5, "boss": {"battle": "mob_boss", "pre": "C4_F3_PRE", "post": "C4_F3_POST"}}),
    ("s4_f4", "백운의 성 4층 · 보물고", "palace", "vault", 36, 144, {"events": ["buff", "trap", "shop", "rest"], "watchers": 4, "blockers": 2}),
    ("s4_f5", "백운의 성 3층 · 천수각", "palace", "cheonsugak", 32, 145, {"events": ["rest", "shop", "buff"], "watchers": 3, "blockers": 2, "boss": BM("C4_F5_PRE", "C4_F5_POST")}),
    ("s5_1", "내의원 환자 돌보기", "palace", "palace", 36, 51, {"events": ["talk", "item", "shop", "talk"], "watchers": 2, "blockers": 1}),
    ("s5_2", "종로에서 약재 구하기", "stone", "jangteo", 40, 52, {"events": ["shop", "talk", "debuff", "shop"]}),
    ("s5_3", "궁궐 담장 아래", "palace", "palace", 40, 53, {"events": ["rest", "buff", "shop"], "watchers": 4, "boss": SH("C5_SHADOW", "C5_SHADOW_FLEE")}),
    ("s5_4", "허 의원 약방으로", "stone", "yakbang", 44, 54, {"events": ["trap", "item", "talk", "shop"], "blockers": 2, "spikes": 3}),
    ("s6_1", "다래와 북한산 오르기", "grass", "stream", 40, 61, {"events": ["talk", "talk", "item", "rest", "shop"], "watchers": 2, "blockers": 1, "herbs": 6}),
    ("s6_2", "산마루 약초밭으로", "dirt", "mountain", 42, 62, {"events": ["talk", "talk", "buff", "shop"], "watchers": 2, "blockers": 1, "herbs": 6}),
    ("s7_1", "역병 도는 마을", "brick", "holland", 40, 71, {"events": ["talk", "item", "talk", "shop"]}),
    ("s7_2", "풍차 언덕 약초밭", "grass", "holland", 42, 72, {"events": ["rest", "shop", "debuff", "talk"], "herbs": 5}),
    ("s9_1", "운종가에서 청계천까지", "stone", "jangteo", 40, 91, {"events": ["talk", "talk", "shop", "talk"], "watchers": 3}),
    ("s9_2", "남산 아래 집터로", "grass", "mountain", 42, 92, {"events": ["talk", "talk", "rest", "shop"], "watchers": 3, "blockers": 2}),
]
S += [
    ("s1_0", "운종가 약재 심부름", "stone", "jangteo", 26, 10, {"events": ["shop", "item", "buff", "rest"], "watchers": 1, "blockers": 1, "spikes": 1}),
    ("s3_h", "자양강장 약재 찾기", "grass", "stream", 28, 300, {"events": ["shop", "item", "buff", "rest"], "watchers": 2, "blockers": 1, "herbs": 5}),
    ("h_port", "화란 항구, 떠나는 날", "stone", "holland_port", 26, 901, {"events": ["shop", "rest", "item", "buff"], "watchers": 2, "blockers": 1}),
    ("h_deck", "귀향의 바닷길", "wood", "deck", 30, 902, {"events": ["rest", "item", "debuff", "trap"], "watchers": 3, "blockers": 2, "spikes": 0, "boss": {"battle": "pirate_boss", "pre": "C9_PIRATE_PRE", "post": "C9_PIRATE_POST"}}),
    ("s9_p", "포도청 수련", "stone", "podocheong", 30, 903, {"events": ["talk", "rest", "item", "buff"], "watchers": 3, "blockers": 2, "boss": {"battle": "dogyeol", "pre": "C9_SPAR_PRE", "post": "C9_SPAR_POST", "lose_ok": True}}),
    ("v_ferry", "압록강 나루", "dirt", "ferry", 32, 701, {"events": ["talk", "shop", "debuff", "rest"], "watchers": 3, "blockers": 2}),
    ("v_yanjing", "연경 약재 시장", "stone", "yanjing", 34, 702, {"events": ["shop", "shop", "item", "debuff"], "watchers": 3, "blockers": 2, "boss": {"battle": "cheong_merchant", "pre": "C7_YANJING_PRE", "post": "C7_YANJING_POST"}}),
    ("v_port", "광주 항구", "wood", "port", 32, 703, {"events": ["shop", "rest", "item", "trap"], "watchers": 3, "blockers": 2}),
    ("v_sea", "천축 앞바다", "wood", "deck", 34, 704, {"events": ["trap", "rest", "debuff", "item"], "watchers": 3, "blockers": 2, "spikes": 0, "boss": {"battle": "pirate_boss", "pre": "C7_PIRATE_PRE", "post": "C7_PIRATE_POST"}}),
]
S += [
    ("s10_isle", "남쪽 유배 섬 가는 길", "dirt", "exile_hut", 36, 1001, {"events": ["talk", "rest", "item", "shop"], "watchers": 3, "blockers": 1, "herbs": 5}),
    ("s10_palace", "밤의 궁궐 잠입", "palace", "palace_night", 34, 1002, {"events": ["trap", "item", "rest", "debuff"], "watchers": 5, "blockers": 2, "boss": {"battle": "jeong_shadow1", "pre": "C10_JEONG1_PRE", "post": "C10_JEONG1_POST"}}),
    ("s10_mapo", "마포 나루 청 상인 창고", "wood", "mapo_warehouse", 36, 1003, {"events": ["shop", "trap", "rest", "item"], "watchers": 4, "blockers": 2, "boss": {"battle": "jeong_shadow", "pre": "C10_JEONG_PRE", "post": "C10_JEONG_POST"}}),
]
for sid, name, tile, bg, ln, seed, kw in S:
    make(sid, name, tile, bg, ln, seed, **kw)
