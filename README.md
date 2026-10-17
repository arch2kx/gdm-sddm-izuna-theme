# gdm-sddm-izuna-theme

A custom SDDM theme styled after GNOME's GDM, written from scratch in plain QML, with a massive clock lock screen and a blurred login screen.

## Features

- Lock screen with a large clock. Click or press any key to unlock.
- Blurred login screen with avatar, password field, session picker and power menu.
- Custom icons, accent colour, font and clock shadow, all set in `theme.conf`.

## Requirements

- SDDM (Qt6)
- `qt6-declarative`
- `adwaita-fonts` (the theme uses Adwaita Sans)

On Arch-based distros:

```
sudo pacman -S sddm qt6-declarative adwaita-fonts
```

## Install

```
git clone https://github.com/arch2kx/gdm-sddm-izuna-theme.git
cd gdm-sddm-izuna-theme
./install.sh /path/to/your/wallpaper.png
```

This copies the theme to `/usr/share/sddm/themes/gdm-style` and sets it as the current theme in `/etc/sddm.conf.d/10-theme.conf`.

## Test without logging out

```
./test.sh /path/to/your/wallpaper.png
```

## Customise

Edit `theme.conf` for the font, accent colour, UI scale, clock shadow and icon sizes. The icons live in `assets/` (`usericon.png`, `settingsicon.png`, `powericon.png`, `backicon.png`). Swap them for your own.

## AI disclosure

Parts of this theme were written with help from Claude (Anthropic).

The design was tweaked by hand to stay close to GDM's look.

## License

GPL-3.0. See `LICENSE`.
