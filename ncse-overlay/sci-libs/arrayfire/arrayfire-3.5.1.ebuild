EAPI=6
inherit cmake-utils

DESCRIPTION="ArrayFire is a high performance software library for parallel computing with an easy-to-use API."
HOMEPAGE="http://arrayfire.org"

if [[ ${PV} = *9999* ]]; then
    inherit git-r3
    EGIT_REPO_URI="https://github.com/arrayfire/arrayfire.git"
    EGIT_BRANCH="master"
else
    SRC_URI="http://arrayfire.com/arrayfire_source/arrayfire-full-${PV}.tar.bz2"
    S=${WORKDIR}/arrayfire-full-${PV}
fi

LICENSE="BSD-with-attribution"
SLOT="0"
KEYWORDS="amd64"

CUDA_COMPUTES="20 30 32 35 37 50 52 53 60 61 62 70"

IUSE_CUDA_COMPUTES=""
for compute in $CUDA_COMPUTES ; do
    IUSE_CUDA_COMPUTES="cuda_compute_${compute} ${IUSE_CUDA_COMPUTES}"
done

IUSE="debug doc +unified +cpu cuda ${IUSE_CUDA_COMPUTES} lapack opencl examples graphics nonfree test"

REQUIRED_USE="cuda? ( || ( ${IUSE_CUDA_COMPUTES} ) )"
for compute in $CUDA_COMPUTES ; do
    REQUIRED_USE="${REQUIRED_USE} cuda_compute_${compute}? ( cuda )"
done

RDEPEND="
    media-libs/freeimage
    lapack? ( virtual/lapack )
    cpu? (
        virtual/cblas
        sci-libs/fftw:3.0
    )
    graphics? (
        >=media-libs/glfw-3.1.4
        media-libs/fontconfig:1.0
    )
    cuda? ( >=dev-util/nvidia-cuda-toolkit-7.0 )
    opencl? (
        >=dev-libs/boost-1.48
        virtual/opencl
        sci-libs/clblast
    )
"

PATCHES=(
    "${FILESDIR}/cuda-9-cmake.patch"
)

src_configure() {
    OPENCL=$(eselect opencl show 2> /dev/null || echo "none")
    if use opencl && [[ ${OPENCL} == nvidia ]] ; then
        eerror "ArrayFire OpenCL will not build against NVidia SDK, please eselect a different OpenCL."
        eerror "NVidia OpenCL *should* work at runtime."
        die "NVidia OpenCL not supported at build time"
    fi

    local mycmakeargs=(
       -DBUILD_UNIFIED="$(usex unified)"
       -DBUILD_CPU="$(usex cpu)"
       -DBUILD_CUDA="$(usex cuda)"
       -DBUILD_OPENCL="$(usex opencl)"
       -DBUILD_GRAPHICS="$(usex graphics)"
       -DBUILD_NONFREE="$(usex nonfree)"
       -DBUILD_EXAMPLES="$(usex examples)"
       -DBUILD_TEST="$(usex test)"
       -DBUILD_DOCS="$(usex doc)"
       -DUSE_SYSTEM_CLBLAST=ON
       -DOPENCL_BLAS_LIBRARY=CLBlast
    )

    if use cuda ; then
        COMPUTES_LIST=""
        for compute in ${CUDA_COMPUTES} ; do
            if use cuda_compute_${compute} ; then
                COMPUTES_LIST="${compute};$COMPUTES_LIST"
            fi
        done

        [ -z "${COMPUTES_LIST}" ] && die "No CUDA computes specified?!"

        mycmakeargs+=(
            -DCUDA_COMPUTE_DETECT=OFF
            -DCOMPUTES_DETECTED_LIST=${COMPUTES_LIST::-1}
        )
    fi

    cmake-utils_src_configure
}
