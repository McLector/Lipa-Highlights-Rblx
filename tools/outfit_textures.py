"""Draw 2D clothing textures for the Lipa Tour avatars (Roblox classic clothing).

Template: Roblox classic clothing, a 585 x 559 RGBA PNG.

Sources:
- Official docs: https://create.roblox.com/docs/avatar/classic-clothing
- Official template PNGs, which the rectangles below were measured from:
  https://prod.docsiteassets.roblox.com/assets/accessories/classic-clothing/Template-Shirts-R15.png
  https://prod.docsiteassets.roblox.com/assets/accessories/classic-clothing/Template-Pants-R15.png
  Each rectangle is fully coloured inside (every pixel) and at least 99.5 percent
  background in its 2 px ring. A red overlay of the rectangles sits on the labelled
  faces. The face sizes also agree with
  https://generalistprogrammer.com/tutorials/how-to-make-roblox-shirts and
  https://random-cactus.github.io/ .

The official pants template also has a TORSO cross (the hip), so pants use the same
18 regions as shirts. The hip is painted in the trouser or skirt colour.

Usage: python tools/outfit_textures.py --out scratch/textures
"""

import argparse
import functools
import hashlib
import sys
from collections import namedtuple
from pathlib import Path

from PIL import Image, ImageDraw

CANVAS_SIZE = (585, 559)
KINDS = ("shirt", "pants")
LIMB_LONG = ("front", "back", "left", "right")

# Face rectangles (x, y, w, h). Labels follow the official template.
SHIRT_REGIONS = {
    "torso_up": (231, 8, 128, 64),
    "torso_right": (165, 74, 64, 128),
    "torso_front": (231, 74, 128, 128),
    "torso_left": (361, 74, 64, 128),
    "torso_back": (427, 74, 128, 128),
    "torso_down": (231, 204, 128, 64),
    "right_arm_left": (19, 355, 64, 128),
    "right_arm_back": (85, 355, 64, 128),
    "right_arm_right": (151, 355, 64, 128),
    "right_arm_front": (217, 355, 64, 128),
    "right_arm_up": (217, 289, 64, 64),
    "right_arm_down": (217, 485, 64, 64),
    "left_arm_front": (308, 355, 64, 128),
    "left_arm_left": (374, 355, 64, 128),
    "left_arm_back": (440, 355, 64, 128),
    "left_arm_right": (506, 355, 64, 128),
    "left_arm_up": (308, 289, 64, 64),
    "left_arm_down": (308, 485, 64, 64),
}
PANTS_REGIONS = {name.replace("arm", "leg"): rect for name, rect in SHIRT_REGIONS.items()}

# Palette (RGB). Skin is the tone named in the brief.
SKIN = (224, 172, 135)
WHITE = (250, 250, 250)

# Barong (sheer ivory long sleeves, embroidered front panels, charcoal trousers).
IVORY = (247, 241, 224)
EMB_LINE = (228, 218, 192)
LEAF = (222, 210, 180)
LEAF_RIB = (204, 192, 160)
COLLAR = (240, 233, 214)
COLLAR_EDGE = (212, 202, 176)
PLACKET = (236, 228, 206)
PLACKET_EDGE = (212, 202, 176)
BUTTON = (190, 180, 150)
SEAM = (232, 224, 204)
HEM = (226, 216, 190)
CUFF = (236, 228, 206)
CUFF_EDGE = (214, 204, 178)
CHARCOAL = (54, 54, 60)
CREASE_DARK = (62, 62, 70)
CREASE_LIGHT = (72, 72, 80)

# Baro't Saya (cream blouse, fichu, red tapis, short sleeves over bare arms, red saya).
BLOUSE = (250, 246, 236)
SLEEVE = (253, 250, 244)
SLEEVE_EDGE = (226, 214, 192)
FICHU = (255, 253, 248)
FICHU_EDGE = (226, 206, 160)
TAPIS = (139, 0, 0)
TAPIS_EDGE = (110, 0, 0)
PLAID = (176, 44, 44)
NECK_TRIM = (232, 222, 204)
SAYA = (150, 22, 34)
SAYA_HEM = (116, 12, 24)
SAYA_FOLD = (172, 40, 52)

