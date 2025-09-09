# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Fortran 90 Makefile dependency tool"
HOMEPAGE="https://github.com/amckinstry/makedepf90"
SRC_URI="https://github.com/amckinstry/makedepf90/archive/upstream/${P}.tar.gz -> ${P}.tar.gz"

KEYWORDS="*"
SLOT="0"
LICENSE="GPL-2"
IUSE=""

DEPEND="sys-devel/bison	sys-devel/flex"

DOCS=( COPYING NEWS README )

S="${WORKDIR}"/${PN}-upstream

src_install() {
	dobin ${PN}
	doman makedepf90.1
	einstalldocs
}
