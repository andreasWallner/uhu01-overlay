# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit versionator

MY_PN="JLink_Linux"
MY_PV="V$(delete_all_version_separators)"
MY_P_64="${MY_PN}_${MY_PV}_x86_64.tgz"
MY_P_32="${MY_PN}_${MY_PV}_i386.tgz"
MY_P_arm="${MY_PN}_${MY_PV}_arm.tgz"

INSTALLDIR="/opt/${PN}"

DESCRIPTION="J-Link gdb-server and commander for Segger J-Link jtag adapter"
HOMEPAGE="http://www.segger.com/jlink-software.html"
SRC_URI="amd64? ( ${MY_P_64} )
	x86? ( ${MY_P_32} )
	arm? ( ${MY_P_arm} )"
LICENSE="J-Link Terms of Use"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~arm"
IUSE=""
QA_PREBUILT="*"

RESTRICT="fetch strip"
DEPEND=""
RDEPEND="${DEPEND}
	dev-libs/libedit"

S=${WORKDIR}/${A/.tgz/}

pkg_nofetch() {
    einfo "Segger requires you to download the needed files manually after"
    einfo "entering the serial number of your debugging probe."
    einfo
	einfo "Download ${A}"
    einfo "from ${HOMEPAGE} and place it in ${DISTDIR}"
}

src_install() {
	dodir ${INSTALLDIR}
	dodir ${INSTALLDIR}/lib
	dodir ${INSTALLDIR}/doc

	local BINS="JLinkExe JLinkGDBServer JLinkRemoteServer JLinkSWOViewer"
	for wrapper in $BINS ; do
		make_wrapper $wrapper ./$wrapper ${INSTALLDIR} lib
	done

	exeinto ${INSTALLDIR}
	doexe $BINS

	exeinto ${INSTALLDIR}/lib
	pushd "$S"
	local LIBNAME=$(ls libjlinkarm.so.${PV/[a-z]/}*)
	popd
	doexe "${LIBNAME}"
	dosym "${LIBNAME}" ${INSTALLDIR}/lib/libjlinkarm.so.$(get_major_version)

	insinto ${INSTALLDIR}/doc
	doins README.txt
	doins Doc/License.txt
	doins Doc/UM08001_JLink.pdf
	doins Doc/ReleaseNotes/ReleaseJLink.html

	insinto ${INSTALLDIR}
	doins -r Samples

	insinto /lib/udev/rules.d/
	doins 99-jlink.rules
}

pkg_postinst() {
	enewgroup plugdev
	elog "To be able to access the jlink usb adapter, you have to be"
	elog "a member of the 'plugdev' group."
}
