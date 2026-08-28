#!/bin/bash
# eval-routing.sh - Check that a prompt reaches the skill it should
# Usage: ./eval-routing.sh [cases-file]
#
# Routing happens on the description alone: an agent sees name, description and path,
# nothing more. This asks a model to pick from exactly that, so a description change can
# be measured instead of argued about.
#
# Any model will do. Set EVAL_BASE_URL to use an OpenAI-compatible endpoint, which most
# providers and local runtimes speak:
#
#   EVAL_BASE_URL=https://api.openai.com/v1  EVAL_MODEL=gpt-4o-mini      EVAL_API_KEY=...
#   EVAL_BASE_URL=http://localhost:11434/v1  EVAL_MODEL=llama3.1        EVAL_API_KEY=ollama
#   EVAL_BASE_URL=https://openrouter.ai/api/v1  EVAL_MODEL=...          EVAL_API_KEY=...
#
# With no EVAL_BASE_URL it calls Anthropic directly, reading the key from
# ANTHROPIC_API_KEY, or from ANTHROPIC_API_KEY_FILE, or from ~/.config/anthropic/api-key.
# Prefer a file, so the key stays out of shell history and out of any transcript.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
CASES="${1:-$WORKSPACE_DIR/evals/routing.tsv}"

[ ! -f "$CASES" ] && echo "❌ Cases file not found: $CASES" && exit 1

if [ -n "${EVAL_BASE_URL:-}" ]; then
    PROVIDER="openai"
    EVAL_API_KEY="${EVAL_API_KEY:-}"
    if [ -z "${EVAL_MODEL:-}" ]; then
        echo "❌ EVAL_BASE_URL is set, so EVAL_MODEL is needed too. There is no sensible default."
        exit 1
    fi
else
    PROVIDER="anthropic"
    KEY_FILE="${ANTHROPIC_API_KEY_FILE:-$HOME/.config/anthropic/api-key}"
    if [ -z "${ANTHROPIC_API_KEY:-}" ] && [ -r "$KEY_FILE" ]; then
        ANTHROPIC_API_KEY="$(tr -d '\r\n' < "$KEY_FILE")"
    fi
    if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
        echo "❌ No API key. Either set EVAL_BASE_URL for an OpenAI-compatible endpoint,"
        echo "   or set ANTHROPIC_API_KEY, or put the key in $KEY_FILE"
        echo "   mkdir -p ~/.config/anthropic && chmod 700 ~/.config/anthropic"
        echo "   printf %s 'YOUR_KEY' > ~/.config/anthropic/api-key && chmod 600 ~/.config/anthropic/api-key"
        exit 1
    fi
    EVAL_API_KEY="$ANTHROPIC_API_KEY"
    EVAL_MODEL="${EVAL_MODEL:-claude-haiku-4-5-20251001}"
fi
export PROVIDER EVAL_API_KEY EVAL_MODEL EVAL_BASE_URL="${EVAL_BASE_URL:-}"

# skills-ref installs its command as agentskills. Use it if it is on PATH, otherwise run
# it on demand, so nobody has to install anything to run one eval.
if command -v agentskills >/dev/null 2>&1; then
    AGENTSKILLS=(agentskills)
elif command -v uvx >/dev/null 2>&1; then
    AGENTSKILLS=(uvx --from skills-ref agentskills)
elif command -v pipx >/dev/null 2>&1; then
    AGENTSKILLS=(pipx run --spec skills-ref agentskills)
else
    echo "❌ Need the reference validator. Install it with: pip install skills-ref"
    exit 1
fi

# The same block an agent is given.
SKILLS_BLOCK="$("${AGENTSKILLS[@]}" to-prompt "$WORKSPACE_DIR"/skills/*/ 2>/dev/null)"
if [ -z "$SKILLS_BLOCK" ]; then
    echo "❌ Could not build the skills block with: ${AGENTSKILLS[*]}"
    exit 1
fi

SKILL_NAMES="$(basename -a "$WORKSPACE_DIR"/skills/*/ | tr '\n' ' ')"

PASS=0; FAIL=0; AMBIGUOUS=0

while IFS=$'\t' read -r prompt expected; do
    case "$prompt" in ''|'#'*) continue;; esac

    picked="$(SKILLS_BLOCK="$SKILLS_BLOCK" PROMPT="$prompt" SKILL_NAMES="$SKILL_NAMES" python3 - <<'PY'
import json, os, urllib.request

SYSTEM = ("You route a user request to one skill. Reply with the skill name and nothing "
          "else, or NONE if no skill fits. Decide from the descriptions alone.")
user = os.environ["SKILLS_BLOCK"] + "\n\nUser request: " + os.environ["PROMPT"] + "\n\nWhich skill?"

if os.environ["PROVIDER"] == "openai":
    url = os.environ["EVAL_BASE_URL"].rstrip("/") + "/chat/completions"
    payload = {"model": os.environ["EVAL_MODEL"], "max_tokens": 24, "messages": [
        {"role": "system", "content": SYSTEM}, {"role": "user", "content": user}]}
    headers = {"content-type": "application/json",
               "authorization": "Bearer " + os.environ["EVAL_API_KEY"]}
    pick = lambda d: d["choices"][0]["message"]["content"]
else:
    url = "https://api.anthropic.com/v1/messages"
    payload = {"model": os.environ["EVAL_MODEL"], "max_tokens": 24, "system": SYSTEM,
               "messages": [{"role": "user", "content": user}]}
    headers = {"content-type": "application/json",
               "x-api-key": os.environ["EVAL_API_KEY"],
               "anthropic-version": "2023-06-01"}
    pick = lambda d: d["content"][0]["text"]

req = urllib.request.Request(url, data=json.dumps(payload).encode(), headers=headers)
try:
    with urllib.request.urlopen(req, timeout=60) as r:
        text = pick(json.load(r)).strip()
except Exception as e:
    print(f"ERROR:{e}")
else:
    # Asking for a bare name does not guarantee one. An answer may open with prose, so
    # take the first known skill name that appears rather than the first word.
    names = os.environ["SKILL_NAMES"].split()
    hit = min(((text.find(n), n) for n in names if n in text), default=None)
    print(hit[1] if hit else "NONE")
PY
)"

    case "$picked" in
        ERROR:*)
            echo "❌ $picked"
            echo "   Stopping on the first failed call rather than repeating it for every case."
            exit 1
            ;;
    esac

    if [ "$expected" = "AMBIGUOUS" ]; then
        echo "⚠️  $prompt"
        echo "      picked $picked, no agreed answer"
        AMBIGUOUS=$((AMBIGUOUS + 1))
    elif [ "$picked" = "$expected" ]; then
        echo "✓ $prompt"
        PASS=$((PASS + 1))
    else
        echo "✗ $prompt"
        echo "      expected $expected, got $picked"
        FAIL=$((FAIL + 1))
    fi
done < "$CASES"

echo ""
echo "$PASS routed correctly, $FAIL wrong, $AMBIGUOUS undecided  (model: $EVAL_MODEL)"
[ "$FAIL" -eq 0 ] || exit 1
