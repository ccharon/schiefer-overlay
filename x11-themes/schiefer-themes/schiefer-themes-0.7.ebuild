# Copyright 2026 Schiefer authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
inherit python-any-r1

DESCRIPTION="Schiefer: color schemes, Plasma style, GTK theme, cursors, window switcher and wallpaper in Motif/CDE style"
SRC_URI="https://github.com/ccharon/kde-schiefer-theme/releases/download/v${PV}/schiefer-${PV}.tar.xz"
HOMEPAGE="https://github.com/ccharon/kde-schiefer-theme"
S="${WORKDIR}/schiefer-${PV}"

LICENSE="GPL-2+ LGPL-2+"
SLOT="0"
KEYWORDS="amd64 arm64"
RESTRICT="test"

# The GTK theme imports Breeze GTK and only overrides the drawing
RDEPEND="kde-plasma/breeze-gtk"
BDEPEND="
	${PYTHON_DEPS}
	$(python_gen_any_dep 'dev-python/pillow[${PYTHON_USEDEP}]')
"

python_check_deps() {
	python_has_version "dev-python/pillow[${PYTHON_USEDEP}]"
}

src_compile() {
	"${EPYTHON}" plasma/make_plasma_theme.py "${WORKDIR}/plasma/schiefer" || die
	rm -f "${WORKDIR}/plasma/schiefer/.schiefer-generated" || die
	"${EPYTHON}" wallpaper/make_wallpaper_package.py "${WORKDIR}/wallpaper/Schiefer" || die
	# cursors (pure Python): XCursor 24-96 px + SVG for Wayland; --check verifies the result
	"${EPYTHON}" cursors/make_cursors.py --out "${WORKDIR}/cursors" --check || die
}

src_install() {
	# palettes Schiefer, Sandstein, Jade, Granit, Basalt (switch with: schiefer-config palette <name>)
	insinto /usr/share/color-schemes
	doins colors/*.colors

	insinto /usr/share/plasma/desktoptheme
	doins -r "${WORKDIR}/plasma/schiefer"

	insinto /usr/share/themes
	doins -r gtk/Schiefer

	insinto /usr/share/icons
	doins -r "${WORKDIR}/cursors/Schiefer"

	# window switcher (Alt+Tab) for KWin
	insinto /usr/share/kwin-wayland/tabbox
	doins -r kwin/tabbox/schiefer

	insinto /usr/share/wallpapers
	doins -r "${WORKDIR}/wallpaper/Schiefer"

	# patterns and a script for pixel-exact wallpapers at any resolution
	insinto /usr/share/schiefer/wallpaper
	doins -r wallpaper/tiles
	exeinto /usr/share/schiefer/wallpaper
	doexe wallpaper/apply.sh
	dosym -r /usr/share/schiefer/wallpaper/apply.sh /usr/bin/schiefer-wallpaper
}

pkg_postinst() {
	elog "GTK theme: System Settings > Application Style > GTK Theme > Schiefer"
	elog "Cursors: System Settings > Cursors > Schiefer"
	elog "Window switcher: System Settings > Window Management > Task Switcher > Schiefer"
	elog "Pixel-exact image wallpaper for any resolution: schiefer-wallpaper [pattern]"
	elog "(pattern per virtual desktop: package x11-themes/schiefer-backdrop)"
}
