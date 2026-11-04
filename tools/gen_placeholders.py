# 아직 일러스트가 없는 인물을 아주 가벼운 도트로 그린 임시 그림 (게임 안에서 "(준비중)" 표시)
# 진짜 그림을 받으면 assets/chars/<이름>.png 를 덮어쓰고 StoryData.PLACEHOLDERS 에서 지운다.
import os
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "chars")
W, H, SC = 34, 60, 12
INK = (36, 26, 24, 255)

def C(h, a=255):
    h = h.lstrip("#"); return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) + (a,)

def figure(o):
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    cx = W // 2
    skin, robe, robe2, sash = C(o.get("skin", "#f2c9a0")), C(o["robe"]), C(o.get("robe2", o["robe"])), C(o.get("sash", "#9a2c22"))
    hair = C(o.get("hair", "#2a1d1a"))
    # 뒷머리 / 수염
    if o.get("long_hair"):
        d.rectangle([cx - 6, 10, cx + 6, 26], fill=hair)
    # 몸통(도포/치마)
    top = 21
    d.polygon([(cx - 6, top), (cx + 6, top), (cx + 11, H - 6), (cx - 11, H - 6)], fill=robe)
    d.polygon([(cx - 2, top), (cx + 2, top), (cx + 3, H - 6), (cx - 3, H - 6)], fill=robe2)
    d.rectangle([cx - 7, 31, cx + 7, 33], fill=sash)
    if o.get("badge"):
        d.ellipse([cx - 3, 24, cx + 3, 30], fill=C(o["badge"]))
    # 팔
    arm = o.get("arms", "down")
    if arm == "down":
        d.rectangle([cx - 10, top + 1, cx - 7, top + 15], fill=robe); d.rectangle([cx + 7, top + 1, cx + 10, top + 15], fill=robe)
        d.rectangle([cx - 10, top + 15, cx - 7, top + 17], fill=skin); d.rectangle([cx + 7, top + 15, cx + 10, top + 17], fill=skin)
    elif arm == "fight":
        d.rectangle([cx - 12, top + 1, cx - 7, top + 5], fill=robe); d.rectangle([cx - 14, top - 3, cx - 11, top + 2], fill=skin)
        d.rectangle([cx + 7, top + 3, cx + 13, top + 7], fill=robe); d.rectangle([cx + 12, top + 2, cx + 15, top + 6], fill=skin)
    elif arm == "staff":
        d.rectangle([cx - 10, top + 1, cx - 7, top + 15], fill=robe)
        d.rectangle([cx + 7, top + 1, cx + 10, top + 12], fill=robe); d.rectangle([cx + 11, 8, cx + 12, H - 5], fill=C("#6e4a2e"))
        d.rectangle([cx + 9, top + 10, cx + 12, top + 13], fill=skin)
    # 발
    d.rectangle([cx - 6, H - 6, cx - 2, H - 4], fill=INK); d.rectangle([cx + 2, H - 6, cx + 6, H - 4], fill=INK)
    # 머리
    d.rectangle([cx - 5, 9, cx + 5, 20], fill=skin)
    d.rectangle([cx - 5, 7, cx + 5, 11], fill=hair)
    if o.get("bangs"):
        d.rectangle([cx - 6, 9, cx - 4, 16], fill=hair); d.rectangle([cx + 4, 9, cx + 6, 16], fill=hair)
    eye = C(o.get("eye", "#241a18"))
    d.point([(cx - 3, 14), (cx - 2, 14), (cx + 2, 14), (cx + 3, 14)], fill=eye)
    if o.get("glasses"):
        g = C("#d9b45a")
        d.rectangle([cx - 4, 13, cx - 1, 15], outline=g); d.rectangle([cx + 1, 13, cx + 4, 15], outline=g)
    if o.get("blush"):
        d.point([(cx - 4, 16), (cx - 3, 16), (cx + 3, 16), (cx + 4, 16)], fill=C("#e8968a"))
    if o.get("dark_eyes"):
        d.point([(cx - 3, 15), (cx - 2, 15), (cx + 2, 15), (cx + 3, 15)], fill=C("#7a5a8a"))
    d.point([(cx - 1, 18), (cx, 18), (cx + 1, 18)], fill=C("#a8443a"))
    if o.get("beard"):
        d.polygon([(cx - 4, 18), (cx + 4, 18), (cx + 1, 27), (cx - 1, 27)], fill=C(o["beard"]))
    # 모자
    hat = o.get("hat")
    if hat == "gat":
        d.rectangle([cx - 11, 7, cx + 11, 8], fill=INK); d.rectangle([cx - 4, 1, cx + 4, 7], fill=INK)
        if o.get("tassel"):
            d.rectangle([cx + 9, 8, cx + 10, 22], fill=C(o["tassel"]))
    elif hat == "satgat":
        d.polygon([(cx - 13, 9), (cx + 13, 9), (cx, 0)], fill=C("#2e2420"))
    elif hat == "ikseon":
        d.rectangle([cx - 6, 2, cx + 6, 8], fill=INK); d.rectangle([cx - 8, 2, cx - 6, 5], fill=INK); d.rectangle([cx + 6, 2, cx + 8, 5], fill=INK)
    elif hat == "garima":
        d.rectangle([cx - 7, 3, cx + 7, 8], fill=C("#1e1a22"))
    elif hat == "bun":
        d.ellipse([cx - 3, 2, cx + 3, 8], fill=hair); d.rectangle([cx - 6, 5, cx + 6, 6], fill=C("#d9b45a"))
    elif hat == "messy":
        for x in range(cx - 7, cx + 8, 2):
            d.rectangle([x, 5 + (x % 3), x + 1, 9], fill=hair)
    # 외곽선
    a = im.getchannel("A")
    out = Image.new("RGBA", (W + 2, H + 2), (0, 0, 0, 0))
    sil = Image.new("RGBA", (W, H), INK); sil.putalpha(a)
    for dx, dy in [(0, 1), (2, 1), (1, 0), (1, 2)]:
        out.alpha_composite(sil, (dx, dy))
    out.alpha_composite(im, (1, 1))
    return out.resize(((W + 2) * SC, (H + 2) * SC), Image.NEAREST)

