#!/bin/sh

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SKILL_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
BASE=${MODEL_ROUTER_URL:-http://127.0.0.1:8317}
BASE=${BASE%/}
MODELS_FILE=${TMPDIR:-/tmp}/generate-me-models-$$.json
trap 'rm -f "$MODELS_FILE"' EXIT HUP INT TERM

python_ok=0
curl_ok=0
key_ok=0
router_ok=0
openai_model_ok=0
google_model_ok=0
codex_ok=0
codex_login_ok=0

if command -v python3 >/dev/null 2>&1; then
    python_version=$(python3 --version 2>&1)
    echo "OK: python3 present, $python_version"
    python_ok=1
else
    echo "MISSING: python3 is not installed or not on PATH"
fi

if command -v curl >/dev/null 2>&1; then
    echo "OK: curl present"
    curl_ok=1
else
    echo "MISSING: curl is not installed or not on PATH"
fi

if [ -n "${MODEL_ROUTER_URL:-}" ]; then
    echo "OK: MODEL_ROUTER_URL is set"
else
    echo "MISSING: MODEL_ROUTER_URL is not set, the default $BASE will be checked"
fi

if [ -n "${MODEL_ROUTER_KEY:-}" ]; then
    echo "OK: MODEL_ROUTER_KEY is set"
    key_ok=1
else
    echo "MISSING: MODEL_ROUTER_KEY is not set"
fi

if [ "$curl_ok" -eq 0 ]; then
    echo "SKIP: router reachability check requires curl"
elif [ "$key_ok" -eq 0 ]; then
    echo "SKIP: router reachability check requires MODEL_ROUTER_KEY"
else
    http_code=$(curl -sS -m 15 -o "$MODELS_FILE" -w '%{http_code}' \
        -H "Authorization: Bearer $MODEL_ROUTER_KEY" "$BASE/v1/models" 2>/dev/null || printf '000')
    case "$http_code" in
        2??)
            echo "OK: router reachable at $BASE/v1/models"
            router_ok=1
            ;;
        *)
            echo "MISSING: router not reachable at $BASE/v1/models, HTTP $http_code"
            ;;
    esac
fi

if [ "$router_ok" -eq 1 ]; then
    if grep -qi 'gpt-image-2' "$MODELS_FILE"; then
        echo "OK: router lists image model gpt-image-2"
        openai_model_ok=1
    else
        echo "MISSING: router does not list image model gpt-image-2"
    fi
    if grep -qi 'gemini-3.1-flash-image' "$MODELS_FILE"; then
        echo "OK: router lists image model gemini-3.1-flash-image"
        google_model_ok=1
    else
        echo "MISSING: router does not list image model gemini-3.1-flash-image"
    fi
else
    echo "SKIP: gpt-image-2 model check requires a reachable router"
    echo "SKIP: gemini-3.1-flash-image model check requires a reachable router"
fi

if command -v codex >/dev/null 2>&1; then
    echo "OK: Codex CLI present"
    codex_ok=1
    if codex login status >/dev/null 2>&1; then
        echo "OK: Codex CLI reports a login"
        codex_login_ok=1
    else
        echo "MISSING: Codex CLI does not report a login"
    fi
else
    echo "MISSING: Codex CLI is not installed or not on PATH"
    echo "SKIP: Codex login check requires the Codex CLI"
fi

IDENTITY_DIR="$SKILL_ROOT/assets/identity-default"
if [ -d "$IDENTITY_DIR" ]; then
    photo_count=$(find "$IDENTITY_DIR" -type f \( -iname '*.jpeg' -o -iname '*.png' \) -print | awk 'END {print NR + 0}')
else
    photo_count=0
fi
if [ "$photo_count" -ge 2 ]; then
    echo "OK: identity-default contains $photo_count photos, at least two are present"
    photos_ok=1
else
    echo "MISSING: identity-default contains $photo_count photos, at least two are required"
    photos_ok=0
fi

PROFILE="$SKILL_ROOT/references/identity-profile.md"
if [ -f "$PROFILE" ]; then
    echo "OK: references/identity-profile.md exists"
    placeholder_count=$(awk '{line=$0; while (match(line, /\{\{/)) {count++; line=substr(line, RSTART + RLENGTH)}} END {print count + 0}' "$PROFILE")
    if [ "$placeholder_count" -eq 0 ]; then
        echo "OK: identity profile has 0 unfilled placeholders"
        profile_ok=1
    else
        echo "MISSING: identity profile has $placeholder_count unfilled placeholders"
        profile_ok=0
    fi
else
    echo "MISSING: references/identity-profile.md does not exist"
    echo "MISSING: identity profile placeholder count is unavailable"
    placeholder_count=0
    profile_ok=0
fi

router_openai=0
router_google=0
builtin_codex=0
[ "$python_ok" -eq 1 ] && [ "$curl_ok" -eq 1 ] && [ "$key_ok" -eq 1 ] && [ "$router_ok" -eq 1 ] && [ "$openai_model_ok" -eq 1 ] && router_openai=1
[ "$python_ok" -eq 1 ] && [ "$key_ok" -eq 1 ] && [ "$router_ok" -eq 1 ] && [ "$google_model_ok" -eq 1 ] && router_google=1
[ "$codex_ok" -eq 1 ] && [ "$codex_login_ok" -eq 1 ] && builtin_codex=1

if [ "$photos_ok" -eq 1 ] && [ "$profile_ok" -eq 1 ]; then
    customization="CUSTOMIZED"
else
    customization="NOT YET CUSTOMIZED"
fi

echo ""
echo "SUMMARY"
if [ "$router_openai" -eq 1 ]; then echo "OK: router OpenAI path available"; else echo "MISSING: router OpenAI path unavailable"; fi
if [ "$router_google" -eq 1 ]; then echo "OK: router Google path available"; else echo "MISSING: router Google path unavailable"; fi
if [ "$builtin_codex" -eq 1 ]; then echo "OK: built-in Codex path available"; else echo "MISSING: built-in Codex path unavailable"; fi
echo "Skill status: $customization"

if [ "$router_openai" -eq 0 ] && [ "$router_google" -eq 0 ] && [ "$builtin_codex" -eq 0 ]; then
    exit 1
fi
exit 0
