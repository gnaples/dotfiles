#!/bin/bash
# Bootstrap on a fresh machine: clone this repo, then run this script.
# Requires GNU Stow (pacman -S stow / brew install stow).
set -euo pipefail

cd "$(dirname "$0")"

PACKAGES=(
  nvim tmux hypr alacritty kitty foot ghostty btop mise
  lazygit lazydocker omarchy starship git mimeapps bash
)

for pkg in "${PACKAGES[@]}"; do
  [ -d "$pkg" ] || continue
  echo "stowing $pkg"
  stow --adopt -v -t "$HOME" "$pkg"
done

echo
echo "Done. Run 'git status' in $(pwd) to check for any local drift"
echo "that --adopt may have pulled in from an existing config on this machine."
