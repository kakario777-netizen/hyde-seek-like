# GitHub Actions에서 실행: 설정에서 고를 수 있는 무료 한글 글꼴(OFL)을 받는다
import os, urllib.request
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets_src", "raw", "fonts")
os.makedirs(OUT, exist_ok=True)
B = "https://raw.githubusercontent.com/google/fonts/main/ofl/"
for path in ["nanummyeongjo/NanumMyeongjo-Bold.ttf", "nanummyeongjo/NanumMyeongjo-Regular.ttf", "gowundodum/GowunDodum-Regular.ttf",
             "yeonsung/YeonSung-Regular.ttf", "hahmlet/Hahmlet%5Bwght%5D.ttf", "nanumgothic/NanumGothic-Bold.ttf",
             "gowunbatang/GowunBatang-Bold.ttf"]:
    try:
        d = urllib.request.urlopen(urllib.request.Request(B + path, headers={"User-Agent": "x"}), timeout=60).read()
        open(os.path.join(OUT, path.split("/")[-1].replace("%5B", "[").replace("%5D", "]")), "wb").write(d)
        print("OK", path, len(d))
    except Exception as e:
        print("FAIL", path, e)
