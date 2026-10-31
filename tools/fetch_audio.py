# GitHub Actions에서 실행: 무료(CC0/CC-BY/퍼블릭 도메인) 소리 후보를 받아 assets_src/raw/audio 에 모은다.
import io, json, os, re, subprocess, time, urllib.parse, urllib.request, zipfile
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets_src", "raw", "audio")
os.makedirs(OUT, exist_ok=True)
UA = {"User-Agent": "HanyangHideGame/0.7 (github.com/kakario777-netizen/hyde-seek-like)"}
log, meta = [], []
def get(u, binary=True):
    for i in range(3):
        try:
            with urllib.request.urlopen(urllib.request.Request(u, headers=UA), timeout=90) as r:
                d = r.read(); return d if binary else d.decode("utf-8", "replace")
        except Exception as e:
            log.append(f"FAIL {u[:140]} {e}"); time.sleep(3 + i * 5)
    return None
OK_LIC = re.compile(r"(CC0|CC-BY 3|CC-BY 4|OGA-BY|Public Domain|public domain|CC BY 3|CC BY 4|CC BY-SA|CC-BY-SA|PD)", re.I)

# 1) OpenGameArt 효과음 묶음 (모두 CC0)
OGA_SFX = ["50-rpg-sound-effects", "51-ui-sound-effects-buttons-switches-and-clicks", "37-hitspunches",
           "rpg-sound-pack", "80-cc0-rpg-sfx", "impact", "100-cc0-sfx", "footsteps-leather-cloth-armor",
           "coin-sounds", "inventory-sound-effects", "punches-hits-swords-and-squishes", "bell-gong-sounds",
           "fantasy-sound-effects-library", "book-page-flip", "paper-sounds"]
def oga(page, kind):
    html = get("https://opengameart.org/content/" + page, binary=False)
    if not html:
        return
    lic = ", ".join(sorted(set(re.findall(r'class="license-name">([^<]+)<', html)))) or "?"
    title = re.search(r"<title>([^<|]+)", html)
    files = re.findall(r'href="(https://opengameart\.org/sites/default/files/[^"]+\.(?:zip|ogg|wav|mp3|flac))"', html)
    log.append(f"OGA {page} lic={lic} files={len(files)}")
    if not OK_LIC.search(lic):
        return
    for f in files[:6]:
        d = get(f)
        if not d:
            continue
        base = f"{kind}/oga_{page}"
        if f.endswith(".zip"):
            try:
                z = zipfile.ZipFile(io.BytesIO(d))
                for n in z.namelist():
                    if n.lower().endswith((".ogg", ".wav", ".mp3", ".flac")) and not n.startswith("__MACOSX"):
                        p = os.path.join(OUT, base, re.sub(r"[^0-9A-Za-z._-]+", "_", n)[-90:])
                        os.makedirs(os.path.dirname(p), exist_ok=True)
                        open(p, "wb").write(z.read(n))
            except Exception as e:
                log.append(f"ZIP {f} {e}")
        else:
            p = os.path.join(OUT, base, os.path.basename(f))
            os.makedirs(os.path.dirname(p), exist_ok=True); open(p, "wb").write(d)
    meta.append({"src": "opengameart", "page": "https://opengameart.org/content/" + page, "title": title.group(1).strip() if title else page, "license": lic, "kind": kind})
for p in OGA_SFX:
    oga(p, "sfx"); time.sleep(1)

# 2) OpenGameArt 음악 검색 (동양풍)
for q in ["korean", "oriental", "asian", "japanese", "chinese", "zen", "eastern", "koto", "erhu", "shakuhachi", "taiko"]:
    url = ("https://opengameart.org/art-search-advanced?keys=" + urllib.parse.quote(q) +
           "&field_art_type_tid%5B%5D=12&sort_by=count&sort_order=DESC&items_per_page=24")
    html = get(url, binary=False)
    if not html:
        continue
    pages = list(dict.fromkeys(re.findall(r'href="/content/([a-z0-9-]+)"', html)))[:8]
    log.append(f"SEARCH {q} {pages}")
    for pg in pages:
        oga(pg, "music"); time.sleep(1)

# 3) 위키미디어 공용 국악 녹음 (퍼블릭 도메인 / CC)
for q in ["gayageum", "haegeum", "daegeum", "geomungo", "piri korean", "janggu", "buk drum korean", "Korean traditional music",
          "sanjo", "jing gong korean", "kkwaenggwari", "Arirang instrumental", "pansori"]:
    t = get("https://commons.wikimedia.org/w/api.php?" + urllib.parse.urlencode({
        "action": "query", "generator": "search", "gsrsearch": q + " filetype:audio", "gsrnamespace": 6, "gsrlimit": 10,
        "prop": "imageinfo", "iiprop": "url|extmetadata|size|mediatype", "format": "json"}), binary=False)
    time.sleep(2)
    if not t:
        continue
    for pgd in json.loads(t).get("query", {}).get("pages", {}).values():
        ii = (pgd.get("imageinfo") or [{}])[0]
        m = ii.get("extmetadata", {})
        lic = m.get("LicenseShortName", {}).get("value", "?")
        url = ii.get("url", "")
        if not url or not OK_LIC.search(lic) or ii.get("size", 0) > 40_000_000:
            log.append(f"SKIP {pgd['title']} {lic}"); continue
        d = get(url); time.sleep(2)
        if d:
            name = re.sub(r"[^0-9A-Za-z._-]+", "_", pgd["title"].replace("File:", ""))[-90:]
            p = os.path.join(OUT, "korean", name); os.makedirs(os.path.dirname(p), exist_ok=True); open(p, "wb").write(d)
            meta.append({"src": "commons", "file": name, "title": pgd["title"], "license": lic,
                         "artist": re.sub("<[^>]+>", "", m.get("Artist", {}).get("value", ""))[:80],
                         "desc": re.sub("<[^>]+>", "", m.get("ImageDescription", {}).get("value", ""))[:200], "kind": "korean"})

# 길이·음량 요약
rows = []
for root, _, fs in os.walk(OUT):
    for f in fs:
        if f.lower().endswith((".ogg", ".wav", ".mp3", ".flac", ".oga", ".opus", ".webm")):
            p = os.path.join(root, f)
            r = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", p], capture_output=True, text=True)
            rows.append(f"{os.path.relpath(p, OUT)}\t{r.stdout.strip()}")
open(os.path.join(OUT, "files.tsv"), "w").write("\n".join(sorted(rows)))
json.dump(meta, open(os.path.join(OUT, "meta.json"), "w"), ensure_ascii=False, indent=1)
open(os.path.join(OUT, "log.txt"), "w").write("\n".join(log))
print(len(rows), "audio files")
