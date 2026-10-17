#!/usr/bin/env bash
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
WALL="${1:-}"

mkdir -p "$SRC/assets"
if [ -n "$WALL" ]; then
    cp "$WALL" "$SRC/assets/wallpaper.png"
fi

exec sddm-greeter-qt6 --test-mode --theme "$SRC"