CHARS = {
    "seohwi_dutch": {"robe": "#1e1a22", "robe2": "#efe8d8", "sash": "#6e4a2e", "hair": "#d8b45a", "eye": "#3a7ad0", "glasses": True, "bangs": True, "hat": "garima"},
    "hero_adult": {"robe": "#c8566a", "robe2": "#f3e6c8", "sash": "#7a2e4a", "hair": "#4a2a1a", "long_hair": True, "hat": "bun", "blush": True},
    "heo_ill": {"robe": "#d8d2c4", "robe2": "#efe8d8", "sash": "#8a8270", "hair": "#a8a49c", "beard": "#c8c4bc", "dark_eyes": True, "skin": "#e0c8b0"},
    "dutch_child": {"robe": "#4a6aa0", "robe2": "#f3e6c8", "sash": "#a8443a", "hair": "#e8d080", "eye": "#3a7ad0", "bangs": True, "blush": True},
    "haejeok": {"robe": "#5a4a3a", "robe2": "#a8443a", "sash": "#2a1d1a", "hair": "#2a1d1a", "hat": "messy", "arms": "fight", "beard": "#3a2a20"},
    "rat": {"robe": "#6a6058", "robe2": "#4a4038", "sash": "#3a3028", "hair": "#4a4038", "skin": "#8a7a70", "eye": "#c0392b", "hat": "messy", "arms": "fight"},
    "jongsagwan": {"robe": "#1e1a22", "robe2": "#9a2c22", "sash": "#d9b45a", "hat": "gat", "tassel": "#c0392b", "badge": "#d9b45a"},
    "jongsagwan_blush": {"robe": "#1e1a22", "robe2": "#9a2c22", "sash": "#d9b45a", "hat": "gat", "tassel": "#c0392b", "badge": "#d9b45a", "blush": True},
    "seohwi": {"robe": "#2c3550", "robe2": "#efe8d8", "sash": "#9a2c22", "hair": "#d8b45a", "eye": "#3a7ad0", "glasses": True, "bangs": True},
    "seohwi_battle": {"robe": "#2c3550", "robe2": "#efe8d8", "sash": "#9a2c22", "hair": "#d8b45a", "eye": "#3a7ad0", "glasses": True, "bangs": True, "arms": "fight"},
    "baegun": {"robe": "#cfcabd", "robe2": "#efe8d8", "sash": "#6e6a60", "hair": "#e8e4dc", "beard": "#e8e4dc", "long_hair": True, "arms": "staff"},
    "baegun_boss": {"robe": "#3a2a40", "robe2": "#1e1a22", "sash": "#9a2c22", "hair": "#e8e4dc", "beard": "#e8e4dc", "hat": "satgat", "eye": "#c0392b", "arms": "staff"},
    "king": {"robe": "#b8352f", "robe2": "#8a2420", "sash": "#d9b45a", "hat": "ikseon", "badge": "#f0c040", "beard": "#2a1d1a"},
    "darae_court": {"robe": "#4f7a4a", "robe2": "#e8968a", "sash": "#d9b45a", "hair": "#4a3020", "hat": "bun", "blush": True},
    "hero_physician": {"robe": "#5a8aa0", "robe2": "#efe8d8", "sash": "#2c3550", "hair": "#4a2a1a", "hat": "garima", "long_hair": True},
    "addict": {"robe": "#7a7468", "robe2": "#5a554c", "sash": "#4a4038", "hat": "messy", "dark_eyes": True, "skin": "#d8b89a"},
}

ONLY = ["seohwi_dutch", "hero_adult", "heo_ill", "dutch_child", "haejeok", "rat"]

if __name__ == "__main__":
    for name, o in CHARS.items():
        if name not in ONLY:
            continue
        figure(o).save(os.path.join(OUT, name + ".png"))
        print(name)