# Kuya Ben (cook): red apron over a white tee.
TEE_WHITE = (246, 246, 244)
APRON_RED = (176, 32, 38)
APRON_STRAP = (124, 20, 26)
NAVY = (36, 46, 74)

# Mika (barista): dark brown apron over a cream shirt.
SHIRT_CREAM = (242, 232, 212)
CUFF_CREAM = (226, 214, 190)
CUFF_CREAM_EDGE = (204, 192, 166)
APRON_BROWN = (74, 45, 30)
APRON_BROWN_DARK = (52, 30, 20)
BROWN_TROUSER = (56, 40, 30)

# Aling Nena (vendor): warm floral blouse.
BLOUSE_WARM = (240, 164, 74)
FLOWER_RED = (206, 60, 50)
FLOWER_PINK = (240, 128, 140)
FLOWER_CENTRE = (250, 216, 96)
LEAF_GREEN = (84, 150, 70)
RUFFLE = (255, 200, 130)
RUFFLE_EDGE = (226, 160, 96)
MAROON = (116, 40, 52)
MAROON_BELT = (84, 28, 38)

# Lola Cora (parishioner): soft lilac blouse with a small white collar.
LILAC = (204, 186, 226)
LILAC_CUFF = (186, 166, 210)
LILAC_EDGE = (160, 140, 186)
BUTTON_LILAC = (236, 226, 246)
DARK_GREY = (68, 68, 74)

# Paolo (football player): blue striped jersey, number 10, shorts.
JERSEY_BLUE = (34, 84, 176)
JERSEY_STRIPE = (60, 116, 204)
SHORTS_NAVY = (22, 38, 84)
DIGIT_WHITE = (244, 244, 244)
DIGIT_SHADOW = (18, 40, 100)

# Ms Grace (resort staff): sage polo with a leaf mark.
SAGE = (156, 175, 136)
POLO_COLLAR = (138, 158, 118)
POLO_EDGE = (116, 136, 98)
PLACKET_WHITE = (236, 232, 216)
PLACKET_BUTTON = (196, 190, 170)
LEAF_MARK = (84, 110, 70)
LEAF_MARK_RIB = (200, 214, 186)
KHAKI = (196, 178, 140)
KHAKI_BELT = (170, 152, 116)

# Jun (caddie): white polo with green visor-colour trim.
WHITE_POLO = (248, 248, 246)
GREEN_TRIM = (34, 120, 72)
OLIVE = (76, 86, 62)
OLIVE_CREASE = ((92, 104, 78), (104, 116, 90))

# Mang Tonyo (fisherman): faded teal long sleeves, rolled cuffs.
FADED_TEAL = (96, 152, 150)
FADE_LIGHT = (120, 172, 168)
FADE_DARK = (80, 128, 126)
DENIM = (72, 96, 124)
DENIM_FADE = (96, 120, 150)

# Ate Liza (chapel volunteer): plain muted blue-grey blouse.
MUTED_BLUE_GREY = (118, 132, 146)
NECK_TRIM_GREY = (104, 118, 132)
ATE_EDGE = (92, 106, 120)
SLATE = (58, 60, 66)
SLATE_CREASE = ((72, 74, 80), (80, 82, 88))

DIGIT_ROWS = {
    "0": ("###", "#.#", "#.#", "#.#", "###"),
    "1": (".#.", "##.", ".#.", ".#.", "###"),
    "2": ("###", "..#", "###", "#..", "###"),
    "3": ("###", "..#", "###", "..#", "###"),
    "4": ("#.#", "#.#", "###", "..#", "..#"),
    "5": ("###", "#..", "###", "..#", "###"),
    "6": ("###", "#..", "###", "#.#", "###"),
    "7": ("###", "..#", "..#", "..#", "..#"),
    "8": ("###", "#.#", "###", "#.#", "###"),
    "9": ("###", "#.#", "###", "..#", "###"),
}

