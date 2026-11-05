#!/usr/bin/env python3
"""Offline, atomic import of 30 owner-reviewed illustrated faction UI PNGs.

Every picture is an actual generated card crop; no stock/Godot placeholder.
Only accepted GitHub issue attachment ZIPs can invoke this on the owner's repo.
"""
import argparse
import hashlib
import io
import json
import pathlib
import zipfile
from PIL import Image

RACES = ("dwarf", "goblin", "elf")
PARTS = ("runner", "carrier", "saboteur", "spikes", "snare", "turret",
         "defender", "ability", "bank", "raid")
EXPECTED = {f"{race}_{part}.png" for race in RACES for part in PARTS}
OUT = pathlib.Path("assets/ui/direct")
MAX_ARCHIVE = 16 * 1024 * 1024
MAX_DECODED = 48 * 1024 * 1024

def import_pack(raw_zip: bytes) -> list[str]:
    if len(raw_zip) > MAX_ARCHIVE:
        raise ValueError("ZIP archive exceeds 16 MiB")
    with zipfile.ZipFile(io.BytesIO(raw_zip)) as archive:
        entries = {item.filename: item for item in archive.infolist()
                   if not item.is_dir()}
        # Keep the strict whitelist: the previously uploaded 27-file
        # original-HUD archive belongs to a different workflow (issue #9).
        # It is not the race-specific 30-PNG archive for issue #11.
        expected_entries = EXPECTED | {"manifest.json"}
        actual_entries = set(entries)
        if actual_entries != expected_entries:
            missing = sorted(expected_entries - actual_entries)
            unexpected = sorted(actual_entries - expected_entries)
            png_count = sum(name.lower().endswith(".png") for name in actual_entries)
            old_hud_markers = {"title.png", "gold_bar.png", "attack_prep.png", "runner_full.png"}
            if old_hud_markers & actual_entries:
                raise ValueError(
                    f"WRONG ZIP FOR ISSUE #11: uploaded original illustrated HUD "
                    f"({png_count} PNGs), not the three-faction menu pack "
                    f"(30 PNGs). Download vault-wars-three-faction-illustrated-ui.zip "
                    f"from ChatGPT and attach that ZIP in a NEW issue #11 comment. "
                    f"Missing faction files: {missing[:8]}; "
                    f"Unexpected old HUD files: {unexpected[:8]}"
                )
            raise ValueError(
                f"Invalid faction menu ZIP: expected 30 named PNGs and manifest.json; "
                f"found {png_count} PNGs. "
                f"Missing: {missing[:12]}. Unexpected: {unexpected[:12]}. "
                f"Required ZIP: vault-wars-three-faction-illustrated-ui.zip"
            )
        if sum(info.file_size for info in entries.values()) > MAX_DECODED:
            raise ValueError("Uncompressed image data exceeds 48 MiB")
        manifest = json.loads(archive.read("manifest.json"))
        if manifest.get("version") != 2 or manifest.get("format") != "rgba_png":
            raise ValueError("Unsupported menu pack version")
        if set(manifest.get("files", {})) != EXPECTED:
            raise ValueError("Missing or unexpected SHA-256 entries")
        if manifest.get("races") != list(RACES):
            raise ValueError("Unexpected faction list")
        staged = {}
        for filename in sorted(EXPECTED):
            entry = entries[filename]
            if not 1000 <= entry.file_size <= 4_500_000:
                raise ValueError(f"{filename}: unexpected PNG byte length")
            data = archive.read(entry)
            metadata = manifest["files"][filename]
            if hashlib.sha256(data).hexdigest() != metadata.get("sha256"):
                raise ValueError(f"{filename}: SHA-256 mismatch")
            with Image.open(io.BytesIO(data)) as im:
                im.load()
                width, height = im.size
                if im.format != "PNG" or im.mode != "RGBA":
                    raise ValueError(f"{filename}: expected RGBA PNG")
                if [width, height] != metadata.get("size"):
                    raise ValueError(f"{filename}: image dimensions disagree with manifest")
                if not (210 <= width <= 1300 and 75 <= height <= 360):
                    raise ValueError(f"{filename}: invalid card dimensions {im.size}")
                if im.getchannel("A").getbbox() is None:
                    raise ValueError(f"{filename}: fully transparent")
            staged[filename] = data
        OUT.mkdir(parents=True, exist_ok=True)
        for name, bytes_png in staged.items():
            (OUT / name).write_bytes(bytes_png)
            print("IMPORTED", name)
        print(f"All illustrated faction menus verified: {len(staged)} PNGs")
        return sorted(staged)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("archive", type=pathlib.Path)
    args = parser.parse_args()
    import_pack(args.archive.read_bytes())
