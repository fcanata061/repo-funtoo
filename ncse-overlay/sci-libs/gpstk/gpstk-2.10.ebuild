EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit cmake-utils python-single-r1

DESCRIPTION="Algorithms and frameworks supporting the development of processing and analysis applications in navigation and global positioning."
HOMEPAGE="http://www.gpstk.org/"

if [[ ${PV} = *9999* ]]; then
    inherit git-r3
    EGIT_REPO_URI="https://github.com/SGL-UT/GPSTk.git"
else
    SRC_URI="https://github.com/SGL-UT/GPSTk/archive/v${PV}.tar.gz -> ${P}.tar.gz"
    S=${WORKDIR}/GPSTk-${PV}
    KEYWORDS="~amd64 ~x86"
fi

LICENSE="LGPL-3"
SLOT="0"

IUSE="ext python doc test"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="
    python? ( ${PYTHON_DEPS} )
"
DEPEND="
    ${RDEPEND}
    python? ( <=dev-lang/swig-2.0.12 )
    doc? (
        app-doc/doxygen
        python? ( dev-python/sphinx[${PYTHON_USEDEP}] )
    )
"

PATCHES=(
)

src_configure() {
    local mycmakeargs=(
        -DBUILD_EXT=$(usex ext ON OFF)
        -DBUILD_PYTHON=$(usex python ON OFF)
        -DTEST_SWITCH=$(usex test ON OFF)
    )

    cmake-utils_src_configure
}
