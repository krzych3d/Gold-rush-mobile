#!/usr/bin/env python3
"""Import the user's exact generated fantasy UI crops, never generic placeholders.

Safeguards: allowlisted PNG names, manifest SHA-256, RGBA format, size limits,
fully-validated ZIP before writing, no path traversal and no paid APIs.
"""
import argparse
import hashlib
import io
import json
from pathlib import Path
from zipfile import ZipFile

from PIL import Image

FILES = (
    "title", "gold_bar", "phase_bar", "message_bar",
    "lane_blue_1", "lane_blue_2", "lane_blue_3", "lane_gold",
    "runner", "carrier", "saboteur", "spikes", "snare", "turret",
    "runner_full", "carrier_full", "saboteur_full",
    "spikes_full", "snare_full", "turret_full",
    "defender", "ability_void", "bank", "raid",
    "attack_prep", "attack_busy", "attack_again",
)
EXPECTED = {name + ".png" for name in FILES}
OUT = Path("assets/ui/direct")


def import_pack(blob: bytes) -> None:
    if len(blob) > 24 * 1024 * 1024:
        raise ValueError("ZIP exceeds 24 MiB")
    with ZipFile(io.BytesIO(blob)) as package:
        entries = {entry.filename: entry for entry in package.infolist()
                   if not entry.is_dir()}
        if set(entries) != EXPECTED | {"manifest.json"}:
            raise ValueError("ZIP must contain exactly the 27 UI PNGs and manifest")
        if sum(item.file_size for item in entries.values()) > 85 * 1024 * 1024:
            raise ValueError("ZIP expansion limit exceeded")
        manifest = json.loads(package.read("manifest.json"))
        if manifest.get("version") != 1 or manifest.get("format") != "rgba_png":
            raise ValueError("Unknown UI pack format")
        if set(manifest.get("files", {})) != EXPECTED:
            raise ValueError("Incomplete/checksum-less manifest")
        verified = {}
        for name in sorted(EXPECTED):
            entry = entries[name]
            if entry.file_size > 6 * 1024 * 1024 or entry.file_size < 1_000:
                raise ValueError(f"{name}: invalid size")
            raw = package.read(entry)
            digest = hashlib.sha256(raw).hexdigest()
            if digest != manifest["files"][name]["sha256"]:
                raise ValueError(f"{name}: checksum mismatch")
            with Image.open(io.BytesIO(raw)) as image:
                if image.format != "PNG" or image.mode != "RGBA":
                    raise ValueError(f"{name}: expected actual RGBA PNG")
                w, h = image.size
                if not (120 <= w <= 1600 and 50 <= h <= 1100):
                    raise ValueError(f"{name}: invalid asset dimensions")
                if [w, h] != manifest["files"][name]["size"]:
                    raise ValueError(f"{name}: image dimensions do not match manifest")
                image.load()
            verified[name] = raw
        OUT.mkdir(parents=True, exist_ok=True)
        for name, raw in verified.items():
            (OUT / name).write_bytes(raw)
        print(f"IMPORTED {len(verified)} original illustrated PNG HUD elements")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("zip_path", type=Path)
    args = parser.parse_args()
    import_pack(args.zip_path.read_bytes())
