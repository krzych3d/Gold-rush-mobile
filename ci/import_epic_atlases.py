#!/usr/bin/env python3
"""Validate and import the 10 GPT-generated, reviewed fantasy sprite atlases.
Offline installer: no external image API, no Leonardo API or paid generation.
"""
import argparse
import hashlib
import io
import json
import pathlib
import zipfile
from PIL import Image

DEST = pathlib.Path("assets/epic/animations")
HEROES = (
    "shadow_wolf", "goblin_raider", "goblin_saboteur",
    "dwarf_defender", "dwarf_carrier", "elf_ranger", "arcane_mage",
)
SPECIAL = ("goblin_raider", "shadow_wolf", "arcane_mage")
FILES = tuple(f"{name}_sheet.png" for name in HEROES) + tuple(
    f"{name}_special_sheet.png" for name in SPECIAL
)
MAX_ARCHIVE = 30 * 1024 * 1024
MAX_FILE = 5 * 1024 * 1024

def install(data: bytes) -> list[str]:
    if len(data) > MAX_ARCHIVE:
        raise ValueError("ZIP exceeds 30 MiB")
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        members = {entry.filename: entry for entry in archive.infolist()
                   if not entry.is_dir()}
        extras = set(members) - set(FILES) - {"manifest.json"}
        missing = set(FILES) - set(members)
        if missing or extras:
            raise ValueError(f"Invalid ZIP: missing={sorted(missing)} unexpected={sorted(extras)}")
        if sum(members[x].file_size for x in members) > 60 * 1024 * 1024:
            raise ValueError("Uncompressed ZIP is too large")
        manifest = json.loads(archive.read("manifest.json"))
        if manifest.get("grid") != [8, 6] or manifest.get("sheet_size") != [1024, 768]:
            raise ValueError("Invalid manifest atlas layout")
        staged = {}
        for name in FILES:
            info = members[name]
            if not (100_000 <= info.file_size <= MAX_FILE):
                raise ValueError(f"{name}: unexpected PNG size")
            content = archive.read(info)
            expected = manifest["files"][name]["sha256"]
            if hashlib.sha256(content).hexdigest() != expected:
                raise ValueError(f"{name}: SHA256 mismatch")
            with Image.open(io.BytesIO(content)) as image:
                if image.size != (1024, 768) or image.mode != "RGBA":
                    raise ValueError(f"{name}: require 1024x768 RGBA")
                image.load()
                alpha = image.getchannel("A")
                for row in range(6):
                    for col in range(8):
                        tile = alpha.crop((col*128, row*128, (col+1)*128, (row+1)*128))
                        if tile.point(lambda v: 255 if v > 80 else 0).getbbox() is None:
                            raise ValueError(f"{name}: empty frame ({row},{col})")
            staged[name] = content
        # Atomic validation: write nothing until ALL sheets pass.
        DEST.mkdir(parents=True, exist_ok=True)
        for name, content in staged.items():
            (DEST / name).write_bytes(content)
            print(f"Imported {name} ({len(content)} bytes)")
        return sorted(staged)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("archive", type=pathlib.Path)
    args = parser.parse_args()
    for name in install(args.archive.read_bytes()):
        print("READY", name)
