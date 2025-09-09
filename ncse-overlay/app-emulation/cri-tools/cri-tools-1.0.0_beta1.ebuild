EAPI=6

if [[ ${PV} =~ ([0-9]+.[0-9]+.[0-9]+)_([a-z]+)([0-9]+) ]] ; then
    EGIT_COMMIT=${BASH_REMATCH[1]}-${BASH_REMATCH[2]}.${BASH_REMATCH[3]}
else
    die "Couldn't parse version"
fi
SRC_URI="https://github.com/kubernetes-incubator/cri-tools/archive/v${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64"
S="${WORKDIR}/${PN}-${EGIT_COMMIT}"

DESCRIPTION="CLI and validation tools for Kubelet Container Runtime Interface (CRI)."
HOMEPAGE="https://github.com/kubernetes-incubator/cri-tools"

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""
RDEPEND=""
DEPEND="dev-lang/go"

DOCS="LICENSE CHANGELOG.md CONTRIBUTING.md OWNERS README.md RELEASE.md"

src_compile() {
    GOPATH="${S}" emake crictl
}

src_install() {
    pushd bin 2> /dev/null || die
    dobin crictl
    popd || die

    einstalldocs
}
