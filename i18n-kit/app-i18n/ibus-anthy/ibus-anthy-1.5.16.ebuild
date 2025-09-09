# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python3+ )

inherit autotools gnome3-utils python-single-r1 xdg

DESCRIPTION="Japanese Anthy engine for IBus"
HOMEPAGE="https://github.com/ibus/ibus/wiki"
SRC_URI="https://github.com/ibus/ibus-anthy/tarball/ce1866174c1815f2dbffefc1002039970edc10d2 -> ibus-anthy-1.5.16-ce18661.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="nls"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	app-i18n/anthy
	$(python_gen_cond_dep '
		app-i18n/ibus[python(+),${PYTHON_USEDEP}]
		dev-python/pygobject:3[${PYTHON_USEDEP}]
	')
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}"
BDEPEND="sys-devel/gettext
	virtual/pkgconfig"

post_src_unpack() {
	mv "${WORKDIR}"/ibus-ibus-anthy-* "${S}" || die
}

src_prepare() {
	default
	eautoreconf
	gnome3_environment_reset
}

src_configure() {
	econf \
		$(use_enable nls) \
		--enable-private-png \
		--with-layout=default \
		--with-python=${EPYTHON}
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die

	python_optimize
}

pkg_preinst() {
	xdg_pkg_preinst
	gnome3_schemas_savelist
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome3_schemas_update

	if ! has_version app-dicts/kasumi; then
		elog "app-dicts/kasumi is not required but probably useful for you."
	fi
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome3_schemas_update
}