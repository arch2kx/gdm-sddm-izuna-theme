#!/usr/bin/env bash
set -euo pipefail

THEME=gdm-style
SRC="$(cd "$(dirname "$0")" && pwd)"
WALL="${1:-$HOME/Pictures/Current_Pics/Blue_Archive/izuna_dress_wallpaper.png}"
DEST="/usr/share/sddm/themes/$THEME"

sudo mkdir -p "$DEST/assets"
sudo install -m644 "$SRC/Main.qml" "$SRC/Blur.qml" "$SRC/Avatar.qml" "$SRC/Icon.qml" "$SRC/Shadow.qml" "$SRC/theme.conf" "$SRC/metadata.desktop" "$DEST/"
sudo install -Dm644 "$WALL" "$DEST/assets/wallpaper.png"
for f in usericon.png settingsicon.png powericon.png backicon.png; do
    if [ -f "$SRC/assets/$f" ]; then
        sudo install -Dm644 "$SRC/assets/$f" "$DEST/assets/$f"
    fi
done
sudo mkdir -p /etc/sddm.conf.d
printf '[Theme]\nCurrent=%s\n' "$THEME" | sudo tee /etc/sddm.conf.d/10-theme.conf >/dev/null

echo "Installed to $DEST"
