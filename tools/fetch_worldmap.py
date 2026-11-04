# GitHub Actions에서 실행: 조선·명대 세계지도(퍼블릭 도메인)를 받는다
import json, os, re, time, urllib.parse, urllib.request
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets_src", "raw", "world")
os.makedirs(OUT, exist_ok=True)
UA = {"User-Agent": "HanyangHideGame/1.0 (game asset research)"}
log = []
def get(u, b=True):
    for i in range(3):
        try:
            with urllib.request.urlopen(urllib.request.Request(u, headers=UA), timeout=60) as r:
                d = r.read(); return d if b else d.decode()
        except Exception as e:
            log.append(f"FAIL {u[:120]} {e}"); time.sleep(5 + i * 10)
for q in ["Kunyu Wanguo Quantu", "곤여만국전도", "Gonyeo mangukjeondo", "Cheonhado map", "Kangnido", "Ricci world map 1602"]:
    t = get("https://commons.wikimedia.org/w/api.php?" + urllib.parse.urlencode({
        "action": "query", "generator": "search", "gsrsearch": q, "gsrnamespace": 6, "gsrlimit": 5,
        "prop": "imageinfo", "iiprop": "url|extmetadata|size", "iiurlwidth": 3000, "format": "json"}), False)
    time.sleep(3)
    if not t:
        continue
    for p in json.loads(t).get("query", {}).get("pages", {}).values():
        ii = (p.get("imageinfo") or [{}])[0]
        lic = ii.get("extmetadata", {}).get("LicenseShortName", {}).get("value", "?")
        url = ii.get("thumburl") or ii.get("url")
        log.append(f"FOUND {p['title']} {lic} {ii.get('width')}x{ii.get('height')}")
        if url and ("Public domain" in lic or "PD" in lic) and url.lower().endswith((".jpg", ".jpeg", ".png")):
            d = get(url); time.sleep(4)
            if d:
                name = re.sub(r"[^0-9A-Za-z._-]+", "_", p["title"].replace("File:", ""))[-80:]
                open(os.path.join(OUT, name), "wb").write(d)
                log.append(f"OK {name} {len(d)}")
open(os.path.join(OUT, "log.txt"), "w").write("\n".join(log))
