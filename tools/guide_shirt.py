# Draws the tour-guide polo as a classic Roblox shirt template (585 x 559, transparent background): teal, collar with a white
# undershirt V, 3-button placket, LIPA TOUR badge, short sleeves (the rest of each arm transparent so skin shows).
# Usage: python tools/guide_shirt.py <out.png> [preview.png]   (needs Pillow and Windows' Arial Bold)
# The output was uploaded to Roblox on 2026-10-22 as rbxassetid://71550766060779 (used by builders/guides.luau). The PNG is not
# kept in the repo; if the design changes, redraw, upload the new image, and update the asset id in the builder and its check.
import sys
from PIL import Image, ImageDraw, ImageFont

W, H = 585, 559
TEAL = (0, 150, 160, 255)
TEAL_DARK = (0, 112, 122, 255)
TEAL_LIGHT = (40, 175, 185, 255)
WHITE = (245, 245, 240, 255)
GOLD = (250, 200, 40, 255)
FONT = "C:/Windows/Fonts/arialbd.ttf"

img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
d = ImageDraw.Draw(img)

def box(x, y, w, h, fill=TEAL):
    d.rectangle([x, y, x + w - 1, y + h - 1], fill=fill)

def shade(x, y, w, h):
    # soft darker edges so the flat colour reads as cloth
    d.rectangle([x, y, x + w - 1, y + h - 1], outline=TEAL_DARK, width=3)

# ---------------- Torso (front 231,74 / back 427,74 / right side 165,74 / left side 361,74 / top 231,8 / bottom 231,204)
for (x, y, w, h) in [(231, 74, 128, 128), (427, 74, 128, 128), (165, 74, 64, 128), (361, 74, 64, 128), (231, 8, 128, 64), (231, 204, 128, 64)]:
    box(x, y, w, h)
for (x, y, w, h) in [(231, 74, 128, 128), (427, 74, 128, 128), (165, 74, 64, 128), (361, 74, 64, 128)]:
    shade(x, y, w, h)
    box(x, y + h - 8, w, 8, TEAL_DARK)  # bottom hem

# Front: open polo collar with a white undershirt V, placket with 3 buttons, LIPA TOUR badge on the wearer's left chest
fx, fy = 231, 74
cx = fx + 64
d.polygon([(cx - 20, fy), (cx + 20, fy), (cx, fy + 26)], fill=WHITE)              # undershirt V
d.polygon([(cx - 34, fy), (cx - 20, fy), (cx - 2, fy + 28), (cx - 22, fy + 22)], fill=TEAL_LIGHT, outline=TEAL_DARK)  # collar flap L
d.polygon([(cx + 34, fy), (cx + 20, fy), (cx + 2, fy + 28), (cx + 22, fy + 22)], fill=TEAL_LIGHT, outline=TEAL_DARK)  # collar flap R
d.rectangle([cx - 5, fy + 26, cx + 5, fy + 62], fill=TEAL_LIGHT, outline=TEAL_DARK)  # placket
for i in range(3):
    by = fy + 33 + i * 11
    d.ellipse([cx - 3, by - 3, cx + 3, by + 3], fill=WHITE, outline=TEAL_DARK)
# badge: the wearer's left chest is the viewer's right on the front face
bx, by, r = fx + 98, fy + 40, 17
d.ellipse([bx - r, by - r, bx + r, by + r], fill=WHITE, outline=GOLD, width=3)
font = ImageFont.truetype(FONT, 9)
for text, dy in (("LIPA", -6), ("TOUR", 5)):
    tw = d.textlength(text, font=font)
    d.text((bx - tw / 2, by + dy - 5), text, font=font, fill=TEAL_DARK)

# Back: collar band across the top
box(427 + 30, 74, 68, 10, TEAL_LIGHT)
d.rectangle([427 + 30, 74, 427 + 97, 83], outline=TEAL_DARK)
# Top face: collar ring
d.rectangle([231 + 34, 8 + 18, 231 + 93, 8 + 45], outline=TEAL_LIGHT, width=6)

# ---------------- Arms: short sleeves (top 52 px of each 128-px arm face), the rest transparent so skin shows
SLEEVE = 52
ARMS = [
    # right arm: L 19, B 85, R 151, F 217 at y 355; up 217,289
    [(19, 355), (85, 355), (151, 355), (217, 355)],
    # left arm: F 308, L 374, B 440, R 506 at y 355; up 308,289
    [(308, 355), (374, 355), (440, 355), (506, 355)],
]
for faces in ARMS:
    for (x, y) in faces:
        box(x, y, 64, SLEEVE)
        d.rectangle([x, y, x + 63, y + SLEEVE - 1], outline=TEAL_DARK, width=2)
        box(x, y + SLEEVE - 7, 64, 7, TEAL_DARK)  # sleeve cuff
for (x, y) in [(217, 289), (308, 289)]:
    box(x, y, 64, 64)

img.save(sys.argv[1])
if len(sys.argv) > 2:
    # preview on a grey checker so transparent areas are visible
    bg = Image.new("RGBA", (W, H), (60, 60, 60, 255))
    cd = ImageDraw.Draw(bg)
    for yy in range(0, H, 16):
        for xx in range(0, W, 16):
            if (xx // 16 + yy // 16) % 2 == 0:
                cd.rectangle([xx, yy, xx + 15, yy + 15], fill=(80, 80, 80, 255))
    bg.alpha_composite(img)
    bg = bg.resize((W * 2, H * 2), Image.NEAREST)
    bg.save(sys.argv[2])
print("ok")
