# Copyright 2026 Schiefer authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

DESCRIPTION="Schiefer boot screen: Plymouth theme in the style of a workstation console"
SRC_URI="https://github.com/ccharon/kde-schiefer-theme/releases/download/v${PV}/schiefer-${PV}.tar.xz"
HOMEPAGE="https://github.com/ccharon/kde-schiefer-theme"
S="${WORKDIR}/schiefer-${PV}/plymouth"

LICENSE="GPL-2+ OFL-1.1"
SLOT="0"
KEYWORDS="amd64 arm64"
RESTRICT="test"

# the images are generated in the source tree (make_plymouth.py), nothing to build
RDEPEND="sys-boot/plymouth"

src_install() {
	insinto /usr/share/plymouth/themes/schiefer
	doins schiefer/schiefer.plymouth schiefer/schiefer.script.in
	# image sets of all palettes; schiefer-plymouth-info copies the one of the system palette
	# to /var/lib/schiefer/plymouth/images, so the initramfs only gets that one
	insinto /usr/share/schiefer/plymouth
	doins -r palettes/.

	exeinto /usr/libexec/schiefer
	doexe schiefer-plymouth-info

	exeinto /usr/lib/dracut/modules.d/90schiefer-plymouth
	doexe dracut/90schiefer-plymouth/module-setup.sh

	keepdir /var/lib/schiefer/plymouth
}

pkg_postinst() {
	# the script with the machine details and the images of the system palette; dracut rewrites
	# both for every initramfs
	"${EROOT}"/usr/libexec/schiefer/schiefer-plymouth-info \
		--template "${EROOT}"/usr/share/plymouth/themes/schiefer/schiefer.script.in \
		--palettes "${EROOT}"/usr/share/schiefer/plymouth \
		--out "${EROOT}"/var/lib/schiefer/plymouth/schiefer.script \
		|| ewarn "could not write ${EROOT}/var/lib/schiefer/plymouth/schiefer.script"

	elog "Activate the boot screen (rebuilds the initramfs of the running kernel with dracut):"
	elog "  plymouth-set-default-theme -R schiefer"
	elog "The kernel command line needs \"splash\" (and usually \"quiet\")."
	elog "Back to a previous theme, for example: plymouth-set-default-theme -R bgrt"
	elog "Colors: the system palette (schiefer-config system-palette), after the next initramfs build"
}

pkg_postrm() {
	[[ -z ${REPLACED_BY_VERSION} ]] && rm -rf "${EROOT}"/var/lib/schiefer/plymouth/{schiefer.script,images}
}
