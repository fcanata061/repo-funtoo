# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="PGI compiler suite"
HOMEPAGE="http://www.pgroup.com/"
SRC_URI="pgilinux-20${PV%%.*}-${PV//./}-x86-64.tar.gz"

LICENSE="PGI"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# ncurses-5 dep is for the debugging binaries that are installed by default.
RDEPEND="net-misc/curl sys-libs/ncurses:5/5"

RESTRICT="mirror fetch strip"
S="${WORKDIR}"

pkg_nofetch() {
	local a
	einfo "Please download these files and move them to your distfiles directory:"
	einfo "Normally /var/cache/portage/distfiles:"
	einfo
	for a in ${A} ; do
		[[ ! -f ${DISTDIR}/${a} ]] && einfo "  ${a}"
	done
	einfo
	einfo "https://www.pgroup.com/support/download_community.php?file=pgi-community-linux-x64"
}

QA_PREBUILT="*"
QA_TEXTRELS="*"

src_install() {
	dodir /opt/${PN}
	export PGI_SILENT=true
	export PGI_ACCEPT_EULA=accept
	export PGI_INSTALL_DIR="${ED}/opt/${PN}"
	export PGI_INSTALL_TYPE=single
	export PGI_INSTALL_NVIDIA=true
	export PGI_INSTALL_JAVA=true
	export PGI_INSTALL_MPI=true
	export PGI_MPI_GPU_SUPPORT=true
	bash ./install
	
	rm -f ${D}/opt/pgi/libnuma.so #remove broken symlink
	
	doenvd "${FILESDIR}"/99pgi
}

pkg_postinst() {
	elog "You need to run env-update and source /etc/profile in any open shells"
	elog "for the PGI compiler binaries to be available"
}
