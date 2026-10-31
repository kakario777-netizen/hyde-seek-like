# GitHub Actions에서 실행: 오픈 라이선스 원본 에셋을 받아 assets_src/raw 에 모은다.
# (작업 공간에서는 외부 사이트 접속이 막혀 있어 빌드 서버에서 받는다)
import io, json, os, re, subprocess, sys, time, urllib.parse, urllib.request, zipfile

OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets_src", "raw")
os.makedirs(OUT, exist_ok=True)
UA = {"User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126 Safari/537.36",
      "Accept-Language": "ko,en;q=0.8"}
log = []

def get(url, binary=True, tries=3):
    for i in range(tries):
        try:
            req = urllib.request.Request(url, headers=UA)
            with urllib.request.urlopen(req, timeout=60) as r:
                data = r.read()
                return data if binary else data.decode("utf-8", "replace")
        except Exception as e:
            log.append(f"FAIL {url} {e}")
            time.sleep(2)
    return None

def save(rel, data):
    p = os.path.join(OUT, rel)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "wb") as f:
        f.write(data)
    log.append(f"OK {rel} {len(data)}")

# 1) 글꼴 (Google Fonts, OFL)
FONTS = {
    "fonts/SongMyung-Regular.ttf": "https://raw.githubusercontent.com/google/fonts/main/ofl/songmyung/SongMyung-Regular.ttf",
    "fonts/GowunBatang-Regular.ttf": "https://raw.githubusercontent.com/google/fonts/main/ofl/gowunbatang/GowunBatang-Regular.ttf",
    "fonts/GowunBatang-Bold.ttf": "https://raw.githubusercontent.com/google/fonts/main/ofl/gowunbatang/GowunBatang-Bold.ttf",
    "fonts/NanumBrushScript-Regular.ttf": "https://raw.githubusercontent.com/google/fonts/main/ofl/nanumbrushscript/NanumBrushScript-Regular.ttf",
    "fonts/YeonSung-Regular.ttf": "https://raw.githubusercontent.com/google/fonts/main/ofl/yeonsung/YeonSung-Regular.ttf",
}
for rel, url in FONTS.items():
    d = get(url)
    if d: save(rel, d)

# 2) 종이·나무 질감 (ambientCG, CC0)
for tid in ["Paper001", "Paper002", "Paper003", "Paper004", "Paper005", "Paper006", "Wood026", "Wood049", "Wood051", "Wood066"]:
    d = get(f"https://ambientcg.com/get?file={tid}_2K-JPG.zip")
    if not d:
        continue
    try:
        z = zipfile.ZipFile(io.BytesIO(d))
        for n in z.namelist():
            if n.endswith("_Color.jpg"):
                save(f"textures/{tid}_Color.jpg", z.read(n))
    except Exception as e:
        log.append(f"ZIPFAIL {tid} {e}")

# 3) 아이콘 (game-icons.net, CC BY 3.0)
ICON_NAMES = ["fist", "punch", "high-kick", "foot-trip", "flying-kick", "shield", "round-shield", "checked-shield",
              "potion-ball", "round-bottom-flask", "corked-tube", "chili-pepper", "pepper", "robber-hand", "grab",
              "footprint", "barefoot", "boot-prints", "scroll-unfurled", "scroll-quill", "elbow", "shoulder-armor",
              "sandal", "walk", "run", "coins", "two-coins", "herbs", "medicines", "talk", "conversation", "shop",
              "tavern-sign", "house", "village", "pagoda", "torii-gate", "spear-hook", "spiked-bat", "nunchaku",
              "dodge", "sprint", "punch-blast", "knockout", "stomp", "body-swapping", "mortar", "ancient-sword",
              "sun", "moon", "wax-seal", "stamper", "lantern-flame", "paper-lantern", "hand", "open-palm"]
try:
    subprocess.run(["git", "clone", "--depth", "1", "https://github.com/game-icons/icons", "/tmp/gi"], check=True)
    for root, _, files in os.walk("/tmp/gi"):
        for fn in files:
            if fn.endswith(".svg") and fn[:-4] in ICON_NAMES:
                author = os.path.basename(root)
                with open(os.path.join(root, fn), "rb") as f:
                    save(f"icons/{author}__{fn}", f.read())
except Exception as e:
    log.append(f"ICONFAIL {e}")

# 4) 수선전도 (조선 한양 지도, 퍼블릭 도메인) 등 위키미디어 공용
def commons(query, n=3, width=2400, prefix="commons"):
    api = "https://commons.wikimedia.org/w/api.php?" + urllib.parse.urlencode({
        "action": "query", "list": "search", "srsearch": query, "srnamespace": 6, "srlimit": n, "format": "json"})
    t = get(api, binary=False)
    if not t:
        return
    for hit in json.loads(t)["query"]["search"]:
        title = hit["title"]
        info = get("https://commons.wikimedia.org/w/api.php?" + urllib.parse.urlencode({
            "action": "query", "titles": title, "prop": "imageinfo", "iiprop": "url|extmetadata",
            "iiurlwidth": width, "format": "json"}), binary=False)
        if not info:
            continue
        page = list(json.loads(info)["query"]["pages"].values())[0]
        ii = page.get("imageinfo", [{}])[0]
        url = ii.get("thumburl") or ii.get("url")
        lic = ii.get("extmetadata", {}).get("LicenseShortName", {}).get("value", "?")
        if url:
            d = get(url)
            if d:
                safe = re.sub(r"[^0-9A-Za-z가-힣._-]+", "_", title.replace("File:", ""))[:80]
                save(f"{prefix}/{safe}.jpg", d)
                log.append(f"LICENSE {title} {lic}")

commons("Suseon jeondo map Seoul", 4, prefix="maps")
commons("수선전도", 3, prefix="maps")

# 5) Pixabay (Pixabay 라이선스: 상업 이용 가능, 출처 표시 불필요)
PIXABAY_QUERIES = ["한복 만화", "한복 캐릭터", "조선 남자 만화", "한복 남자 만화", "한옥 밤", "한옥 골목",
                   "한옥 일러스트", "조선 궁궐 일러스트", "한국 전통 마을 일러스트", "한방 약방", "한국 전통 배경 일러스트",
                   "hanok night illustration", "korean traditional anime"]
seen = {}
for q in PIXABAY_QUERIES:
    html = get("https://pixabay.com/ko/illustrations/search/" + urllib.parse.quote(q) + "/", binary=False)
    if not html:
        continue
    save(f"pixabay/search_{len(seen)}_{abs(hash(q)) % 10000}.html", html.encode())
    for m in re.finditer(r'https://cdn\.pixabay\.com/photo/[^"\s,]+?_(?:340|640|1280)\.(?:jpg|png|webp)', html):
        url = m.group(0)
        mid = re.search(r"-(\d{5,})_", url)
        if not mid:
            continue
        pid = mid.group(1)
        if pid in seen:
            continue
        seen[pid] = {"query": q, "url": url}
for pid, v in list(seen.items())[:220]:
    big = re.sub(r"_(340|640)\.", "_1280.", v["url"])
    d = get(big) or get(v["url"])
    if d:
        ext = big.rsplit(".", 1)[1]
        save(f"pixabay/{pid}.{ext}", d)
with open(os.path.join(OUT, "pixabay", "index.json") if seen else os.path.join(OUT, "pixabay_index.json"), "w", encoding="utf-8") as f:
    json.dump(seen, f, ensure_ascii=False, indent=1)

with open(os.path.join(OUT, "fetch_log.txt"), "w", encoding="utf-8") as f:
    f.write("\n".join(log))
print("\n".join(log[-80:]))
