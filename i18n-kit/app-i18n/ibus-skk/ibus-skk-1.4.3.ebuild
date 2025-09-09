# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit vala

DESCRIPTION="Japanese SKK engine for IBus"
HOMEPAGE="https://github.com/ueno/ibus-skk"
SRC_URI="https://github.com/ueno/ibus-skk/releases/download/ibus-skk-1.4.3/ibus-skk-1.4.3.tar.xz -> ibus-skk-1.4.3.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"
IUSE="nls"

DEPEND="app-i18n/ibus
	>=app-i18n/libskk-1.0.2
	x11-libs/gtk+:3
	nls? ( virtual/libintl )"
RDEPEND="${DEPEND}
	app-i18n/skk-jisyo"
BDEPEND="$(vala_depend)
	dev-util/intltool
	virtual/pkgconfig
	nls? ( sys-devel/gettext )"

src_prepare() {
	vala_src_prepare
	default
}

src_configure() {
	econf $(use_enable nls)
}
