# 대사에 쓰인 한자만 골라 작은 보조 글꼴(Noto Serif CJK KR, OFL)로 만든다. 대사에 한자를 새로 넣으면 다시 실행.
import glob, os
from fontTools.ttLib import TTCollection
from fontTools import subset
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
chars = set()
for f in glob.glob(os.path.join(ROOT, "scripts", "*.gd")):
    chars |= {ord(c) for c in open(f, encoding="utf-8").read() if 0x3400 <= ord(c) <= 0x9FFF or 0xF900 <= ord(c) <= 0xFAFF}
src = "/usr/share/fonts/opentype/noto/NotoSerifCJK-Bold.ttc"
tmp = "/tmp/_kr.otf"
for fnt in TTCollection(src).fonts:
    if fnt["name"].getDebugName(1).startswith("Noto Serif CJK KR"):
        fnt.save(tmp); break
opts = subset.Options(); opts.name_IDs = ["*"]
font = subset.load_font(tmp, opts)
s = subset.Subsetter(opts); s.populate(unicodes=sorted(chars)); s.subset(font)
out = os.path.join(ROOT, "assets", "fonts", "Hanja-Subset.otf")
font.save(out)
print(len(chars), "chars ->", out, os.path.getsize(out))
