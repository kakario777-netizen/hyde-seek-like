# GitHub Actions에서 실행: 상업 이용·수정 가능한 일러스트 후보를 찾아 미리보기 시트를 만든다.
import io, json, os, re, time, urllib.parse, urllib.request
from PIL import Image, ImageDraw

OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets_src", "raw", "search")
os.makedirs(OUT, exist_ok=True)
UA = {"User-Agent": "HanyangHideGame/0.3 (asset research; github.com/kakario777-netizen/hyde-seek-like)"}
log = []

def get(url, binary=True):
    for i in range(3):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=60) as r:
                d = r.read()
                return d if binary else d.decode("utf-8", "replace")
        except Exception as e:
            log.append(f"FAIL {url[:120]} {e}")
            time.sleep(3 + i * 4)
    return None

cands = []

# Openverse (CC 라이선스 모음: 플리커·위키미디어 등)
OV = ["hanbok anime", "hanbok illustration", "hanbok girl drawing", "joseon illustration", "korean traditional anime girl",
      "hanbok manga", "korean historical drama illustration", "hanok illustration night", "hanok painting", "joseon painting",
      "anime girl traditional", "visual novel character", "anime boy hanfu", "hanfu illustration", "shin yun-bok", "kim hong-do"]
for q in OV:
    t = get("https://api.openverse.org/v1/images/?" + urllib.parse.urlencode(
        {"q": q, "license_type": "commercial,modification", "page_size": 20}), binary=False)
    if not t:
        continue
    try:
        for r in json.loads(t).get("results", []):
            cands.append({"src": "openverse", "q": q, "id": r["id"], "title": r.get("title"), "creator": r.get("creator"),
                          "license": f'{r.get("license")} {r.get("license_version")}', "url": r.get("url"),
                          "thumb": r.get("thumbnail"), "page": r.get("foreign_landing_url"), "w": r.get("width"), "h": r.get("height")})
    except Exception as e:
        log.append(f"PARSE {q} {e}")
    time.sleep(1.5)

# 위키미디어 공용 (천천히)
WM = ["Hanbok illustration", "Hanbok anime", "Joseon woman painting Shin Yun-bok", "Miindo Shin Yunbok",
      "Danopungjeong", "Kim Hong-do genre painting", "Joseon dynasty police podocheong", "Hanok drawing",
      "Korean folk painting tiger", "Korean traditional paper hanji texture"]
for q in WM:
    t = get("https://commons.wikimedia.org/w/api.php?" + urllib.parse.urlencode({
        "action": "query", "generator": "search", "gsrsearch": q, "gsrnamespace": 6, "gsrlimit": 12,
        "prop": "imageinfo", "iiprop": "url|extmetadata|size", "iiurlwidth": 320, "format": "json"}), binary=False)
    time.sleep(2)
    if not t:
        continue
    for p in json.loads(t).get("query", {}).get("pages", {}).values():
        ii = (p.get("imageinfo") or [{}])[0]
        meta = ii.get("extmetadata", {})
        cands.append({"src": "commons", "q": q, "id": p["title"], "title": p["title"],
                      "creator": re.sub("<[^>]+>", "", meta.get("Artist", {}).get("value", ""))[:60],
                      "license": meta.get("LicenseShortName", {}).get("value", "?"), "url": ii.get("url"),
                      "thumb": ii.get("thumburl"), "page": ii.get("descriptionurl"), "w": ii.get("width"), "h": ii.get("height")})

# 미리보기 시트 (번호 붙여 저장)
seen = set(); items = []
for c in cands:
    if c["id"] in seen or not c.get("thumb"):
        continue
    seen.add(c["id"]); items.append(c)
thumbs = []
for i, c in enumerate(items):
    d = get(c["thumb"])
    time.sleep(0.3)
    try:
        im = Image.open(io.BytesIO(d)).convert("RGB"); im.thumbnail((200, 200)); thumbs.append((i, im))
    except Exception:
        pass
cols = 8
for s in range(0, len(thumbs), 48):
    part = thumbs[s:s + 48]
    sheet = Image.new("RGB", (cols * 210, ((len(part) + cols - 1) // cols) * 230), (240, 236, 228))
    dr = ImageDraw.Draw(sheet)
    for k, (i, im) in enumerate(part):
        x, y = (k % cols) * 210, (k // cols) * 230
        sheet.paste(im, (x + 5, y + 5)); dr.text((x + 5, y + 210), f"#{i} {items[i]['license'][:18]}", fill=(0, 0, 0))
    sheet.save(os.path.join(OUT, f"sheet_{s // 48}.jpg"), quality=85)
with open(os.path.join(OUT, "candidates.json"), "w", encoding="utf-8") as f:
    json.dump(items, f, ensure_ascii=False, indent=1)
with open(os.path.join(OUT, "log.txt"), "w") as f:
    f.write("\n".join(log))
print(len(items), "candidates")
