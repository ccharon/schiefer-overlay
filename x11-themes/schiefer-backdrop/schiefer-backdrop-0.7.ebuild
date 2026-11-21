# Copyright 2026 Schiefer authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

inherit cmake

DESCRIPTION="Schiefer Patterns: Plasma wallpaper with a pattern and color per virtual desktop (CDE)"
SRC_URI="https://github.com/ccharon/kde-schiefer-theme/releases/download/v${PV}/schiefer-${PV}.tar.xz"
HOMEPAGE="https://github.com/ccharon/kde-schiefer-theme"
S="${WORKDIR}/schiefer-${PV}/wallpaper/plugin"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64 arm64"
RESTRICT="test"

# QML package with one shader (compiled by qsb at build time); libplasma only for the CMake macros
DEPEND="
	kde-frameworks/ki18n:6
	kde-plasma/libplasma:6
"
RDEPEND="
	dev-qt/qtdeclarative:6
	kde-frameworks/kdeclarative:6
	kde-frameworks/kirigami:6
	kde-plasma/plasma-workspace:6
"
BDEPEND="
	dev-qt/qtshadertools:6
	kde-frameworks/extra-cmake-modules:0
	sys-devel/gettext
"

src_configure() {
	local mycmakeargs=( -DKDE_INSTALL_USE_QT_SYS_PATHS=ON -DBUILD_TESTING=OFF )
	cmake_src_configure
}

pkg_postinst() {
	elog "Select it: right click on the desktop > Desktop and Wallpaper > Wallpaper type \"Schiefer Patterns\","
	elog "or run: schiefer-config pattern-backdrop on"
	elog "After installing or updating: systemctl --user restart plasma-plasmashell"
}
