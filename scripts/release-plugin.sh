#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <version>" >&2
  echo "Example: $0 0.1.13" >&2
  exit 1
fi

VERSION=$1

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: invalid version '$VERSION' — expected semver (e.g. 0.1.13)" >&2
  exit 1
fi

CURRENT=$(cat plugins/product-builder/VERSION)
if [[ "$VERSION" == "$CURRENT" ]]; then
  echo "Error: version '$VERSION' is already the current version" >&2
  exit 1
fi
if [[ "$(printf '%s\n%s' "$CURRENT" "$VERSION" | sort -V | tail -1)" != "$VERSION" ]]; then
  echo "Error: version '$VERSION' is not higher than current '$CURRENT'" >&2
  exit 1
fi

if git tag -l "$VERSION" | grep -q .; then
  echo "Error: tag '$VERSION' already exists" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Error: working tree is not clean — commit or stash changes first" >&2
  exit 1
fi

echo "$VERSION" > plugins/product-builder/VERSION

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

jq --arg version "$VERSION" \
  '.version = $version' \
  plugins/product-builder/.codex-plugin/plugin.json \
  > "$tmp"
mv "$tmp" plugins/product-builder/.codex-plugin/plugin.json

tmp=$(mktemp)

jq --arg version "$VERSION" \
  '.version = $version' \
  plugins/product-builder/.claude-plugin/plugin.json \
  > "$tmp"
mv "$tmp" plugins/product-builder/.claude-plugin/plugin.json

tmp=$(mktemp)

jq --arg version "$VERSION" \
  '(.plugins[] | select(.name=="product-builder")).version = $version' \
  .claude-plugin/marketplace.json \
  > "$tmp"
mv "$tmp" .claude-plugin/marketplace.json

errors=0
check() {
  local label=$1 actual=$2
  if [[ "$actual" != "$VERSION" ]]; then
    echo "✗ $label: expected $VERSION, got $actual" >&2
    errors=$((errors + 1))
  fi
}

check "codex plugin.json" \
  "$(jq -r '.version' plugins/product-builder/.codex-plugin/plugin.json)"
check "claude plugin.json" \
  "$(jq -r '.version' plugins/product-builder/.claude-plugin/plugin.json)"
check "marketplace.json" \
  "$(jq -r '.plugins[] | select(.name=="product-builder") | .version' .claude-plugin/marketplace.json)"

if [[ $errors -gt 0 ]]; then
  echo "$errors file(s) out of sync" >&2
  exit 1
fi

git add \
  plugins/product-builder/VERSION \
  plugins/product-builder/.codex-plugin/plugin.json \
  plugins/product-builder/.claude-plugin/plugin.json \
  .claude-plugin/marketplace.json

git commit -m "$(cat <<EOF
release(product-builder): v$VERSION
EOF
)"

git tag "$VERSION"

echo "✓ Committed and tagged $VERSION"
