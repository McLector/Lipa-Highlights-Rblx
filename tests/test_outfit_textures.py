"""Tests for tools/outfit_textures.py, written before the implementation.

Run from the roblox folder:
    python -m unittest tests.test_outfit_textures -v
or:
    python tests/test_outfit_textures.py

Uses only Pillow and the standard library.
"""

import contextlib
import hashlib
import io
import re
import sys
import tempfile
import unittest
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageStat

ROOT = Path(__file__).resolve().parent.parent
MODULE_PATH = ROOT / "tools" / "outfit_textures.py"
CANVAS = (585, 559)
KINDS = ("shirt", "pants")
OUTFITS = (
    "barong",
    "barotsaya",
    "persona_kuya_ben",
    "persona_mika",
    "persona_aling_nena",
    "persona_lola_cora",
    "persona_paolo",
    "persona_ms_grace",
    "persona_jun",
    "persona_mang_tonyo",
    "persona_ate_liza",
)
PERSONA_OUTFITS = tuple(name for name in OUTFITS if name.startswith("persona_"))
SKIN = (224, 172, 135, 255)

# Rectangles (x, y, w, h) read from the official Roblox template PNGs
# Template-Shirts-R15.png and Template-Pants-R15.png, and checked by pixel analysis.
VERIFIED_SHIRT_RECTS = {
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
VERIFIED_PANTS_RECTS = {
    name.replace("arm", "leg"): rect for name, rect in VERIFIED_SHIRT_RECTS.items()
}


def _load():
    """Import the module under test. Raises ModuleNotFoundError until it exists."""
    if str(ROOT) not in sys.path:
        sys.path.insert(0, str(ROOT))
    from tools import outfit_textures

    return outfit_textures


def _expected_size(name):
    parts = name.split("_")
    face = parts[-1]
    if parts[0] == "torso":
        sizes = {
            "front": (128, 128),
            "back": (128, 128),
            "left": (64, 128),
            "right": (64, 128),
            "up": (128, 64),
            "down": (128, 64),
        }
    else:
        sizes = {
            "front": (64, 128),
            "back": (64, 128),
            "left": (64, 128),
            "right": (64, 128),
            "up": (64, 64),
            "down": (64, 64),
        }
    return sizes[face]


def _crop(img, rect):
    x, y, w, h = rect
    return img.crop((x, y, x + w, y + h))


def _count(img, rect, predicate):
    colours = _crop(img, rect).getcolors(maxcolors=rect[2] * rect[3])
    return sum(n for n, colour in colours if predicate(colour))


_RENDER_CACHE = {}


def _render(ot, outfit, kind):
    key = (outfit, kind)
    if key not in _RENDER_CACHE:
        _RENDER_CACHE[key] = ot.render(outfit, kind)
    return _RENDER_CACHE[key]


class RegionLayoutTests(unittest.TestCase):
    def setUp(self):
        self.ot = _load()

    def test_canvas_size_is_the_template_size(self):
        self.assertEqual(self.ot.CANVAS_SIZE, CANVAS)

    def test_shirt_regions_match_the_verified_template_layout(self):
        self.assertEqual(self.ot.SHIRT_REGIONS, VERIFIED_SHIRT_RECTS)

    def test_pants_regions_match_the_verified_template_layout(self):
        self.assertEqual(self.ot.PANTS_REGIONS, VERIFIED_PANTS_RECTS)

    def test_each_kind_uses_eighteen_faces(self):
        self.assertEqual(len(self.ot.SHIRT_REGIONS), 18)
        self.assertEqual(len(self.ot.PANTS_REGIONS), 18)

    def test_face_sizes_match_the_documented_sizes(self):
        for table in (self.ot.SHIRT_REGIONS, self.ot.PANTS_REGIONS):
            for name, (_x, _y, w, h) in table.items():
                with self.subTest(region=name):
                    self.assertEqual((w, h), _expected_size(name))

    def test_regions_lie_inside_the_canvas(self):
        canvas_w, canvas_h = CANVAS
        for table in (self.ot.SHIRT_REGIONS, self.ot.PANTS_REGIONS):
            for name, (x, y, w, h) in table.items():
                with self.subTest(region=name):
                    self.assertGreaterEqual(x, 0)
                    self.assertGreaterEqual(y, 0)
                    self.assertGreater(w, 0)
                    self.assertGreater(h, 0)
                    self.assertLessEqual(x + w, canvas_w)
                    self.assertLessEqual(y + h, canvas_h)

    def test_regions_do_not_overlap(self):
        for table in (self.ot.SHIRT_REGIONS, self.ot.PANTS_REGIONS):
            items = list(table.items())
            for i, (name_a, (ax, ay, aw, ah)) in enumerate(items):
                for name_b, (bx, by, bw, bh) in items[i + 1:]:
                    with self.subTest(a=name_a, b=name_b):
                        overlap_x = ax < bx + bw and bx < ax + aw
                        overlap_y = ay < by + bh and by < ay + ah
                        self.assertFalse(overlap_x and overlap_y)


class OutfitListTests(unittest.TestCase):
    def setUp(self):
        self.ot = _load()

    def test_outfit_names_match_the_brief(self):
        self.assertEqual(tuple(self.ot.OUTFITS), OUTFITS)


class RenderShapeTests(unittest.TestCase):
    def setUp(self):
        self.ot = _load()

    def _regions(self, kind):
        return self.ot.SHIRT_REGIONS if kind == "shirt" else self.ot.PANTS_REGIONS

    def test_every_outfit_renders_585_by_559_rgba(self):
        for outfit in OUTFITS:
            for kind in KINDS:
                with self.subTest(outfit=outfit, kind=kind):
                    img = _render(self.ot, outfit, kind)
                    self.assertIsInstance(img, Image.Image)
                    self.assertEqual(img.size, CANVAS)
                    self.assertEqual(img.mode, "RGBA")

    def test_every_used_region_is_opaque_and_has_three_colours(self):
        for outfit in OUTFITS:
            for kind in KINDS:
                img = _render(self.ot, outfit, kind)
                for name, rect in self._regions(kind).items():
                    with self.subTest(outfit=outfit, kind=kind, region=name):
                        crop = _crop(img, rect)
                        alpha_min, alpha_max = crop.getchannel("A").getextrema()
                        self.assertGreater(alpha_max, 0, "region is fully transparent")
                        self.assertEqual(alpha_min, 255, "region has transparent holes")
                        colours = crop.getcolors(maxcolors=rect[2] * rect[3])
                        self.assertIsNotNone(colours)
                        self.assertGreaterEqual(len(colours), 3)

    def test_pixels_outside_every_region_are_fully_transparent(self):
        for outfit in OUTFITS:
            for kind in KINDS:
                mask = Image.new("L", CANVAS, 0)
                draw = ImageDraw.Draw(mask)
                for x, y, w, h in self._regions(kind).values():
                    draw.rectangle([x, y, x + w - 1, y + h - 1], fill=255)
                outside = mask.point(lambda v: 255 - v)
                alpha = _render(self.ot, outfit, kind).getchannel("A")
                leak = ImageChops.multiply(alpha, outside)
                with self.subTest(outfit=outfit, kind=kind):
                    self.assertEqual(leak.getextrema(), (0, 0))

    def test_same_call_twice_gives_identical_pixels(self):
        for outfit in OUTFITS:
            for kind in KINDS:
                with self.subTest(outfit=outfit, kind=kind):
                    first = self.ot.render(outfit, kind)
                    second = self.ot.render(outfit, kind)
                    self.assertEqual(first.tobytes(), second.tobytes())

    def test_barong_shirt_front_differs_from_every_persona_shirt(self):
        front = self.ot.SHIRT_REGIONS["torso_front"]
        barong = _crop(_render(self.ot, "barong", "shirt"), front).tobytes()
        for outfit in PERSONA_OUTFITS:
            with self.subTest(outfit=outfit):
                other = _crop(_render(self.ot, outfit, "shirt"), front).tobytes()
                self.assertNotEqual(barong, other)

    def test_every_outfit_has_its_own_shirt_front(self):
        front = self.ot.SHIRT_REGIONS["torso_front"]
        fronts = {
            outfit: _crop(_render(self.ot, outfit, "shirt"), front).tobytes()
            for outfit in OUTFITS
        }
        self.assertEqual(len(set(fronts.values())), len(OUTFITS))

    def test_barong_shirt_front_is_light_cream(self):
        front = _crop(_render(self.ot, "barong", "shirt"), self.ot.SHIRT_REGIONS["torso_front"])
        means = ImageStat.Stat(front.convert("RGB")).mean
        self.assertTrue(all(m > 200 for m in means), means)

    def test_barong_pants_are_dark_charcoal(self):
        img = _render(self.ot, "barong", "pants")
        means = ImageStat.Stat(img.convert("RGB"), img.getchannel("A")).mean
        self.assertTrue(all(m < 90 for m in means), means)

    def test_barotsaya_shows_skin_below_the_sleeves(self):
        img = _render(self.ot, "barotsaya", "shirt")
        for region in ("right_arm_front", "left_arm_front"):
            with self.subTest(region=region):
                skin = _count(img, self.ot.SHIRT_REGIONS[region], lambda c: c == SKIN)
                self.assertGreater(skin, 1000)

    def test_barotsaya_shirt_front_has_a_deep_red_tapis_band(self):
        img = _render(self.ot, "barotsaya", "shirt")
        reds = _count(
            img,
            self.ot.SHIRT_REGIONS["torso_front"],
            lambda c: c[0] >= 120 and c[1] <= 60 and c[2] <= 60,
        )
        self.assertGreater(reds, 2000)

    def test_barotsaya_pants_are_saya_red(self):
        img = _render(self.ot, "barotsaya", "pants")
        means = ImageStat.Stat(img.convert("RGB"), img.getchannel("A")).mean
        self.assertGreater(means[0], means[1] + 60)
        self.assertGreater(means[0], means[2] + 60)

    def test_paolo_back_carries_the_number_ten_in_white(self):
        img = _render(self.ot, "persona_paolo", "shirt")
        white = _count(
            img,
            self.ot.SHIRT_REGIONS["torso_back"],
            lambda c: min(c[:3]) >= 230 and c[3] == 255,
        )
        self.assertGreater(white, 300)


class RenderErrorTests(unittest.TestCase):
    def setUp(self):
        self.ot = _load()

    def test_unknown_outfit_raises_value_error(self):
        with self.assertRaises(ValueError):
            self.ot.render("persona_nobody", "shirt")

    def test_unknown_kind_raises_value_error(self):
        with self.assertRaises(ValueError):
            self.ot.render("barong", "hat")

    def test_empty_outfit_name_raises_value_error(self):
        with self.assertRaises(ValueError):
            self.ot.render("", "shirt")

    def test_empty_kind_raises_value_error(self):
        with self.assertRaises(ValueError):
            self.ot.render("barong", "")

    def test_none_outfit_name_raises_type_error(self):
        with self.assertRaises(TypeError):
            self.ot.render(None, "shirt")

    def test_none_kind_raises_type_error(self):
        with self.assertRaises(TypeError):
            self.ot.render("barong", None)

    def test_outfit_name_must_match_exactly(self):
        for bad in ("Barong", "BAROTSAYA", "barong ", "persona_mika/"):
            with self.subTest(name=bad):
                with self.assertRaises(ValueError):
                    self.ot.render(bad, "shirt")

    def test_kind_must_match_exactly(self):
        for bad in ("Shirt", "PANTS", "shirt "):
            with self.subTest(kind=bad):
                with self.assertRaises(ValueError):
                    self.ot.render("barong", bad)


class CliTests(unittest.TestCase):
    def setUp(self):
        self.ot = _load()

    def _run(self, argv):
        out = io.StringIO()
        with contextlib.redirect_stdout(out):
            code = self.ot.main(argv)
        return code, out.getvalue()

    def test_writes_one_png_per_outfit_and_kind(self):
        with tempfile.TemporaryDirectory() as tmp:
            code, _ = self._run(["--out", tmp])
            self.assertEqual(code, 0)
            names = sorted(p.name for p in Path(tmp).iterdir())
            expected = sorted(f"{outfit}_{kind}.png" for outfit in OUTFITS for kind in KINDS)
            self.assertEqual(len(names), 22)
            self.assertEqual(names, expected)
            for name in names:
                with Image.open(Path(tmp) / name) as im:
                    self.assertEqual(im.size, CANVAS)
                    self.assertEqual(im.mode, "RGBA")

    def test_prints_one_line_per_file_with_size_and_sha_prefix(self):
        line_re = re.compile(r"^([a-z_]+\.png) (\d+)x(\d+) sha256=([0-9a-f]{12})$")
        with tempfile.TemporaryDirectory() as tmp:
            _, text = self._run(["--out", tmp])
            lines = text.splitlines()
            self.assertEqual(len(lines), 22)
            self.assertTrue(lines[0].startswith("barong_shirt.png "), lines[0])
            for line in lines:
                match = line_re.match(line)
                self.assertIsNotNone(match, line)
                name, width, height, prefix = match.groups()
                self.assertEqual((int(width), int(height)), CANVAS)
                digest = hashlib.sha256((Path(tmp) / name).read_bytes()).hexdigest()
                self.assertEqual(prefix, digest[:12])

    def test_output_is_identical_across_runs(self):
        with tempfile.TemporaryDirectory() as first_dir, tempfile.TemporaryDirectory() as second_dir:
            _, first = self._run(["--out", first_dir])
            _, second = self._run(["--out", second_dir])
            self.assertEqual(first, second)

    def test_creates_a_missing_output_directory(self):
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "nested" / "textures"
            code, _ = self._run(["--out", str(target)])
            self.assertEqual(code, 0)
            self.assertEqual(len(list(target.glob("*.png"))), 22)

    def test_out_argument_is_required(self):
        err = io.StringIO()
        with contextlib.redirect_stderr(err), self.assertRaises(SystemExit) as ctx:
            self.ot.main([])
        self.assertNotEqual(ctx.exception.code, 0)


class SourceTests(unittest.TestCase):
    def test_module_source_is_ascii_only(self):
        source = MODULE_PATH.read_bytes()
        self.assertTrue(all(byte < 128 for byte in source))

    def test_module_header_cites_the_template_sources(self):
        source = MODULE_PATH.read_text(encoding="ascii")
        self.assertIn("https://create.roblox.com/docs/avatar/classic-clothing", source)
        self.assertIn(
            "https://prod.docsiteassets.roblox.com/assets/accessories/classic-clothing/Template-Shirts-R15.png",
            source,
        )
        self.assertIn(
            "https://prod.docsiteassets.roblox.com/assets/accessories/classic-clothing/Template-Pants-R15.png",
            source,
        )


if __name__ == "__main__":
    unittest.main(verbosity=2)
