#!/usr/bin/env bash
set -euo pipefail

THEME=gdm-style
SRC="$(cd "$(dirname "$0")" && pwd)"
WALL="${1:-$SRC/assets/wallpaper.png}"
DEST="/usr/share/sddm/themes/$THEME"

sudo mkdir -p "$DEST/assets"
sudo install -m644 "$SRC/Main.qml" "$SRC/Blur.qml" "$SRC/Avatar.qml" "$SRC/Icon.qml" "$SRC/Shadow.qml" "$SRC/theme.conf" "$SRC/metadata.desktop" "$DEST/"
if [ -f "$WALL" ]; then
    sudo install -Dm644 "$WALL" "$DEST/assets/wallpaper.png"
fi
for f in usericon.png settingsicon.png powericon.png backicon.png; do
    if [ -f "$SRC/assets/$f" ]; then
        sudo install -Dm644 "$SRC/assets/$f" "$DEST/assets/$f"
    fi
done
sudo mkdir -p /etc/sddm.conf.d
printf '[Theme]\nCurrent=%s\n' "$THEME" | sudo tee /etc/sddm.conf.d/10-theme.conf >/dev/null

MAIN_CONF=/etc/sddm.conf
if [ -f "$MAIN_CONF" ] && sudo sed -n '/^\[Theme\]/,/^\[/p' "$MAIN_CONF" | grep -q '^Current='; then
    sudo cp -n "$MAIN_CONF" "$MAIN_CONF.bak"
    sudo sed -i "/^\[Theme\]/,/^\[/ s|^Current=.*|Current=$THEME|" "$MAIN_CONF"
    echo "Updated [Theme] in $MAIN_CONF (backup: $MAIN_CONF.bak)"
fi

echo "Installed to $DEST"
