#!/usr/bin/env python3
"""Strict offline importer for all missing unit animation sheets, including Voidborn.

8 source PNG atlases, each RGBA 1024x768, 8 columns x 6 true frame actions.
Source ZIP must include checksums in its manifest.json.
No Leonardo API or paid generation is invoked.
"""
import argparse
import hashlib
import io
import json
import pathlib
import zipfile
from PIL import Image

ROOT = pathlib.Path("assets/epic/animations")
ALLOWED = (
    "dwarf_defender_special_sheet.png",
    "dwarf_carrier_special_sheet.png",
    "elf_ranger_special_sheet.png",
    "goblin_saboteur_special_sheet.png",
    "void_sentinel_sheet.png",
    "void_stalker_sheet.png",
    "void_collector_sheet.png",
    "void_weaver_sheet.png",
)
MAX_ZIP = 30 * 1024 * 1024
MAX_UNCOMPRESSED = 45 * 1024 * 1024

def install(payload: bytes) -> list[str]:
    if len(payload) > MAX_ZIP:
        raise ValueError("ZIP exceeds 30 MiB")
    with zipfile.ZipFile(io.BytesIO(payload)) as archive:
        contents = {item.filename: item for item in archive.infolist() if not item.is_dir()}
        expected = set(ALLOWED) | {"manifest.json"}
        if set(contents) != expected:
            raise ValueError(f"Expected eight atlases + manifest; missing={expected - set(contents)}, extra={set(contents) - expected}")
        if sum(item.file_size for item in contents.values()) > MAX_UNCOMPRESSED:
            raise ValueError("Decompressed ZIP exceeds 45 MiB")
        manifest = json.loads(archive.read("manifest.json"))
        if manifest.get("pack") != "voidborn-and-missing-specials-v1":
            raise ValueError("Wrong animation pack")
        if manifest.get("grid") != [8, 6] or manifest.get("sheet_size") != [1024, 768]:
            raise ValueError("Expected 1024x768 atlas with 8x6 cells")
        staged = {}
        for name in ALLOWED:
            info = contents[name]
            if not 100_000 <= info.file_size <= 5_000_000:
                raise ValueError(f"{name}: invalid PNG file size")
            data = archive.read(info)
            actual = hashlib.sha256(data).hexdigest()
            if manifest["files"][name]["sha256"] != actual:
                raise ValueError(f"{name}: checksum mismatch")
            with Image.open(io.BytesIO(data)) as image:
                if image.format != "PNG" or image.mode != "RGBA" or image.size != (1024, 768):
                    raise ValueError(f"{name}: must be 1024x768 RGBA PNG")
                image.load()
                alpha = image.getchannel("A")
                if alpha.getpixel((0, 0)) > 32:
                    raise ValueError(f"{name}: visible background at atlas corner")
                for row in range(6):
                    for column in range(8):
                        region = alpha.crop((128*column, 128*row, 128*(column+1), 128*(row+1)))
                        if region.point(lambda value: 255 if value > 70 else 0).getbbox() is None:
                            raise ValueError(f"{name}: empty frame {row},{column}")
            staged[name] = data
        # All-or-nothing validation: no writes before every sheet was validated.
        ROOT.mkdir(parents=True, exist_ok=True)
        for name, data in staged.items():
            (ROOT / name).write_bytes(data)
            print(f"Installed {name}: {len(data)} bytes")
        print(f"SUCCESS: {len(staged)} animated atlases; {len(staged)*48} validated frames")
        return list(staged)

if __name__ == "__main__":
    cli = argparse.ArgumentParser()
    cli.add_argument("archive", type=pathlib.Path)
    args = cli.parse_args()
    install(args.archive.read_bytes())
