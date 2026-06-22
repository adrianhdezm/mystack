#!/usr/bin/env bash
# release-plugin.sh <plugin> <version>
#
# Bumps the version for a single plugin across all manifests, commits, and tags.
# Supported plugins: product-builder, project-bootstrapper
#
# Examples:
#   ./scripts/release-plugin.sh product-builder 0.2.1
#   ./scripts/release-plugin.sh project-bootstrapper 0.1.1
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

SUPPORTED_PLUGINS=(product-builder project-bootstrapper)

# ── argument validation ───────────────────────────────────────────────────────

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <plugin> <version>" >&2
  echo "Example: $0 product-builder 0.2.1" >&2
  echo "         $0 project-bootstrapper 0.1.1" >&2
  exit 1
fi

PLUGIN=$1
VERSION=$2

# Validate plugin name
valid_plugin=false
for p in "${SUPPORTED_PLUGINS[@]}"; do
  [[ "$p" == "$PLUGIN" ]] && valid_plugin=true && break
done
if [[ "$valid_plugin" == false ]]; then
  echo "Error: unknown plugin '$PLUGIN'" >&2
  echo "Supported: ${SUPPORTED_PLUGINS[*]}" >&2
  exit 1
fi

# Validate semver format
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: invalid version '$VERSION' — expected semver (e.g. 0.2.1)" >&2
  exit 1
fi

# ── pre-flight checks ─────────────────────────────────────────────────────────

EXPECTED_EMAIL="aahdezm@gmail.com"
ACTUAL_EMAIL="$(git config user.email || true)"
if [[ "$ACTUAL_EMAIL" != "$EXPECTED_EMAIL" ]]; then
  echo "Error: git user.email is '$ACTUAL_EMAIL', expected '$EXPECTED_EMAIL'" >&2
  echo "Fix with: git config user.email '$EXPECTED_EMAIL'" >&2
  exit 1
fi

VERSION_FILE="plugins/$PLUGIN/VERSION"
CURRENT=$(cat "$VERSION_FILE")

if [[ "$VERSION" == "$CURRENT" ]]; then
  echo "Error: version '$VERSION' is already the current version" >&2
  exit 1
fi

if [[ "$(printf '%s\n%s' "$CURRENT" "$VERSION" | sort -V | tail -1)" != "$VERSION" ]]; then
  echo "Error: version '$VERSION' is not higher than current '$CURRENT'" >&2
  exit 1
fi

TAG="$PLUGIN-v$VERSION"
if git tag -l "$TAG" | grep -q .; then
  echo "Error: tag '$TAG' already exists" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Error: working tree is not clean — commit or stash changes first" >&2
  exit 1
fi

# ── update files ──────────────────────────────────────────────────────────────

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

echo "$VERSION" > "$VERSION_FILE"

# .codex-plugin/plugin.json
jq --arg v "$VERSION" '.version = $v' \
  "plugins/$PLUGIN/.codex-plugin/plugin.json" > "$tmp"
mv "$tmp" "plugins/$PLUGIN/.codex-plugin/plugin.json"

# .claude-plugin/plugin.json
tmp=$(mktemp)
jq --arg v "$VERSION" '.version = $v' \
  "plugins/$PLUGIN/.claude-plugin/plugin.json" > "$tmp"
mv "$tmp" "plugins/$PLUGIN/.claude-plugin/plugin.json"

# .claude-plugin/marketplace.json
tmp=$(mktemp)
jq --arg name "$PLUGIN" --arg v "$VERSION" \
  '(.plugins[] | select(.name==$name)).version = $v' \
  .claude-plugin/marketplace.json > "$tmp"
mv "$tmp" .claude-plugin/marketplace.json

# ── verify ────────────────────────────────────────────────────────────────────

errors=0
check() {
  local label=$1 actual=$2
  if [[ "$actual" != "$VERSION" ]]; then
    echo "✗ $label: expected $VERSION, got $actual" >&2
    errors=$((errors + 1))
  fi
}

check "VERSION file" "$(cat "$VERSION_FILE")"
check "codex plugin.json" \
  "$(jq -r '.version' "plugins/$PLUGIN/.codex-plugin/plugin.json")"
check "claude plugin.json" \
  "$(jq -r '.version' "plugins/$PLUGIN/.claude-plugin/plugin.json")"
check "marketplace.json" \
  "$(jq -r --arg name "$PLUGIN" '.plugins[] | select(.name==$name) | .version' .claude-plugin/marketplace.json)"

if [[ $errors -gt 0 ]]; then
  echo "$errors file(s) out of sync — aborting" >&2
  exit 1
fi

# ── commit and tag ────────────────────────────────────────────────────────────

git add \
  "$VERSION_FILE" \
  "plugins/$PLUGIN/.codex-plugin/plugin.json" \
  "plugins/$PLUGIN/.claude-plugin/plugin.json" \
  .claude-plugin/marketplace.json

git commit -m "release($PLUGIN): v$VERSION"

git tag "$TAG"

echo "✓ Released $PLUGIN v$VERSION (tag: $TAG)"
