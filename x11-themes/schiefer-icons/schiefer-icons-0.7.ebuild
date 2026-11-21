# Copyright 2026 Schiefer authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
inherit multiprocessing python-any-r1 xdg

DESCRIPTION="Schiefer: Breeze icons in muted CDE/Motif colors (SVG), generated from breeze-icons at build time"
SRC_URI="https://github.com/ccharon/kde-schiefer-theme/releases/download/v${PV}/schiefer-${PV}.tar.xz"
HOMEPAGE="https://github.com/ccharon/kde-schiefer-theme"
S="${WORKDIR}/schiefer-${PV}"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="amd64 arm64"
RESTRICT="test"

# The icons are generated from breeze-icons at build time. breeze-icons has the subslot
# 6/<frameworks minor> (frameworks.kde.org.eclass), so ":6=" in RDEPEND rebuilds this package
# with every frameworks minor release. BDEPEND does not allow ":=".
RDEPEND="kde-frameworks/breeze-icons:6="
BDEPEND="
	${PYTHON_DEPS}
	kde-frameworks/breeze-icons:6
	$(python_gen_any_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
	')
"

python_check_deps() {
	python_has_version "dev-python/numpy[${PYTHON_USEDEP}]"
}

src_compile() {
	einfo "Recoloring the icons from /usr/share/icons/breeze ..."
	"${EPYTHON}" make_theme.py --src "${EPREFIX}/usr/share/icons/breeze" \
		--out "${WORKDIR}/icons/schiefer" --name Schiefer -j "$(makeopts_jobs)" || die
	rm -f "${WORKDIR}/icons/schiefer/.schiefer-generated" || die
}

src_install() {
	dodir /usr/share/icons
	# cp -a keeps the symlinks of the theme
	cp -a "${WORKDIR}/icons/schiefer" "${ED}/usr/share/icons/" || die
}

pkg_preinst() {
	# Size directories such as 16@2x are symlinks (16@2x -> 16) as in Breeze. Portage does not replace
	# a directory with a symlink, so remove empty directories left by versions up to 0.3.
	local l rel t
	while IFS= read -r -d '' l; do
		[[ -d ${l} ]] || continue          # directory symlinks only
		rel=${l#"${ED}"}
		t=${EROOT%/}${rel}
		rm -f "${t}".backup.[0-9][0-9][0-9][0-9]
		if [[ -d ${t} && ! -L ${t} ]]; then
			rmdir "${t}" 2>/dev/null || ewarn "Not empty, please remove by hand: ${t}"
		fi
	done < <(find "${ED}/usr/share/icons/schiefer" -type l -print0)
}

pkg_postinst() {
	xdg_pkg_postinst
	elog "The Schiefer icons are a snapshot of breeze-icons."
	elog "Rebuild after kde-frameworks/breeze-icons updates if Portage does not do it:"
	elog "  emerge -1 schiefer-icons"
}
