# GitHub Actions에서 실행: ambientCG(CC0)의 종이·천 질감을 모두 받아 한지 후보로 비교
import io, json, os, urllib.request, zipfile
from PIL import Image
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets_src", "raw", "paper")
os.makedirs(OUT, exist_ok=True)
UA = {"User-Agent": "Mozilla/5.0"}
def get(u):
    try:
        with urllib.request.urlopen(urllib.request.Request(u, headers=UA), timeout=60) as r:
            return r.read()
    except Exception as e:
        print("FAIL", u, e); return None
ids = []
for q in ["paper", "rice paper", "parchment", "linen", "fabric"]:
    t = get("https://ambientcg.com/api/v2/full_json?type=Material&limit=60&q=" + urllib.parse.quote(q) if False else
            "https://ambientcg.com/api/v2/full_json?type=Material&limit=60&q=" + q.replace(" ", "%20"))
    if t:
        for a in json.loads(t).get("foundAssets", []):
            if a["assetId"] not in ids:
                ids.append(a["assetId"])
print(ids)
thumbs = []
for aid in ids[:40]:
    d = get(f"https://ambientcg.com/get?file={aid}_1K-JPG.zip")
    if not d:
        continue
    try:
        z = zipfile.ZipFile(io.BytesIO(d))
        for n in z.namelist():
            if n.endswith("_Color.jpg"):
                b = z.read(n)
                open(os.path.join(OUT, aid + ".jpg"), "wb").write(b)
                im = Image.open(io.BytesIO(b)).convert("RGB").resize((256, 256)); thumbs.append((aid, im))
    except Exception as e:
        print("ZIP", aid, e)
from PIL import ImageDraw
cols = 8
sheet = Image.new("RGB", (cols * 260, ((len(thumbs) + cols - 1) // cols) * 280), "white")
d = ImageDraw.Draw(sheet)
for k, (aid, im) in enumerate(thumbs):
    x, y = (k % cols) * 260, (k // cols) * 280
    sheet.paste(im, (x, y)); d.text((x, y + 258), aid, fill="black")
sheet.save(os.path.join(OUT, "sheet.jpg"), quality=85)
