# Copyright 2026 Schiefer authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

inherit cmake

DESCRIPTION="Schiefer: window decoration and Qt widget style in Motif/CDE style (fork of Breeze)"
SRC_URI="https://github.com/ccharon/kde-schiefer-theme/releases/download/v${PV}/schiefer-${PV}.tar.xz"
HOMEPAGE="https://github.com/ccharon/kde-schiefer-theme"
S="${WORKDIR}/schiefer-${PV}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64 arm64"
RESTRICT="test"

# qtbase:6= and kdecoration:6= trigger rebuilds on ABI changes
DEPEND="
	dev-qt/qtbase:6=[dbus,gui,widgets]
	dev-qt/qtdeclarative:6
	kde-frameworks/frameworkintegration:6
	kde-frameworks/kcolorscheme:6
	kde-frameworks/kconfig:6
	kde-frameworks/kcoreaddons:6
	kde-frameworks/kguiaddons:6
	kde-frameworks/kiconthemes:6
	kde-frameworks/kwindowsystem:6
	kde-plasma/kdecoration:6=
"
RDEPEND="${DEPEND}"
BDEPEND="kde-frameworks/extra-cmake-modules:0"

# Two separate CMake projects (kdecoration, kstyle)
src_prepare() {
	default
	local c
	for c in kdecoration kstyle; do
		CMAKE_USE_DIR="${S}/${c}" BUILD_DIR="${WORKDIR}/build-${c}" cmake_prepare
	done
}

src_configure() {
	local mycmakeargs=( -DKDE_INSTALL_USE_QT_SYS_PATHS=ON -DBUILD_TESTING=OFF )
	CMAKE_USE_DIR="${S}/kdecoration" BUILD_DIR="${WORKDIR}/build-kdecoration" cmake_src_configure
	mycmakeargs+=( -DBUILD_GALLERY=OFF )
	CMAKE_USE_DIR="${S}/kstyle" BUILD_DIR="${WORKDIR}/build-kstyle" cmake_src_configure
}

src_compile() {
	local c
	for c in kdecoration kstyle; do
		BUILD_DIR="${WORKDIR}/build-${c}" cmake_src_compile
	done
}

src_install() {
	local c
	for c in kdecoration kstyle; do
		BUILD_DIR="${WORKDIR}/build-${c}" cmake_src_install
	done
}

pkg_postinst() {
	elog "Window decoration: System Settings > Window Decorations > Schiefer"
	elog "Application style: System Settings > Application Style > Schiefer"
	elog "After a decoration update: log out and back in"
}
