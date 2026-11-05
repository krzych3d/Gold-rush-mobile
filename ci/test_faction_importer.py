#!/usr/bin/env python3
"""Regression checks for GitHub issue #11 faction PNG importer.
Creates temporary synthetic assets; does NOT add placeholders to the game.
"""
import hashlib
import io
import json
import tempfile
import unittest
import zipfile
from pathlib import Path

from PIL import Image

from import_faction_illustrations import EXPECTED, import_pack


def create_pack(wrong: bool = False) -> bytes:
    payloads = {}
    if wrong:
        names = ["title.png", "gold_bar.png", "runner.png", "attack_prep.png"]
    else:
        names = sorted(EXPECTED)
    for index, name in enumerate(names):
        image = Image.new("RGBA", (310, 168), (35 + (index % 9) * 14, 38, 121, 255))
        # Ensure all PNGs exceed the minimum expected byte length.
        for x in range(0, 310, 4):
            for y in range(0, 168, 4):
                image.putpixel((x, y), ((x + index * 31) % 255, (y + index * 23) % 255, 149, 255))
        buf = io.BytesIO()
        image.save(buf, format="PNG")
        payloads[name] = buf.getvalue()
    manifest = {
        "version": 2,
        "format": "rgba_png",
        "races": ["dwarf", "goblin", "elf"],
        "files": {},
    }
    for name, data in payloads.items():
        manifest["files"][name] = {
            "sha256": hashlib.sha256(data).hexdigest(),
            "size": [310, 168],
        }
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w", compression=zipfile.ZIP_DEFLATED) as zip_file:
        for name, data in payloads.items():
            zip_file.writestr(name, data)
        zip_file.writestr("manifest.json", json.dumps(manifest))
    return buf.getvalue()


class FactionImportTest(unittest.TestCase):
    def test_correct_thirty_asset_manifest(self):
        import import_faction_illustrations as mod
        with tempfile.TemporaryDirectory() as tmp:
            original = mod.OUT
            mod.OUT = Path(tmp)
            try:
                installed = import_pack(create_pack())
                self.assertEqual(len(installed), 30)
                self.assertEqual(len(list(Path(tmp).glob("*.png"))), 30)
            finally:
                mod.OUT = original

    def test_wrong_legacy_hud_zip_gives_actionable_error(self):
        with self.assertRaisesRegex(ValueError, r"WRONG ZIP FOR ISSUE #11"):
            import_pack(create_pack(wrong=True))

    def test_sha256_mismatch_is_rejected(self):
        archive = create_pack()
        stream = io.BytesIO()
        with zipfile.ZipFile(io.BytesIO(archive)) as src, zipfile.ZipFile(stream, "w", zipfile.ZIP_DEFLATED) as dst:
            for name in src.namelist():
                content = src.read(name)
                if name == "dwarf_runner.png":
                    content = content + b"corruption"
                dst.writestr(name, content)
        with self.assertRaisesRegex(ValueError, r"SHA-256 mismatch"):
            import_pack(stream.getvalue())


if __name__ == "__main__":
    unittest.main()
