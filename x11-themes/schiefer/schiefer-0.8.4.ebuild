# Copyright 2026 Schiefer authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
inherit python-single-r1

DESCRIPTION="Schiefer: global theme (splash, logout), lock screen, SDDM login, schiefer-config, meta package"
SRC_URI="https://github.com/ccharon/kde-schiefer-theme/releases/download/v${PV}/schiefer-${PV}.tar.xz"
HOMEPAGE="https://github.com/ccharon/kde-schiefer-theme"
S="${WORKDIR}/schiefer-${PV}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64 arm64"
RESTRICT="test"
IUSE="+backdrop +dock +icons +kde +plymouth +themes"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# schiefer-config calls kreadconfig6/kwriteconfig6, qdbus6 and plasma-apply-*
RDEPEND="
	${PYTHON_DEPS}
	dev-qt/qttools:6[qdbus]
	kde-frameworks/kconfig:6
	kde-plasma/plasma-workspace:6
	backdrop? ( ~x11-themes/schiefer-backdrop-${PV} )
	dock? ( ~x11-themes/schiefer-dock-${PV} )
	icons? ( ~x11-themes/schiefer-icons-${PV} )
	kde? ( ~x11-themes/schiefer-kde-${PV} )
	plymouth? ( ~x11-themes/schiefer-plymouth-${PV} )
	themes? ( ~x11-themes/schiefer-themes-${PV} )
"

src_prepare() {
	default
	# The shared Motif kit is a symlink in the source tree; each package gets a copy
	# because KPackage and SDDM only read inside their own directory.
	local d
	for d in lookandfeel/schiefer.desktop/contents greeter/sddm/schiefer greeter/lockscreen; do
		rm "${d}/kit" || die
		cp -r greeter/kit "${d}/kit" || die
	done
	# line below the host name on the login screen: name of the system
	local os
	os=$(. /etc/os-release 2>/dev/null && echo "${PRETTY_NAME}")
	sed -i "s|^subtitle=.*|subtitle=${os//|/}|" greeter/sddm/schiefer/theme.conf || die
}

src_install() {
	insinto /usr/share/plasma/look-and-feel
	doins -r lookandfeel/schiefer.desktop

	insinto /usr/share/sddm/themes
	doins -r greeter/sddm/schiefer

	insinto /usr/share/schiefer
	doins -r greeter/lockscreen

	insinto /etc/xdg/plasma-workspace/env
	doins greeter/schiefer-lockscreen.sh

	python_doscript tools/schiefer-config
}

pkg_postinst() {
	elog "Everything at once: System Settings > Global Theme > Schiefer"
	elog "(sets colors, Plasma style, icons, application style, window decoration and wallpaper)."
	elog "Select the GTK theme separately: Application Style > GTK Theme > Schiefer"
	elog
	elog "Toggle single Motif features and switch palettes:"
	elog "  schiefer-config list"
	elog "  schiefer-config defaults        (all options to the Schiefer defaults, for example after the global theme)"
	elog "  schiefer-config palette basalt  (palettes: schiefer, broica, sandstein, jade, granit, basalt)"
	elog
	elog "Lock screen (per user):    schiefer-config lockscreen on"
	elog "Login (SDDM, all users):   System Settings > Login Screen (SDDM) > Schiefer"
	elog "  or /etc/sddm.conf.d/...: [Theme] Current=schiefer"
	elog "Palette of login and boot screen: sudo schiefer-config system-palette broica"
}
