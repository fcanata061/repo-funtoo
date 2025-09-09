EAPI=6
inherit cmake-utils

DESCRIPTION="OSSIM is an open source, C++ (mostly), geospatial image processing library used by government, commercial, educational, and private entities throughout the solar system."
HOMEPAGE="https://trac.osgeo.org/ossim/"

if [[ ${PV} = *9999* ]]; then
    inherit git-r3
    EGIT_REPO_URI="https://github.com/ossimlabs/ossim-video"
else
    RELEASE="Gasparilla"
    SRC_URI="https://github.com/ossimlabs/ossim-video/archive/${RELEASE}-${PV}.tar.gz -> ${P}.tar.gz"
    S=${WORKDIR}/${PN}-${RELEASE}-${PV}
    KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"

IUSE="debug"

RDEPEND="
    sci-libs/ossim
    media-video/ffmpeg
"

PATCHES=(
    "${FILESDIR}/ossim-cmake-modules.patch"
)

src_configure() {
    local mycmakeargs=(
        -DBUILD_GDAL_PLUGIN=OFF
        -DBUILD_KAKADU_PLUGIN=OFF
        -DBUILD_MRSID_PLUGIN=OFF
        -DBUILD_OMS=OFF
        -DBUILD_OSSIM_FRAMEWORKS=OFF
        -DBUILD_OSSIM_GUI=OFF
        -DBUILD_OSSIM_PLANET=OFF
        -DBUILD_OSSIM_VIDEO=ON
        -DBUILD_OSSIM_WMS=OFF
        -DBUILD_PDAL_PLUGIN=OFF
    )

    cmake-utils_src_configure
}
