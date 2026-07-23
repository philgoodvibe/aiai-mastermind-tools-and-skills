#!/usr/bin/env python3
"""Generate comparison images with the configured identity references.

Examples:
  python3 scripts/generate.py --scene "studio-portrait=Photoreal studio portrait in soft window light" --provider both
  python3 scripts/generate.py --scenes-file scenes.txt --out output/comparison
"""

import argparse
import base64
import concurrent.futures
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import threading
import time
import urllib.error
import urllib.request


PRINT_LOCK = threading.Lock()
SLOT_ORDER = (
    "02-upper-body",
    "01-primary-face",
    "03-proportions",
    "04-expression-open-smile",
    "05-secondary-face",
)
ALLOWED_IMAGE_SUFFIXES = {".jpeg", ".png"}


def eprint(message):
    print(message, file=sys.stderr, flush=True)


def discover_identity_photos(skill_root):
    identity_dir = skill_root / "assets" / "identity-default"
    photos = []
    for slot in SLOT_ORDER:
        matches = sorted(
            path
            for path in identity_dir.glob(slot + ".*")
            if path.is_file() and path.suffix.lower() in ALLOWED_IMAGE_SUFFIXES
        )
        if matches:
            photos.append(matches[0])
        if len(photos) == 5:
            break
    return photos


def reusable_prompt_block(skill_root):
    profile_path = skill_root / "references" / "identity-profile.md"
    if not profile_path.is_file():
        eprint(
            "WARNING: references/identity-profile.md is missing. "
            "Continuing without a reusable identity prompt block."
        )
        return ""

    text = profile_path.read_text(encoding="utf-8")
    if "{{" in text:
        eprint(
            "WARNING: references/identity-profile.md still contains {{ placeholders. "
            "The skill is not fully customized, but this test will continue."
        )

    lines = text.splitlines()
    start = None
    for index, line in enumerate(lines):
        if re.match(r"^#{1,6}\s+.*reusable prompt block", line, re.IGNORECASE):
            start = index + 1
            break
    if start is None:
        eprint(
            "WARNING: No heading containing 'Reusable prompt block' was found in "
            "references/identity-profile.md. Continuing without it."
        )
        return ""

    block_lines = []
    for line in lines[start:]:
        if re.match(r"^#{1,6}\s+", line):
            break
        block_lines.append(re.sub(r"^\s*>\s?", "", line))
    return "\n".join(block_lines).strip()


def parse_scene(value, source):
    if "=" not in value:
        raise ValueError(f"{source} must use slug=description: {value!r}")
    slug, description = value.split("=", 1)
    slug = slug.strip()
    description = description.strip()
    if not slug or not description:
        raise ValueError(f"{source} has an empty slug or description: {value!r}")
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]*", slug):
        raise ValueError(
            f"Invalid scene slug {slug!r}. Use letters, numbers, dots, underscores, or hyphens."
        )
    return slug, description


def collect_scenes(args):
    scenes = []
    for value in args.scene:
        scenes.append(parse_scene(value, "--scene"))

    if args.scenes_file:
        scenes_path = Path(args.scenes_file).expanduser()
        try:
            lines = scenes_path.read_text(encoding="utf-8").splitlines()
        except OSError as exc:
            raise ValueError(f"Could not read scenes file {scenes_path}: {exc}") from exc
        for line_number, line in enumerate(lines, 1):
            stripped = line.strip()
            if not stripped or stripped.startswith("#"):
                continue
            scenes.append(parse_scene(stripped, f"{scenes_path}:{line_number}"))

    if args.description:
        description = " ".join(args.description).strip()
        if not description:
            raise ValueError("The positional scene description is empty.")
        scenes.append(("scene-01", description))

    if not scenes:
        raise ValueError(
            "Provide at least one scene with --scene, --scenes-file, or a positional description."
        )

    seen = set()
    for slug, _ in scenes:
        if slug in seen:
            raise ValueError(f"Duplicate scene slug: {slug}")
        seen.add(slug)
    return scenes


def combined_prompt(description, prompt_block):
    if not prompt_block:
        return description
    return description.rstrip() + "\n\nReusable identity instructions:\n" + prompt_block


def normalized_extension(value, default):
    extension = str(value or default).lower().lstrip(".")
    aliases = {"jpeg": "jpg", "jpg": "jpg", "png": "png", "webp": "webp"}
    return aliases.get(extension, default)


