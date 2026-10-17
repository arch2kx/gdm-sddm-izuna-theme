#!/usr/bin/env bash
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
WALL="${1:-$HOME/Pictures/Current_Pics/Blue_Archive/izuna_dress_wallpaper.png}"

mkdir -p "$SRC/assets"
cp "$WALL" "$SRC/assets/wallpaper.png"

exec sddm-greeter-qt6 --test-mode --theme "$SRC"
