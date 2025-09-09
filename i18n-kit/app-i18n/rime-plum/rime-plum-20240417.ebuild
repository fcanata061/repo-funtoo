# Distributed under the terms of the GNU General Public License v2
# Plum replaces brise, the old database package that many distributions currently use
EAPI="7"

inherit user

DESCRIPTION="Rime configuration manager and input schema repository"
HOMEPAGE="https://rime.im/ https://github.com/rime/plum"
SRC_URI="
	https://github.com/rime/plum/archive/4c28f11f451facef809b380502874a48ba964ddb.tar.gz -> rime-plum-20240417.tar.gz
	https://github.com/rime/rime-bopomofo/archive/c7618f4f5728e1634417e9d02ea50d82b71956ab.tar.gz -> bopomofo.tar.gz
	https://github.com/rime/rime-cangjie/archive/0ac8452eeb4abbcd8dd1f9e7314012310743285f.tar.gz -> cangjie.tar.gz
	https://github.com/rime/rime-essay/archive/5fe7d1aa4be2c20c6326e4d692022ab92523656f.tar.gz -> essay.tar.gz
	https://github.com/rime/rime-luna-pinyin/archive/0418e912d023c2325598b53b8cdfbefb049d6130.tar.gz -> luna-pinyin.tar.gz
	https://github.com/rime/rime-prelude/archive/3803f09458072e03b9ed396692ce7e1d35c88c95.tar.gz -> prelude.tar.gz
	https://github.com/rime/rime-stroke/archive/65fdbbf2f9485cc907cb9a6d6b9210938a50f71e.tar.gz -> stroke.tar.gz
	https://github.com/rime/rime-terra-pinyin/archive/333ec4128fa1f93924a0707da3c623ccd92a73f0.tar.gz -> terra-pinyin.tar.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="*"

DEPEND="app-i18n/librime"
RDEPEND="${DEPEND}"

pkg_setup() {
	# Create the rime group
	enewgroup "rime"
}

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}"/plum-* "${S}"
}

src_compile() {
	echo "Nothing to compile"
}

src_install() {
	# create directories and files that are needed
	mkdir -p ${ED}/usr/bin/
	mkdir -p ${ED}/usr/share/rime-data
	mkdir -p ${ED}/var/lib/plum
	mkdir -p ${ED}/etc

	# Install the plum source code to /var/lib, the source is required for plum to actually function.
	# There is no standard directory for installing the plum source, instead it is defined by an
	# environment variable. Logically it should be under /var/lib so that's where I put it
	cp "${S}"/* "${ED}"/var/lib/plum -r

	# Copy the script from the source to the binary directory
	cp ${ED}/var/lib/plum/rime-install ${ED}/usr/bin/rime-install

	# Install the data for rime, we cannot use the rime-install package manager since we don't have internet access so we use
	# tarballs provided from artifacts that comprise the minimal package set
	for directory in "${WORKDIR}"/*/; do
		cp -f "${directory}"*.yaml "${directory}"*.txt "${ED}"/usr/share/rime-data &> /dev/null
	done

	# install the plum_dir environment variable
	echo "plum_dir=\"/var/lib/plum\"" >> "${ED}"/etc/environment

	# Manage permissions here
	fowners -R :rime /var/lib/plum/
	fperms -R g+w+s /var/lib/plum/
}

pkg_postinst() {
	elog "To use rime please add yourself to the \"rime\" group to have access"
	elog "to the \"rime-install\" executable. This application is the new"
	elog "database + micro package manager for rime. For more information"
	elog "visit our rime page at:"
	elog "https://www.funtoo.org/Package:IBus/Chinese/rime"
	elog "For more information on how to use the package manager head to the"
	elog "\"Bundled input methods and installing additional ones\" paragraph"
}