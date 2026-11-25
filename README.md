# schiefer-overlay

Gentoo overlay for [Schiefer](https://github.com/ccharon/kde-schiefer-theme), a Motif/CDE look for KDE Plasma 6.
The ebuilds download the release tarball from the kde-schiefer-theme releases.

## Usage

```bash
eselect repository add schiefer-overlay git https://github.com/ccharon/schiefer-overlay.git
emaint sync -r schiefer-overlay
emerge -av x11-themes/schiefer
```

## Packages

| Package | Content |
|---|---|
| `x11-themes/schiefer` | global theme, lock screen, SDDM theme, `schiefer-config`; pulls in the packages below |
| `x11-themes/schiefer-kde` | window decoration and Qt widget style |
| `x11-themes/schiefer-icons` | icons, generated from the installed breeze-icons at build time |
| `x11-themes/schiefer-themes` | color schemes, Plasma style, GTK theme, cursors, window switcher, image wallpaper |
| `x11-themes/schiefer-dock` | dock widgets in the style of the CDE front panel |
| `x11-themes/schiefer-backdrop` | wallpaper plugin with a pattern and color per virtual desktop |
| `x11-themes/schiefer-plymouth` | Plymouth boot screen; pulled in by `x11-themes/schiefer` with USE `plymouth` |

Keywords: `amd64`, `arm64`. Requires Plasma 6.

## License

Ebuilds: GPL-2. See the theme repository for the licenses of the theme itself.