def error_message(payload):
    error = payload.get("error") if isinstance(payload, dict) else None
    if isinstance(error, dict):
        return str(error.get("message") or error)
    if error:
        return str(error)
    return ""


def generate_openai(base_url, key, prompt, photos, out_dir, slug):
    url = base_url + "/v1/images/edits"
    command = [
        "curl",
        "-sS",
        "-m",
        "300",
        "-X",
        "POST",
        url,
        "-H",
        f"Authorization: Bearer {key}",
        "-F",
        "model=gpt-image-2",
        "-F",
        f"prompt={prompt}",
    ]
    for photo in photos:
        command.extend(["-F", f"image[]=@{photo}"])

    completed = subprocess.run(
        command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=310, check=False
    )
    if completed.returncode != 0:
        detail = completed.stderr.decode("utf-8", errors="replace").strip()
        raise RuntimeError(detail or f"curl exited with status {completed.returncode}")
    try:
        payload = json.loads(completed.stdout.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"OpenAI router response was not valid JSON: {exc}") from exc
    message = error_message(payload)
    if message:
        raise RuntimeError(message)
    try:
        item = payload["data"][0]
        image_bytes = base64.b64decode(item["b64_json"], validate=True)
    except (KeyError, IndexError, TypeError, ValueError) as exc:
        raise RuntimeError("OpenAI response did not contain a valid data[0].b64_json image") from exc
    extension = normalized_extension(
        item.get("output_format") or payload.get("output_format"), "png"
    )
    destination = out_dir / f"{slug}--openai-gpt-image-2.{extension}"
    destination.write_bytes(image_bytes)
    return destination, len(image_bytes)


def generate_google(base_url, key, prompt, photos, out_dir, slug):
    url = base_url + "/v1beta/models/gemini-3.1-flash-image:generateContent"
    parts = [{"text": "Generate an image. " + prompt}]
    for photo in photos:
        encoded = base64.b64encode(photo.read_bytes()).decode("ascii")
        parts.append({"inlineData": {"mimeType": "image/jpeg", "data": encoded}})
    body = json.dumps({"contents": [{"role": "user", "parts": parts}]}).encode("utf-8")
    request = urllib.request.Request(
        url,
        data=body,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {key}",
            "x-goog-api-key": key,
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=300) as response:
            response_bytes = response.read()
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace").strip()
        raise RuntimeError(f"Google router HTTP {exc.code}: {detail or exc.reason}") from exc
    except urllib.error.URLError as exc:
        raise RuntimeError(f"Google router request failed: {exc.reason}") from exc
    try:
        payload = json.loads(response_bytes.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"Google router response was not valid JSON: {exc}") from exc
    message = error_message(payload)
    if message:
        raise RuntimeError(message)

    for candidate in payload.get("candidates", []):
        for part in candidate.get("content", {}).get("parts", []):
            inline_data = part.get("inlineData")
            if isinstance(inline_data, dict) and inline_data.get("data"):
                try:
                    image_bytes = base64.b64decode(inline_data["data"], validate=True)
                except (TypeError, ValueError) as exc:
                    raise RuntimeError("Google response contained invalid base64 image data") from exc
                mime_type = inline_data.get("mimeType", "image/jpeg")
                mime_extensions = {
                    "image/jpeg": "jpg",
                    "image/jpg": "jpg",
                    "image/png": "png",
                    "image/webp": "webp",
                }
                extension = mime_extensions.get(str(mime_type).lower(), "jpg")
                destination = out_dir / f"{slug}--google-gemini-3.1-flash-image.{extension}"
                destination.write_bytes(image_bytes)
                return destination, len(image_bytes)
    raise RuntimeError("Google response did not contain image data in candidates content parts")


