# GitHub Actions에서 실행: assets_src/upload 의 일러스트 배경을 지워 assets_src/raw/chars 로 저장
import glob, os, subprocess, sys
subprocess.run([sys.executable, "-m", "pip", "install", "-q", "rembg", "onnxruntime"], check=True)
from rembg import new_session, remove
from PIL import Image
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets_src", "raw", "chars")
os.makedirs(OUT, exist_ok=True)
sessions = {m: new_session(m) for m in ("isnet-anime", "birefnet-general")}
for f in sorted(glob.glob(os.path.join(ROOT, "assets_src", "upload", "*.png"))):
    im = Image.open(f).convert("RGB")
    for m, s in sessions.items():
        out = remove(im, session=s, post_process_mask=True)
        out.save(os.path.join(OUT, f"{m}__{os.path.basename(f)}"))
        print(m, f, flush=True)
