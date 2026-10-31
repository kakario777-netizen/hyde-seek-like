# 대동여지도 위 제1장 이동 경로(한양 → 지리산) 칸 배치 생성
import json, math, os, random

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
W, H = 1024, 1536
WAY = [(507, 742), (560, 780), (604, 842), (676, 806), (733, 828), (768, 900), (722, 958), (652, 925),
       (602, 990), (642, 1042), (703, 1080), (762, 1122), (705, 1166), (622, 1128), (560, 1064),
       (487, 990), (420, 962), (398, 1040), (468, 1082), (432, 1132), (410, 1166), (382, 1212),
       (462, 1236), (540, 1208)]
N = 56

seg, total = [], 0.0
for a, b in zip(WAY, WAY[1:]):
    L = math.dist(a, b); seg.append((a, b, L)); total += L
pts = []
for i in range(N):
    t = total * i / (N - 1)
    for a, b, L in seg:
        if t <= L + 1e-9 or (a, b, L) == seg[-1]:
            f = min(1.0, t / L)
            pts.append((a[0] + (b[0] - a[0]) * f, a[1] + (b[1] - a[1]) * f)); break
        t -= L

types = ["empty"] * N
types[0] = "start"; types[-1] = "goal"
fixed = {
    3: "talk", 6: "item", 8: "walpae", 10: "buff", 12: "trap", 14: "talk", 16: "pojol", 18: "rest",
    19: "story1", 21: "debuff", 23: "item", 25: "walpae", 27: "shop", 29: "trap", 31: "talk", 33: "buff",
    35: "pojol", 37: "debuff", 38: "story2", 40: "item", 42: "walpae", 44: "trap", 45: "rest", 47: "talk",
    49: "pojol", 50: "buff", 52: "debuff", 53: "walpae",
}
for k, v in fixed.items():
    types[k] = v

PLACES = {0: "한양 숭례문", 4: "광나루", 9: "원주 고개", 19: "문경새재", 27: "대구 약령시", 38: "공주 금강 나루",
          45: "전주 주막", 55: "지리산 화엄골"}
nodes = []
for i, ((x, y), t) in enumerate(zip(pts, types)):
    n = {"x": round(x / W, 4), "y": round(y / H, 4), "type": t}
    if i in PLACES:
        n["name"] = PLACES[i]
    nodes.append(n)
with open(os.path.join(ROOT, "assets", "data", "board1.json"), "w", encoding="utf-8") as f:
    json.dump({"map": "korea_map.jpg", "scale": 1.9, "nodes": nodes}, f, ensure_ascii=False, indent=1)
print("length", round(total), "spacing", round(total / (N - 1), 1))
