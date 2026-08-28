#!/bin/bash
# validate-skills.sh - Validate skills against the Agent Skills specification
# Usage: ./validate-skills.sh [skills-directory]
#
# Spec: https://agentskills.io/specification
# Errors fail the run. Recommendations are reported as warnings only.
#
# This runs alongside skills-ref, the reference validator, which CI treats as the
# authority on the spec itself. Do not delete this script as a duplicate. It covers
# what skills-ref does not: allowed-tools formatting (a spec rule the reference
# implementation accepts violations of), this repo's README.md convention, and the
# line and description length recommendations. It also needs no Python.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

SKILLS_DIR="$(cd "${1:-$WORKSPACE_DIR/skills}" && pwd)"

# Frontmatter fields the spec allows. Anything else is rejected.
ALLOWED_FIELDS="name description license compatibility metadata allowed-tools"

ERRORS=0
WARNINGS=0
CHECKED=0

fail() { echo "❌ $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo "⚠️  $1"; WARNINGS=$((WARNINGS + 1)); }

[ ! -d "$SKILLS_DIR" ] && echo "❌ Skills directory not found: $SKILLS_DIR" && exit 1

# The canonical location is skills/. .claude/skills is a symlink kept for anyone who
# linked or copied the old path. A checkout without symlink support turns it into a text
# file, and the failure is silent, so check that it still resolves to the same place.
COMPAT_LINK="$WORKSPACE_DIR/.claude/skills"
if [ -e "$COMPAT_LINK" ] || [ -L "$COMPAT_LINK" ]; then
    if [ ! -d "$COMPAT_LINK" ]; then
        fail "compatibility path .claude/skills does not resolve to a directory"
    elif [ "$(cd "$COMPAT_LINK" && pwd -P)" != "$(cd "$WORKSPACE_DIR/skills" && pwd -P)" ]; then
        fail "compatibility path .claude/skills resolves somewhere other than skills/"
    fi
fi

# Prints the frontmatter block of $1, without the --- delimiters.
# Requires the closing --- on a line of its own.
frontmatter() {
    awk 'NR==1 && $0!="---" { exit } NR==1 { next } $0=="---" { exit } { print }' "$1"
}

# Prints the value of top-level key $2 in the frontmatter of $1, joining any
# indented continuation lines. Not a YAML parser, the spec keeps this shallow.
field() {
    frontmatter "$1" | awk -v key="$2" '
        $0 ~ "^"key":" { sub("^"key":[ \t]*", ""); print; found=1; next }
        found && /^[ \t]+/ { sub(/^[ \t]+/, " "); printf "%s", $0; next }
        found { exit }
    '
}

# Prints the top-level keys present in the frontmatter of $1.
keys() {
    frontmatter "$1" | grep -oE '^[A-Za-z][A-Za-z0-9_-]*:' | tr -d ':'
}

for dir in "$SKILLS_DIR"/*/; do
    [ -d "$dir" ] || continue
    name="$(basename "$dir")"
    skill="$dir/SKILL.md"
    CHECKED=$((CHECKED + 1))

    if [ ! -f "$skill" ]; then
        fail "$name: missing SKILL.md"
        continue
    fi

    # Repo convention, not part of the spec: every skill documents itself for humans.
    [ -f "$dir/README.md" ] || fail "$name: missing README.md (repo convention)"

    if [ -z "$(frontmatter "$skill")" ]; then
        fail "$name: frontmatter must start on line 1 with --- and close with --- on its own line"
        continue
    fi

    for key in $(keys "$skill"); do
        case " $ALLOWED_FIELDS " in
            *" $key "*) ;;
            *) fail "$name: unknown frontmatter field '$key', put extra data under 'metadata'" ;;
        esac
    done

    fm_name="$(field "$skill" name)"
    if [ -z "$fm_name" ]; then
        fail "$name: 'name' is required"
    else
        [ "$fm_name" = "$name" ] || fail "$name: name '$fm_name' must match the directory name"
        [ "${#fm_name}" -le 64 ] || fail "$name: name is ${#fm_name} characters, max 64"
        echo "$fm_name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$' \
            || fail "$name: name must be lowercase alphanumeric and single hyphens, no leading or trailing hyphen"
    fi

    # An unquoted YAML scalar cannot contain ": ". The reference parser rejects the
    # whole file, and the failure looks like a parse error rather than a typo.
    frontmatter "$skill" | grep -qE '^[A-Za-z][A-Za-z0-9_-]*:[ \t]+[^"'"'"'].*: ' \
        && fail "$name: a frontmatter value contains \": \", which breaks YAML unless quoted"

    desc="$(field "$skill" description)"
    if [ -z "$desc" ]; then
        fail "$name: 'description' is required and must be non-empty"
    else
        [ "${#desc}" -le 1024 ] || fail "$name: description is ${#desc} characters, max 1024"
        [ "${#desc}" -ge 50 ] || warn "$name: description is ${#desc} characters, too short to route on reliably"
    fi

    compat="$(field "$skill" compatibility)"
    [ -z "$compat" ] || [ "${#compat}" -le 500 ] \
        || fail "$name: compatibility is ${#compat} characters, max 500"

    if keys "$skill" | grep -qx "allowed-tools"; then
        # A YAML list is indented under the key, so it has to be caught on the raw
        # frontmatter. field() would join the items and hide it.
        if frontmatter "$skill" | awk '
            /^allowed-tools:/ { seen = 1; next }
            seen && /^[ \t]*-/  { print "list"; exit }
            seen && /^[A-Za-z]/ { exit }
        ' | grep -q list; then
            fail "$name: allowed-tools must be a space-separated string, not a list"
        else
            tools="$(field "$skill" allowed-tools)"
            case "$tools" in
                "")  fail "$name: allowed-tools must be a non-empty space-separated string" ;;
                *,*) fail "$name: allowed-tools must be space-separated, not comma-separated" ;;
            esac
        fi
    fi

    # strictyaml, used by the reference parser, rejects JSON-style flow mappings.
    frontmatter "$skill" | grep -qE '^metadata:[ \t]*\{' \
        && fail "$name: metadata must be a nested block, not inline JSON"

    lines="$(wc -l < "$skill")"
    [ "$lines" -le 500 ] || warn "$name: SKILL.md is $lines lines, the spec recommends under 500"
done

# A skill with no routing case is a skill nobody checks. Worse, a new skill competes
# with every existing one for the same prompts, so adding one without a case can move
# traffic away from another and go unnoticed. This is a plain text check, no API key,
# so it runs on pull requests from forks too.
CASES="$WORKSPACE_DIR/evals/routing.tsv"
if [ -f "$CASES" ]; then
    for dir in "$SKILLS_DIR"/*/; do
        [ -d "$dir" ] || continue
        skill="$(basename "$dir")"
        grep -qE "	$skill\$" "$CASES" \
            || fail "$skill: no case in evals/routing.tsv, add one and rerun eval-routing.sh"
    done
fi

# One version, two files that must agree. plugin.json is the anchor; the changelog's
# top released heading has to match it, so a release cannot half-happen.
MANIFEST="$WORKSPACE_DIR/plugin.json"
CHANGELOG="$WORKSPACE_DIR/CHANGELOG.md"
if [ -f "$MANIFEST" ] && [ -f "$CHANGELOG" ]; then
    manifest_version="$(grep -oE '"version"[ ]*:[ ]*"[^"]+"' "$MANIFEST" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
    changelog_version="$(grep -m1 -oE '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' "$CHANGELOG" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
    if [ "$manifest_version" != "$changelog_version" ]; then
        fail "plugin.json says $manifest_version, CHANGELOG.md says $changelog_version"
    fi
fi

echo ""
echo "Checked $CHECKED skills in $SKILLS_DIR"
echo "$ERRORS error(s), $WARNINGS warning(s)"

[ "$ERRORS" -eq 0 ] || exit 1
echo "✅ All skills conform to the Agent Skills specification"
