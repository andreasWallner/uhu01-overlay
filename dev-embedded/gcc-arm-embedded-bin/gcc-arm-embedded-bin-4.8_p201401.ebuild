# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Pre-built GNU toolchain from ARM Cortex-M & Cortex-R processors (Cortex-M0/M0+/M3/M4, Cortex-R4/R5/R7)."
HOMEPAGE="https://launchpad.net/gcc-arm-embedded"
SRC_URI="https://launchpad.net/gcc-arm-embedded/4.8/4.8-2014-q1-update/+download/gcc-arm-none-eabi-4_8-2014q1-20140314-linux.tar.bz2"

LICENSE="BSD GPL GPL-2 LGPL-2 LGPL-3 MIT NEWLIB ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~x86 -*"
IUSE="doc samples"
RESTRICT="strip binchecks"

DEPEND=""
RDEPEND="amd64? ( app-emulation/emul-linux-x86-baselibs )"

S="${WORKDIR}"/gcc-arm-none-eabi-4_8-2014q1/

src_install() {
	if ! use samples ; then
		rm -rf "${S}"/share/gcc-arm-none-eabi/samples
	fi
	if ! use doc ; then
		rm -rf "${S}"/share/doc
	fi

	local DEST=/opt/${PN}

	dodir ${DEST}
	cp -r "${S}"/* "${ED}${DEST}" || die "cp failed"
	fowners -R root:root ${DEST}

	cat > "${T}/env" << EOF
PATH=${DEST}/bin
ROOTPATH=${DEST}/bin
LDPATH=${DEST}/lib
MANPATH=${DEST}/share/doc/arm-arm-none-eabi/man
EOF
	newenvd "${T}/env" 99gcc-arm-embedded-bin
}

pkg_postinst() {
	env-update
}