Part = namedtuple("Part", ["base", "paint"])
Design = namedtuple("Design", ["shirt", "pants"])


def _ink(rgb):
    return (rgb[0], rgb[1], rgb[2], 255)


def _scale(rgb, factor):
    return tuple(max(0, min(255, int(round(c * factor)))) for c in rgb)


def _group(face):
    return face.rpartition("_")[0]


def _side(face):
    return face.rpartition("_")[2]


def _rect(draw, x, y, w, h, rgb):
    draw.rectangle([x, y, x + w - 1, y + h - 1], fill=_ink(rgb))


def _poly(draw, points, rgb):
    draw.polygon(points, fill=_ink(rgb))


def _disc(draw, cx, cy, r, rgb):
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=_ink(rgb))


def _vline(draw, x, y0, y1, rgb):
    draw.line([(x, y0), (x, y1)], fill=_ink(rgb), width=1)


def _hline(draw, x0, x1, y, rgb, width=1):
    draw.line([(x0, y), (x1, y)], fill=_ink(rgb), width=width)


def _leaf(draw, cx, cy, half_h, half_w, rgb, rib):
    draw.polygon(
        [(cx, cy - half_h), (cx + half_w, cy), (cx, cy + half_h), (cx - half_w, cy)],
        fill=_ink(rgb),
    )
    draw.line([(cx, cy - half_h + 2), (cx, cy + half_h - 2)], fill=_ink(rib), width=1)


