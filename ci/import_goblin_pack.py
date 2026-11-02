#!/usr/bin/env python3
"""Validate and install a sprite-pack ZIP into the Godot project."""
import argparse
import io
import json
import pathlib
import re
import struct
import zipfile

ROOT = pathlib.Path("assets/epic/animations")
FRAMES = {"idle": 8, "walk": 12, "attack": 12, "hit": 8, "carry": 12, "deposit": 12, "death": 16, "run": 12}
MAX_ARCHIVE = 30 * 1024 * 1024
MAX_FILE = 5 * 1024 * 1024
PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"

def install(data: bytes) -> None:
    if len(data) > MAX_ARCHIVE:
        raise ValueError("Archive exceeds 30 MiB")
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        entries = {pathlib.PurePosixPath(info.filename).name: info for info in archive.infolist()
                   if not info.is_dir() and info.filename.lower().endswith(".png")}
        missing = []
        staged = {}
        for action, count in FRAMES.items():
            name = f"goblin_raider_{action}.png"
            if name not in entries:
                if action != "run":
                    missing.append(name)
                continue
            info = entries[name]
            if info.file_size > MAX_FILE:
                raise ValueError(f"{name} exceeds 5 MiB")
            png = archive.read(info)
            if not png.startswith(PNG_SIGNATURE) or len(png) < 33:
                raise ValueError(f"{name}: invalid PNG")
            width, height = struct.unpack(">II", png[16:24])
            if (width, height) != (192 * count, 192):
                raise ValueError(f"{name}: expected {192 * count}x192, got {width}x{height}")
            color_type = png[25]
            if color_type not in (4, 6):
                raise ValueError(f"{name}: expected PNG with alpha (color type 4 or 6)")
            staged[name] = png
        if missing:
            raise ValueError("Missing required sprite strips: " + ", ".join(missing))
        ROOT.mkdir(parents=True, exist_ok=True)
        for name, png in staged.items():
            (ROOT / name).write_bytes(png)
            print(f"Installed {name} ({len(png)} bytes)")
        print(f"Installed {len(staged)} strips")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("archive", type=pathlib.Path)
    args = parser.parse_args()
    install(args.archive.read_bytes())
