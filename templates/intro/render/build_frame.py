"""Builds intro_frame.png: the full artwork (uncropped, full tagline visible)
composited onto a procedural starfield that extends to fill 1080x1920,
so the frame is full-bleed without flat letterbox bars or any cropped text.
Run from templates/intro/render/: python3 build_frame.py
"""
import random
from PIL import Image, ImageDraw

SRC = "../../../brand/assets/sy-intro-source.png"
OUT = "../intro_frame.png"
W, H = 1080, 1920
BASE_COLOR = (3, 6, 16)

random.seed(42)
canvas = Image.new("RGB", (W, H), BASE_COLOR)
draw = ImageDraw.Draw(canvas)

for _ in range(260):
    x = random.randint(0, W)
    y = random.randint(0, H)
    size = random.choice([1, 1, 1, 2, 2, 3])
    b = random.randint(90, 230)
    color = (b, b, min(255, b + 15))
    if size == 1:
        draw.point((x, y), fill=color)
    else:
        draw.ellipse([x - size // 2, y - size // 2, x + size // 2, y + size // 2], fill=color)

for _ in range(12):
    x = random.randint(0, W)
    y = random.randint(0, H)
    r = random.randint(2, 4)
    draw.ellipse([x - r, y - r, x + r, y + r], fill=(200, 210, 255))

src = Image.open(SRC).convert("RGB")
sw, sh = src.size
new_w = W
new_h = round(sh * (new_w / sw))
src_resized = src.resize((new_w, new_h), Image.LANCZOS)
y_off = (H - new_h) // 2
canvas.paste(src_resized, (0, y_off))
canvas.save(OUT)
print("wrote", OUT, "pasted image at y_off", y_off, "size", new_w, new_h)