def _flower(draw, cx, cy, r, petal):
    half = max(2, r // 2)
    _disc(draw, cx - r, cy - half, 3, LEAF_GREEN)
    _disc(draw, cx + r, cy + half, 3, LEAF_GREEN)
    for dx, dy in ((-half, 0), (half, 0), (0, -half), (0, half)):
        _disc(draw, cx + dx, cy + dy, half, petal)
    _disc(draw, cx, cy, max(1, r // 3), FLOWER_CENTRE)


def _stripes(draw, w, h, rgb):
    for x in range(8, w, 16):
        _rect(draw, x, 0, 8, h, rgb)


def _tapis(draw, w, h):
    """Deep red wrap-around band at the waist, with a faint plaid."""
    top = 84
    _rect(draw, 0, top, w, h - top, TAPIS)
    _hline(draw, 0, w - 1, top, TAPIS_EDGE)
    for x in range(4, w, 14):
        draw.line([(x, top), (x, h - 1)], fill=_ink(PLAID), width=2)
    for y in range(top + 6, h, 14):
        _hline(draw, 0, w - 1, y, PLAID, width=2)


def _number(draw, text, x, y, scale, rgb, shadow):
    """Draw digits from a 3 x 5 bitmap font, with a drop shadow."""
    cells = []
    cursor = x
    for char in text:
        for row_index, row in enumerate(DIGIT_ROWS[char]):
            for col_index, cell in enumerate(row):
                if cell == "#":
                    cells.append((cursor + col_index * scale, y + row_index * scale))
        cursor += 4 * scale
    for cx, cy in cells:
        draw.rectangle([cx + 3, cy + 3, cx + scale + 2, cy + scale + 2], fill=_ink(shadow))
    for cx, cy in cells:
        draw.rectangle([cx, cy, cx + scale - 1, cy + scale - 1], fill=_ink(rgb))


def _seam(tile):
    """Darken the outer edge and lighten the first inner ring, from the painted pixels.

    Using the pixels underneath (not the cloth colour) keeps the seam on bare skin
    skin-coloured instead of framing it in the sleeve or trouser colour.
    """
    w, h = tile.size
    px = tile.load()

    def shade(x, y, factor):
        r, g, b, a = px[x, y]
        px[x, y] = _scale((r, g, b), factor) + (a,)

    for x in range(w):
        shade(x, 0, 0.86)
        shade(x, h - 1, 0.86)
    for y in range(1, h - 1):
        shade(0, y, 0.86)
        shade(w - 1, y, 0.86)
    for x in range(1, w - 1):
        shade(x, 1, 1.04)
        shade(x, h - 2, 1.04)
    for y in range(2, h - 2):
        shade(1, y, 1.04)
        shade(w - 2, y, 1.04)


def _short_arm(sleeve_len, trim=None):
    """Sleeve colour down to sleeve_len, bare skin below, skin on the wrist end."""

    def paint(face, draw, w, h):
        side = _side(face)
        if side in LIMB_LONG:
            _rect(draw, 0, sleeve_len, w, h - sleeve_len, SKIN)
            if trim is not None:
                _rect(draw, 0, sleeve_len - 6, w, 6, trim)
        elif side == "down":
            _rect(draw, 0, 0, w, h, SKIN)

    return paint


def _long_arm(cuff):
    """Long sleeve with an optional cuff band (top y, colour, edge colour)."""

    def paint(face, draw, w, h):
        if cuff is not None and _side(face) in LIMB_LONG:
            top, rgb, edge = cuff
            _rect(draw, 0, top, w, 15, rgb)
            _hline(draw, 0, w - 1, top, edge)

    return paint


def _trousers(face, draw, w, h, crease=None, waist=None):
    """Plain trousers with an optional front crease and waistband."""
    group, side = _group(face), _side(face)
    if crease is not None and side == "front":
        _vline(draw, w // 2 - 1, 0, h - 1, crease[0])
        _vline(draw, w // 2, 0, h - 1, crease[1])
    if waist is not None and group == "torso" and side in LIMB_LONG:
        _hline(draw, 0, w - 1, 3, waist)


def _barong_shirt(face, draw, w, h):
    group, side = _group(face), _side(face)
    if group == "torso":
        if side == "front":
            draw.rectangle([26, 22, 46, 118], outline=_ink(EMB_LINE))
            draw.rectangle([82, 22, 102, 118], outline=_ink(EMB_LINE))
            for x in (30, 42, 86, 98):
                _vline(draw, x, 24, 116, EMB_LINE)
            for cx in (36, 92):
                for cy in (40, 66, 92):
                    _leaf(draw, cx, cy, 6, 3, LEAF, LEAF_RIB)
            _poly(draw, [(34, 0), (94, 0), (64, 30)], COLLAR)
            draw.line([(34, 0), (64, 30), (94, 0)], fill=_ink(COLLAR_EDGE), width=2)
            _rect(draw, 59, 30, 10, 98, PLACKET)
            _vline(draw, 59, 30, h - 1, PLACKET_EDGE)
            _vline(draw, 68, 30, h - 1, PLACKET_EDGE)
            for cy in (46, 66, 86, 106):
                _disc(draw, 64, cy, 2, BUTTON)
        elif side == "back":
            _rect(draw, 44, 0, 40, 4, COLLAR)
            _hline(draw, 44, 83, 4, COLLAR_EDGE)
        elif side in ("left", "right"):
            _vline(draw, 32, 0, h - 1, SEAM)
        elif side == "down":
            _hline(draw, 0, w - 1, 6, HEM)
    else:
        _long_arm((104, CUFF, CUFF_EDGE))(face, draw, w, h)


def _barotsaya_shirt(face, draw, w, h):
    group, side = _group(face), _side(face)
    if group == "torso":
        if side == "front":
            _tapis(draw, w, h)
            _poly(draw, [(0, 0), (127, 0), (64, 80)], FICHU)
            draw.line([(0, 0), (64, 80), (127, 0)], fill=_ink(FICHU_EDGE), width=2)
        elif side == "back":
            _tapis(draw, w, h)
            _hline(draw, 30, 97, 4, NECK_TRIM, width=2)
        elif side in ("left", "right"):
            _tapis(draw, w, h)
        elif side == "down":
            _rect(draw, 0, 0, w, h, TAPIS)
    else:
        if side in LIMB_LONG:
            _rect(draw, 0, 40, w, h - 40, SKIN)
            draw.ellipse([-8, -10, w + 7, 57], fill=_ink(SLEEVE), outline=_ink(SLEEVE_EDGE))
        elif side == "up":
            _rect(draw, 0, 0, w, h, SLEEVE)
        else:
            _rect(draw, 0, 0, w, h, SKIN)


def _barotsaya_pants(face, draw, w, h):
    group, side = _group(face), _side(face)
    if side == "down":
        _rect(draw, 0, 0, w, h, SAYA_HEM)
        return
    if group != "torso" and side in LIMB_LONG:
        _rect(draw, 0, 96, w, h - 96, SAYA_HEM)
        _hline(draw, 0, w - 1, 96, SAYA_FOLD)
    if side == "front":
        _vline(draw, w // 2, 0, h - 1, SAYA_FOLD)


def _kuya_ben_shirt(face, draw, w, h):
    group, side = _group(face), _side(face)
    if group == "torso":
        if side == "front":
            _rect(draw, 22, 40, 84, 88, APRON_RED)
            _rect(draw, 28, 0, 5, 40, APRON_STRAP)
            _rect(draw, 95, 0, 5, 40, APRON_STRAP)
            draw.rectangle([46, 84, 81, 109], outline=_ink(APRON_STRAP))
        elif side in ("back", "left", "right"):
            _hline(draw, 0, w - 1, 70, APRON_STRAP, width=2)
    else:
        _short_arm(52)(face, draw, w, h)


def _mika_shirt(face, draw, w, h):
    group, side = _group(face), _side(face)
    if group == "torso":
        if side == "front":
            _rect(draw, 26, 30, 76, 98, APRON_BROWN)
            _rect(draw, 34, 0, 3, 30, APRON_BROWN_DARK)
            _rect(draw, 91, 0, 3, 30, APRON_BROWN_DARK)
            draw.rectangle([46, 74, 81, 101], outline=_ink(APRON_BROWN_DARK))
        elif side in ("back", "left", "right"):
            _hline(draw, 0, w - 1, 64, APRON_BROWN_DARK, width=2)
    else:
        _long_arm((104, CUFF_CREAM, CUFF_CREAM_EDGE))(face, draw, w, h)


def _flowers_at(draw, points, radius, petal):
    for cx, cy in points:
        _flower(draw, cx, cy, radius, petal)


def _aling_nena_shirt(face, draw, w, h):
    group, side = _group(face), _side(face)
    if group == "torso":
        if side == "front":
            _flowers_at(draw, [(24, 24), (104, 24), (64, 58), (24, 100), (104, 100)], 9, FLOWER_RED)
        elif side == "back":
            _flowers_at(draw, [(32, 30), (96, 30), (64, 72), (32, 110), (96, 110)], 9, FLOWER_PINK)
        elif side in ("left", "right"):
            _flowers_at(draw, [(32, 36), (32, 100)], 8, FLOWER_RED)
        elif side == "up":
            _flowers_at(draw, [(32, 32), (96, 32)], 7, FLOWER_PINK)
        elif side == "down":
            _hline(draw, 0, w - 1, 8, FLOWER_PINK)
    else:
        if side in LIMB_LONG:
            _flower(draw, 32, 60, 8, FLOWER_PINK)
        _long_arm((112, RUFFLE, RUFFLE_EDGE))(face, draw, w, h)


def _lola_cora_shirt(face, draw, w, h):
    group, side = _group(face), _side(face)
    if group == "torso":
        if side == "front":
            _poly(draw, [(40, 0), (88, 0), (64, 20)], WHITE)
            draw.line([(40, 0), (64, 20), (88, 0)], fill=_ink(LILAC_EDGE), width=1)
            for cy in (40, 56, 72):
                _disc(draw, 64, cy, 2, BUTTON_LILAC)
        elif side == "back":
            _rect(draw, 40, 0, 48, 4, WHITE)
    else:
        _long_arm((104, LILAC_CUFF, LILAC_EDGE))(face, draw, w, h)


def _paolo_shirt(face, draw, w, h):
    group, side = _group(face), _side(face)
    if group == "torso":
        _stripes(draw, w, h, JERSEY_STRIPE)
        if side == "front":
            _rect(draw, 44, 0, 40, 6, WHITE)
        elif side == "back":
            _number(draw, "10", 15, 29, 14, DIGIT_WHITE, DIGIT_SHADOW)
    elif side in LIMB_LONG:
        _stripes(draw, w, 56, JERSEY_STRIPE)
        _rect(draw, 0, 56, w, h - 56, SKIN)
    elif side == "up":
        _stripes(draw, w, h, JERSEY_STRIPE)
    else:
        _rect(draw, 0, 0, w, h, SKIN)


def _paolo_pants(face, draw, w, h):
    group, side = _group(face), _side(face)
    if group == "torso":
        if side in LIMB_LONG:
            _rect(draw, 0, 0, w, 6, WHITE)
        return
    if side in LIMB_LONG:
        _rect(draw, 0, 84, w, h - 84, SKIN)
        _rect(draw, 0, 84, w, 4, WHITE)
    elif side == "down":
        _rect(draw, 0, 0, w, h, SKIN)


def _ms_grace_shirt(face, draw, w, h):
    group, side = _group(face), _side(face)
    if group == "torso":
        if side == "front":
            _poly(draw, [(40, 0), (88, 0), (64, 24)], POLO_COLLAR)
            draw.line([(40, 0), (64, 24), (88, 0)], fill=_ink(POLO_EDGE), width=2)
            _rect(draw, 60, 24, 8, 30, PLACKET_WHITE)
            for cy in (32, 44):
                _disc(draw, 64, cy, 2, PLACKET_BUTTON)
            _leaf(draw, 92, 84, 12, 5, LEAF_MARK, LEAF_MARK_RIB)
        elif side == "back":
            _rect(draw, 40, 0, 48, 4, POLO_COLLAR)
    else:
        _short_arm(56, trim=POLO_COLLAR)(face, draw, w, h)


def _jun_shirt(face, draw, w, h):
    group, side = _group(face), _side(face)
    if group == "torso":
        if side == "front":
            _poly(draw, [(40, 0), (88, 0), (64, 24)], WHITE_POLO)
            draw.line([(40, 0), (64, 24), (88, 0)], fill=_ink(GREEN_TRIM), width=3)
            _vline(draw, 59, 24, 60, GREEN_TRIM)
            _vline(draw, 68, 24, 60, GREEN_TRIM)
            for cy in (32, 44, 56):
                _disc(draw, 64, cy, 2, GREEN_TRIM)
        elif side == "back":
            _rect(draw, 40, 0, 48, 3, GREEN_TRIM)
    else:
        _short_arm(56, trim=GREEN_TRIM)(face, draw, w, h)


def _mang_tonyo_shirt(face, draw, w, h):
    group, side = _group(face), _side(face)
    if group == "torso":
        if side == "front":
            for cx, cy, r in ((30, 30, 14), (100, 66, 10), (56, 104, 12)):
                _disc(draw, cx, cy, r, FADE_LIGHT)
        elif side == "back":
            for cx, cy, r in ((96, 40, 12), (30, 96, 10)):
                _disc(draw, cx, cy, r, FADE_LIGHT)
        elif side in ("left", "right"):
            _disc(draw, 32, 60, 10, FADE_LIGHT)
    else:
        if side in LIMB_LONG:
            _rect(draw, 0, 96, w, 14, FADE_LIGHT)
            _hline(draw, 0, w - 1, 96, FADE_DARK)
            _hline(draw, 0, w - 1, 109, FADE_DARK)
            _rect(draw, 0, 110, w, h - 110, SKIN)
        elif side == "down":
            _rect(draw, 0, 0, w, h, SKIN)


def _mang_tonyo_pants(face, draw, w, h):
    group, side = _group(face), _side(face)
    if group != "torso" and side in LIMB_LONG:
        _disc(draw, 20, 46, 10, DENIM_FADE)
        _disc(draw, 46, 96, 8, DENIM_FADE)


def _ate_liza_shirt(face, draw, w, h):
    group, side = _group(face), _side(face)
    if group == "torso":
        if side in ("front", "back"):
            _rect(draw, 44, 0, 40, 4, NECK_TRIM_GREY)
    else:
        _long_arm((110, NECK_TRIM_GREY, ATE_EDGE))(face, draw, w, h)


DESIGNS = {
    "barong": Design(
        shirt=Part(IVORY, _barong_shirt),
        pants=Part(CHARCOAL, functools.partial(_trousers, crease=(CREASE_DARK, CREASE_LIGHT))),
    ),
    "barotsaya": Design(
        shirt=Part(BLOUSE, _barotsaya_shirt),
        pants=Part(SAYA, _barotsaya_pants),
    ),
    "persona_kuya_ben": Design(
        shirt=Part(TEE_WHITE, _kuya_ben_shirt),
        pants=Part(NAVY, functools.partial(_trousers, crease=((40, 52, 84), (50, 64, 98)))),
    ),
    "persona_mika": Design(
        shirt=Part(SHIRT_CREAM, _mika_shirt),
        pants=Part(BROWN_TROUSER, _trousers),
    ),
    "persona_aling_nena": Design(
        shirt=Part(BLOUSE_WARM, _aling_nena_shirt),
        pants=Part(MAROON, functools.partial(_trousers, waist=MAROON_BELT)),
    ),
    "persona_lola_cora": Design(
        shirt=Part(LILAC, _lola_cora_shirt),
        pants=Part(DARK_GREY, functools.partial(_trousers, crease=((78, 78, 84), (90, 90, 96)))),
    ),
    "persona_paolo": Design(
        shirt=Part(JERSEY_BLUE, _paolo_shirt),
        pants=Part(SHORTS_NAVY, _paolo_pants),
    ),
    "persona_ms_grace": Design(
        shirt=Part(SAGE, _ms_grace_shirt),
        pants=Part(KHAKI, functools.partial(_trousers, waist=KHAKI_BELT)),
    ),
    "persona_jun": Design(
        shirt=Part(WHITE_POLO, _jun_shirt),
        pants=Part(OLIVE, functools.partial(_trousers, crease=OLIVE_CREASE)),
    ),
    "persona_mang_tonyo": Design(
        shirt=Part(FADED_TEAL, _mang_tonyo_shirt),
        pants=Part(DENIM, _mang_tonyo_pants),
    ),
    "persona_ate_liza": Design(
        shirt=Part(MUTED_BLUE_GREY, _ate_liza_shirt),
        pants=Part(SLATE, functools.partial(_trousers, crease=SLATE_CREASE)),
    ),
}
OUTFITS = tuple(DESIGNS)


def render(outfit_name, kind):
    """Return the 585 x 559 RGBA texture for one outfit and kind ('shirt' or 'pants')."""
    if not isinstance(outfit_name, str):
        raise TypeError("outfit_name must be a str")
    if not isinstance(kind, str):
        raise TypeError("kind must be a str")
    if outfit_name not in DESIGNS:
        raise ValueError(f"unknown outfit: {outfit_name!r}")
    if kind not in KINDS:
        raise ValueError(f"unknown kind: {kind!r}")
    part = getattr(DESIGNS[outfit_name], kind)
    regions = SHIRT_REGIONS if kind == "shirt" else PANTS_REGIONS
    canvas = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    for face, (x, y, w, h) in regions.items():
        tile = Image.new("RGBA", (w, h), _ink(part.base))
        draw = ImageDraw.Draw(tile)
        part.paint(face, draw, w, h)
        _seam(tile)
        canvas.paste(tile, (x, y))
    return canvas


def main(argv=None):
    parser = argparse.ArgumentParser(description="Render the Lipa Tour clothing textures as PNG files.")
    parser.add_argument("--out", required=True, help="folder to write the PNG files into")
    args = parser.parse_args(argv)
    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)
    for outfit in OUTFITS:
        for kind in KINDS:
            img = render(outfit, kind)
            path = out_dir / f"{outfit}_{kind}.png"
            img.save(path, format="PNG")
            digest = hashlib.sha256(path.read_bytes()).hexdigest()
            print(f"{path.name} {img.width}x{img.height} sha256={digest[:12]}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
