# Copyright 2026 Schiefer authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

inherit cmake

DESCRIPTION="Schiefer dock: Plasma widgets in the style of the CDE front panel"
SRC_URI="https://github.com/ccharon/kde-schiefer-theme/releases/download/v${PV}/schiefer-${PV}.tar.xz"
HOMEPAGE="https://github.com/ccharon/kde-schiefer-theme"
S="${WORKDIR}/schiefer-${PV}/dock"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64 arm64"
RESTRICT="test"

# libplasma:6= triggers a rebuild when the Plasma ABI changes (the applets link against libplasma)
DEPEND="
	dev-qt/qtbase:6=[dbus,gui]
	dev-qt/qtdeclarative:6
	kde-frameworks/kconfig:6
	kde-frameworks/kcoreaddons:6
	kde-frameworks/ki18n:6
	kde-frameworks/kio:6
	kde-frameworks/kirigami:6
	kde-frameworks/knotifications:6
	kde-frameworks/kservice:6
	kde-plasma/libplasma:6=
"
# runtime: QML modules (Kirigami, KItemModels, KCMUtils, DragAndDrop, TaskManager)
# and the Plasma system tray for the status tiles
RDEPEND="${DEPEND}
	kde-frameworks/kcmutils:6
	kde-frameworks/kdeclarative:6
	kde-frameworks/kitemmodels:6
	kde-plasma/plasma-workspace:6
"
BDEPEND="
	kde-frameworks/extra-cmake-modules:0
	sys-devel/gettext
"

src_configure() {
	local mycmakeargs=( -DKDE_INSTALL_USE_QT_SYS_PATHS=ON -DBUILD_TESTING=OFF )
	cmake_src_configure
}

src_install() {
	cmake_src_install
	# Plasma scripts that build the panels
	insinto /usr/share/schiefer/dock
	doins layout.js add-endcaps.js
}

pkg_postinst() {
	elog "After installing or updating: systemctl --user restart plasma-plasmashell"
	elog
	elog "The global theme Schiefer builds the panels (dock at the bottom, icon box on the left,"
	elog "status tiles at the top right) with \"Desktop and window layout\" checked; the panel"
	elog "template \"Schiefer Front Panel\" is also listed under \"Add Panel\"."
	elog "Or by script. WARNING: removes existing panels at the bottom, left and right!"
	elog "  qdbus6 org.kde.plasmashell /PlasmaShell evaluateScript \"\$(cat ${EPREFIX}/usr/share/schiefer/dock/layout.js)\""
	elog
	elog "Only add the end pieces to an existing dock:"
	elog "  qdbus6 org.kde.plasmashell /PlasmaShell evaluateScript \"\$(cat ${EPREFIX}/usr/share/schiefer/dock/add-endcaps.js)\""
}
