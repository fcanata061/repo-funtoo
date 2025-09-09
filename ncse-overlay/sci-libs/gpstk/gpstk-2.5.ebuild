EAPI=6

inherit cmake-utils

DESCRIPTION="Algorithms and frameworks supporting the development of processing and analysis applications in navigation and global positioning."
HOMEPAGE="http://www.gpstk.org/"

SRC_URI="https://github.com/SGL-UT/GPSTk/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S=${WORKDIR}/GPSTk-${PV}/dev
KEYWORDS="~amd64 ~x86"

LICENSE="LGPL-3"
SLOT="0"

IUSE=""

PATCHES=(
    "${FILESDIR}/${PV}-compare-logstream.patch"
)
