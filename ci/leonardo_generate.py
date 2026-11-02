#!/usr/bin/env python3
"""Leonardo API asset generation. Explicit opt-in only; never auto-publish AI output."""
import argparse, json, os, pathlib, time, urllib.request, urllib.error

BASE = "https://cloud.leonardo.ai/api/rest/v1/generations"
PROMPTS = {
 "idle": "same goblin raider, neutral breathing idle pose",
 "walk": "same goblin raider, twelve distinct walking gait poses, alternating feet",
 "attack": "same goblin raider, complete curved dagger swing from windup to follow-through",
 "hit": "same goblin raider, recoil after being struck",
 "carry": "same goblin raider, running with a heavy gold sack",
 "deposit": "same goblin raider, kneeling and tipping gold coins from sack",
 "death": "same goblin raider, collapsing and lying still"
}
IDENTITY = ("2D high-end fantasy game sprite reference, one consistent green-skinned goblin raider, "
            "long pointed ears, red hood, brown leather armor, curved dagger in right hand, "
            "gold sack on back. Full body, side view facing right, feet visible, "
            "consistent costume and anatomy, isolated simple solid background, no lettering, "
            "no borders, no overlapping figures. ")
def api(url, key, method="GET", payload=None):
    body = None if payload is None else json.dumps(payload).encode()
    request = urllib.request.Request(url, data=body, method=method,
        headers={"Authorization": "Bearer " + key, "Accept": "application/json",
                 "Content-Type": "application/json"})
    with urllib.request.urlopen(request, timeout=45) as response:
        return json.load(response)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--action", choices=list(PROMPTS), default="idle")
    parser.add_argument("--model-id", default="")
    parser.add_argument("--submit", action="store_true")
    args = parser.parse_args()
    out = pathlib.Path("artifacts/leonardo")
    out.mkdir(parents=True, exist_ok=True)
    prompt = IDENTITY + PROMPTS[args.action] + ". Four distinct coherent key poses."
    spec = {"action": args.action, "prompt": prompt, "height": 768, "width": 1024,
            "num_images": 1, "alchemy": False, "public": False}
    if args.model_id:
        spec["modelId"] = args.model_id
    (out / "request-preview.json").write_text(json.dumps(spec, indent=2))
    if not args.submit:
        print("Dry run: request preview created. No API call, no charge.")
        return
    key = os.environ.get("LEONARDO_API_KEY")
    if not key:
        raise SystemExit("LEONARDO_API_KEY GitHub Actions secret is missing")
    if not args.model_id:
        raise SystemExit("Specify model ID from Leonardo Get API Code before paid submission")
    response = api(BASE, key, "POST", spec)
    generation_id = response.get("sdGenerationJob", {}).get("generationId")
    if not generation_id:
        raise SystemExit("Leonardo did not return a generation ID: " + str(response)[:300])
    print("Submitted generation", generation_id)
    (out / "generation-id.txt").write_text(str(generation_id))
    for attempt in range(30):
        time.sleep(8)
        result = api(BASE + "/" + generation_id, key)
        generation = result.get("generations_by_pk") or {}
        status = generation.get("status")
        if status == "COMPLETE":
            images = generation.get("generated_images") or []
            if not images:
                raise SystemExit("Generation completed without images")
            for index, item in enumerate(images):
                url = item.get("url", "")
                if not url.startswith("https://"):
                    raise SystemExit("Unexpected image URL")
                with urllib.request.urlopen(url, timeout=60) as stream:
                    data = stream.read(15 * 1024 * 1024 + 1)
                if len(data) > 15 * 1024 * 1024:
                    raise SystemExit("Image exceeds size limit")
                suffix = ".png" if data.startswith(b"\x89PNG") else ".webp" if data.startswith(b"RIFF") else ".jpg" if data.startswith(b"\xff\xd8") else None
                if not suffix:
                    raise SystemExit("Unsupported image encoding")
                (out / (args.action + "-" + str(index) + suffix)).write_bytes(data)
            print("Downloaded", len(images), "image candidates for human review")
            return
        if status == "FAILED":
            raise SystemExit("Leonardo generation failed")
    raise SystemExit("Timed out waiting for Leonardo; generation ID stored as artifact")

if __name__ == "__main__":
    main()
