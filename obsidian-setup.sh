#!/bin/bash
# Bootstrap the Obsidian PKM structure (folders, templates, dashboard,
# core-plugin config) into a vault, on any machine.
#
# What this does vs. what plain `stow` would do, and why they're split:
#   - Templates/, Home.md, and the daily-notes/templates core-plugin config
#     are genuinely portable — stowed as symlinks, same as any other config
#     in this repo. Edit them here, `git push`, `git pull` on another
#     machine, done.
#   - The Systems/ Architecture/ Reference/ Daily/ content folders are NOT
#     stowed: they hold your actual per-vault notes, and symlinking them
#     would mean every vault using this repo shares one folder of live
#     content, which defeats having separate vaults. This script only
#     creates them if missing.
#   - community-plugins.json is NOT stowed either — it reflects whatever
#     plugins you happen to be trying on a given vault, which is exactly
#     the kind of noisy, per-machine state that shouldn't live in a shared
#     config repo. This script only ensures Dataview and Excalidraw are
#     present and enabled, merging into whatever's already there.
#
# Usage: ./setup.sh "/path/to/your/vault"

set -euo pipefail

VAULT="${1:-}"
if [[ -z "$VAULT" ]]; then
  echo "Usage: $0 /path/to/your/vault" >&2
  exit 1
fi
if [[ ! -d "$VAULT/.obsidian" ]]; then
  echo "error: $VAULT doesn't look like an Obsidian vault (no .obsidian/ dir)" >&2
  echo "Open it in Obsidian once first to initialize it, then re-run." >&2
  exit 1
fi

command -v stow >/dev/null 2>&1 || { echo "error: GNU Stow is required (pacman -S stow / brew install stow)" >&2; exit 1; }

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "Linking Templates/, Home.md, and core-plugin config..."
stow --adopt -d "$DOTFILES" -t "$VAULT" obsidian

echo "Creating content folders (only if missing; these hold your real notes, not templated)..."
mkdir -p "$VAULT/Systems" "$VAULT/Architecture/Decisions" "$VAULT/Reference" "$VAULT/Daily"

echo "Ensuring Dataview and Excalidraw plugins are installed and enabled..."
for plugin in dataview obsidian-excalidraw-plugin; do
  case "$plugin" in
    dataview) repo="blacksmithgu/obsidian-dataview" ;;
    obsidian-excalidraw-plugin) repo="zsviczian/obsidian-excalidraw-plugin" ;;
  esac

  plugin_dir="$VAULT/.obsidian/plugins/$plugin"
  if [[ ! -f "$plugin_dir/main.js" ]]; then
    echo "  installing $plugin..."
    mkdir -p "$plugin_dir"
    base="https://github.com/$repo/releases/latest/download"
    curl -sL -o "$plugin_dir/main.js" "$base/main.js"
    curl -sL -o "$plugin_dir/manifest.json" "$base/manifest.json"
    curl -sL -o "$plugin_dir/styles.css" "$base/styles.css" 2>/dev/null || true
  else
    echo "  $plugin already installed"
  fi
done

python3 - "$VAULT/.obsidian/community-plugins.json" <<'PYEOF'
import json, sys
path = sys.argv[1]
try:
    with open(path) as f:
        enabled = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    enabled = []
for plugin in ("dataview", "obsidian-excalidraw-plugin"):
    if plugin not in enabled:
        enabled.append(plugin)
with open(path, "w") as f:
    json.dump(enabled, f, indent=2)
    f.write("\n")
PYEOF

echo
echo "Done. Open (or reload) the vault in Obsidian — Settings > Community plugins"
echo "may still need a one-time confirmation to turn community plugins on."
