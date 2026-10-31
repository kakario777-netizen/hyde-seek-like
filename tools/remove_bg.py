# GitHub Actions에서 실행: assets_src/upload 의 일러스트 배경을 지워 assets_src/raw/chars 로 저장
import glob, os, subprocess, sys, traceback
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets_src", "raw", "chars")
os.makedirs(OUT, exist_ok=True)
log = open(os.path.join(OUT, "log.txt"), "w")
def L(*a):
    print(*a, flush=True); log.write(" ".join(str(x) for x in a) + "\n"); log.flush()
r = subprocess.run([sys.executable, "-m", "pip", "install", "-q", "rembg[cpu]", "onnxruntime"], capture_output=True, text=True)
L("pip", r.returncode, r.stderr[-2000:])
try:
    from rembg import new_session, remove
    from PIL import Image
    for m in ("isnet-anime", "u2net"):
        try:
            s = new_session(m)
        except Exception:
            L("SESSION FAIL", m, traceback.format_exc()); continue
        for f in sorted(glob.glob(os.path.join(ROOT, "assets_src", "upload", "*.png"))):
            try:
                im = Image.open(f).convert("RGB")
                out = remove(im, session=s)
                out.save(os.path.join(OUT, f"{m}__{os.path.basename(f)}"))
                L("ok", m, f)
            except Exception:
                L("FAIL", m, f, traceback.format_exc())
except Exception:
    L("TOP FAIL", traceback.format_exc())
