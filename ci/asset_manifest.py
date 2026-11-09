#!/usr/bin/env python3
"""Verify shipping art bytes and record a safe, binary-free upload plan."""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import subprocess

ROOT = Path(__file__).resolve().parents[1]
SUFFIXES = {".png", ".jpg", ".jpeg", ".svg", ".webp", ".ogg", ".wav", ".ttf", ".otf"}


def describe(path):
    data = path.read_bytes()
    result = {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest(),
              "git_blob_sha1": hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()}
    if path.suffix.lower() == ".png":
        if len(data) < 33 or data[:16] != b"\x89PNG\r\n\x1a\n\0\0\0\rIHDR":
            raise ValueError("Invalid PNG: " + str(path))
        result["size"] = list(struct.unpack(">II", data[16:24]))
        if not all(1 <= side <= 8192 for side in result["size"]):
            raise ValueError("Image exceeds the texture budget: " + str(path))
    return result


def inventory():
    result = {}
    for path in sorted((ROOT / "assets").rglob("*")):
        if path.suffix.lower() not in SUFFIXES:
            continue
        if path.is_symlink() or not path.is_file():
            raise ValueError("Asset must be a regular file")
        result[path.relative_to(ROOT).as_posix()] = describe(path)
    return {"version": 1, "assets": result}


def check():
    actual = inventory()
    if actual != json.loads((ROOT / "assets/manifest.json").read_text()):
        raise ValueError("Shipping artwork differs from its recorded inventory")
    provenance = json.loads((ROOT / "art_sources/cinematic-lobby.json").read_text())
    for item in provenance["assets"]:
        if actual["assets"][item["path"]]["sha256"] != item["sha256"]:
            raise ValueError("Generated lobby source differs from installed art")
    print("Asset inventory verified:", len(actual["assets"]), "files; cinematic art hashes match")


def plan():
    tracked = subprocess.check_output(["git", "diff", "--name-only", "-z", "HEAD"], cwd=ROOT).decode().split("\0")
    added = subprocess.check_output(["git", "ls-files", "--others", "--exclude-standard", "-z"], cwd=ROOT).decode().split("\0")
    result = []
    for filename in sorted(set(tracked + added) - {""}):
        path = ROOT / filename
        if not path.is_file():
            raise ValueError("Deletion is not supported by the asset upload plan")
        result.append({"path": filename, "mode": "100644", "type": "blob", **describe(path),
                       "encoding": "base64" if path.suffix.lower() in {".png", ".jpg", ".jpeg", ".webp", ".ogg", ".wav", ".ttf", ".otf"} else "utf-8"})
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--write", action="store_true")
    group.add_argument("--check", action="store_true")
    group.add_argument("--plan", action="store_true")
    args = parser.parse_args()
    if args.write:
        (ROOT / "assets/manifest.json").write_text(json.dumps(inventory(), indent=2, sort_keys=True) + "\n")
    elif args.check:
        check()
    else:
        print(json.dumps(plan(), indent=2))
