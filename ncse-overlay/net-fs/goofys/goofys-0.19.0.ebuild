EAPI=6

EGO_PN="github.com/kahing/goofys"
EGIT_COMMIT="943e017724ea820eb4185419ef3c41d6f921a324"
EGO_VENDOR=( "github.com/jacobsa/fuse 3b434060032d594d1a6f5145e7b100bc09ebd1b5"
        "github.com/jinzhu/copier 7e38e58719c33e0d44d585c4ab477a30f8cb82dd"
        "github.com/aws/aws-sdk-go 5bd0dfd750f991728fc4eda2bd34b8d158f69879"
        "github.com/kardianos/osext ae77be60afb1dcacde03767a8c37337fad28ac14"
        "github.com/sevlyar/go-daemon 32749a731f76154d29bc6a547e6585f320eb235e"
        "github.com/shirou/gopsutil cd915bdc31582b0a56405ede7fa2f4ab043f851b"
        "github.com/sirupsen/logrus 778f2e774c725116edbc3d039dc0dfc1cc62aae8"
        "github.com/urfave/cli cfb38830724cc34fedffe9a2a29fb54fa9169cd1"
        "golang.org/x/crypto beb2a9779c3b677077c41673505f150149fce895 github.com/golang/crypto"
        "golang.org/x/net 61147c48b25b599e5b561d2e9c4f3e1ef489ca41 github.com/golang/net"
        "golang.org/x/sys 3b87a42e500a6dc65dae1a55d0b641295971163e github.com/golang/sys"
        )

inherit user golang-build golang-vcs-snapshot

ARCHIVE_URI="https://${EGO_PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64"

DESCRIPTION="Goofys is a high-performance, POSIX-ish Amazon S3 file system written in Go"
HOMEPAGE="https://github.com/kahing/goofys"
SRC_URI="${ARCHIVE_URI}
        ${EGO_VENDOR_URI}"
LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

DEPEND="dev-lang/go:0"

src_compile() {
        env GOPATH="${WORKDIR}/${P}:$(get_golibdir_gopath)" \
                go build -v -ldflags "-X main.Version=${EGIT_COMMIT:0:7}" "${EGO_PN}"
}

src_install() {
        insopts -m0644 -p # preserve timestamps for bug 551486
        dobin goofys
}
