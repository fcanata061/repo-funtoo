# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
EGO_PN="github.com/NVIDIA/nvidia-container-runtime"

MY_PVR="${PVR/_/-}"
EGIT_COMMIT="v${MY_PVR/r/}"
SRC_URI="https://${EGO_PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64"
inherit golang-build golang-vcs-snapshot

DESCRIPTION="nvidia custom pre-start hook to all containers"
HOMEPAGE="https://github.com/NVIDIA/nvidia-container-runtime"

LICENSE="NVIDIA-r2"
SLOT="0"

RDEPEND="
    app-emulation/libnvidia-container[tools]
"

src_compile() {
    pushd src/${EGO_PN}/hook/nvidia-container-runtime-hook 2> /dev/null || die
    go get -d
    go build
    popd || die
}

src_install() {
    pushd src/${EGO_PN} 2> /dev/null || die
    dobin hook/nvidia-container-runtime-hook/nvidia-container-runtime-hook
    dodoc LICENSE
    dodir /etc/nvidia-container-runtime
    insinto /etc/nvidia-container-runtime
    newins hook/config.toml.amzn config.toml
    popd || die
}
