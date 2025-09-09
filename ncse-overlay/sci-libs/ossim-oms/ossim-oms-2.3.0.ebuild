EAPI=6

JAVA_PKG_IUSE=""

inherit java-pkg-2 java-pkg-simple cmake-utils

DESCRIPTION="OSSIM is an open source, C++ (mostly), geospatial image processing library used by government, commercial, educational, and private entities throughout the solar system."
HOMEPAGE="https://trac.osgeo.org/ossim/"

if [[ ${PV} = *9999* ]]; then
    inherit git-r3
    EGIT_REPO_URI="https://github.com/ossimlabs/ossim-oms"
else
    RELEASE="Gasparilla"
    SRC_URI="https://github.com/ossimlabs/ossim-oms/archive/${RELEASE}-${PV}.tar.gz -> ${P}.tar.gz"
    S=${WORKDIR}/${PN}-${RELEASE}-${PV}
    KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"

IUSE="debug java"

CDEPEND="
    java? (
        dev-java/groovy
        dev-java/commons-lang:2.1
        >=dev-java/commons-compress-1.9
    )
"
DEPEND="$CDEPEND"
RDEPEND="$CDEPEND
    sci-libs/ossim-video
"

PATCHES=(
    "${FILESDIR}/ossim-cmake-modules.patch"
    "${FILESDIR}/ossim-joms-no-maven.patch"
)

src_configure() {
    local mycmakeargs=(
        -DBUILD_GDAL_PLUGIN=OFF
        -DBUILD_KAKADU_PLUGIN=OFF
        -DBUILD_MRSID_PLUGIN=OFF
        -DBUILD_OMS=ON
        -DBUILD_OSSIM_FRAMEWORKS=OFF
        -DBUILD_OSSIM_GUI=OFF
        -DBUILD_OSSIM_PLANET=OFF
        -DBUILD_OSSIM_VIDEO=ON
        -DBUILD_OSSIM_WMS=OFF
        -DBUILD_PDAL_PLUGIN=OFF
    )

    cmake-utils_src_configure
}

src_compile() {
    cmake-utils_src_compile

    if use java ; then
        echo "ossim.home=/usr" > ${S}/joms/local.properties
        echo "oms.home=${S}" >> ${S}/joms/local.properties
        echo "ossim.build=${BUILD_DIR}" >> ${S}/joms/local.properties
        echo "jdk.home=$(java-config -g JAVA_HOME)" >> ${S}/joms/local.properties
        ant -f ${S}/joms/build.xml generate-wrappers compile-c++ compile-java || die "Java/JNI compile failed"
        groovyc $(find ${S}/joms -name "*.groovy" -type f) -cp "${S}/joms/bin:$(java-pkg_getjar --build-only commons-compress commons-compress.jar):${FILESDIR}/groovy-json-2.4.5.jar" -d ${BUILD_DIR}/joms/bin || die "Groovy compile failed"
    fi
}

src_install() {
    cmake-utils_src_install

    if use java ; then
        dolib ${S}/joms/libjoms.so
        cp -r ${S}/joms/bin/* ${BUILD_DIR}/joms/bin
        cp -r ${S}/joms/src/java/META-INF ${BUILD_DIR}/joms/bin
        $(java-config -j) cf ${S}/joms-${PV}.jar -C ${BUILD_DIR}/joms/bin .
        JAVA_JAR_FILENAME="joms-${PV}.jar" java-pkg-simple_src_install
    fi
}