def run_with_retry(provider, slug, prompt, photos, out_dir, base_url, key):
    started = time.monotonic()
    last_error = ""
    for attempt in (1, 2):
        attempt_started = time.monotonic()
        try:
            if provider == "openai":
                destination, byte_count = generate_openai(
                    base_url, key, prompt, photos, out_dir, slug
                )
            else:
                destination, byte_count = generate_google(
                    base_url, key, prompt, photos, out_dir, slug
                )
            attempt_seconds = time.monotonic() - attempt_started
            with PRINT_LOCK:
                print(
                    f"OK {provider} {slug}, attempt {attempt}/2, "
                    f"{byte_count} bytes in {attempt_seconds:.1f}s, {destination}",
                    flush=True,
                )
            return {
                "provider": provider,
                "slug": slug,
                "ok": True,
                "file": str(destination),
                "bytes": byte_count,
                "seconds": round(time.monotonic() - started, 3),
                "attempts": attempt,
            }
        except Exception as exc:
            last_error = str(exc) or exc.__class__.__name__
            attempt_seconds = time.monotonic() - attempt_started
            with PRINT_LOCK:
                print(
                    f"FAIL {provider} {slug}, attempt {attempt}/2, "
                    f"{attempt_seconds:.1f}s, {last_error}",
                    file=sys.stderr,
                    flush=True,
                )
    return {
        "provider": provider,
        "slug": slug,
        "ok": False,
        "file": "",
        "bytes": 0,
        "seconds": round(time.monotonic() - started, 3),
        "attempts": 2,
        "error": last_error,
    }


def build_parser():
    parser = argparse.ArgumentParser(
        description="Generate each scene concurrently with OpenAI, Google, or both."
    )
    parser.add_argument(
        "description",
        nargs="*",
        help="Bare scene description. It receives the slug scene-01.",
    )
    parser.add_argument(
        "--scene",
        action="append",
        default=[],
        metavar="SLUG=DESCRIPTION",
        help="Add a scene. Repeat this option for multiple scenes.",
    )
    parser.add_argument(
        "--scenes-file",
        help="Read one slug=description scene per line. Blank lines and comments are ignored.",
    )
    parser.add_argument(
        "--provider",
        choices=("openai", "google", "both"),
        default="both",
        help="Provider selection. Default: both.",
    )
    parser.add_argument(
        "--out",
        help="Output directory. Default: output inside the skill root.",
    )
    return parser


def main():
    args = build_parser().parse_args()
    key = os.environ.get("MODEL_ROUTER_KEY", "").strip()
    if not key:
        eprint(
            "ERROR: MODEL_ROUTER_KEY is not set. Set the router key in the environment, "
            "then run this command again."
        )
        return 1

    script_dir = Path(__file__).resolve().parent
    skill_root = script_dir.parent
    base_url = os.environ.get("MODEL_ROUTER_URL", "http://127.0.0.1:8317").rstrip("/")
    if not base_url:
        eprint("ERROR: MODEL_ROUTER_URL resolves to an empty base URL.")
        return 1

    photos = discover_identity_photos(skill_root)
    if len(photos) < 2:
        eprint(
            "ERROR: The skill is not customized yet. Add at least two slot photos to "
            "assets/identity-default/ before generating."
        )
        return 1

    try:
        scenes = collect_scenes(args)
    except ValueError as exc:
        eprint(f"ERROR: {exc}")
        return 1

    prompt_block = reusable_prompt_block(skill_root)
    out_dir = Path(args.out).expanduser() if args.out else skill_root / "output"
    try:
        out_dir.mkdir(parents=True, exist_ok=True)
    except OSError as exc:
        eprint(f"ERROR: Could not create output directory {out_dir}: {exc}")
        return 1

    providers = ("openai", "google") if args.provider == "both" else (args.provider,)
    jobs = []
    for slug, description in scenes:
        prompt = combined_prompt(description, prompt_block)
        for provider in providers:
            jobs.append((provider, slug, prompt))

    results = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
        future_map = {
            executor.submit(
                run_with_retry,
                provider,
                slug,
                prompt,
                photos,
                out_dir,
                base_url,
                key,
            ): (provider, slug)
            for provider, slug, prompt in jobs
        }
        for future in concurrent.futures.as_completed(future_map):
            provider, slug = future_map[future]
            try:
                results.append(future.result())
            except Exception as exc:
                results.append(
                    {
                        "provider": provider,
                        "slug": slug,
                        "ok": False,
                        "file": "",
                        "bytes": 0,
                        "seconds": 0.0,
                        "attempts": 2,
                        "error": f"Unexpected worker failure: {exc}",
                    }
                )

    results_path = out_dir / "results.json"
    results_path.write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {results_path}", flush=True)
    return 0 if any(result["ok"] for result in results) else 1


if __name__ == "__main__":
    sys.exit(main())
