# Copyright 2022 Gianni Bombelli <bombo82@giannibombelli.it>
# Distributed under the terms of the GNU General Public License as published by the Free Software Foundation;
# either version 2 of the License, or (at your option) any later version.

EAPI=8

inherit desktop wrapper

DESCRIPTION="Fast & powerful cross-platform .NET IDE"
HOMEPAGE="https://www.jetbrains.com/rider/"
# FIXME check licenses
LICENSE="
	|| ( jetbrains_business-4.0 jetbrains_individual-4.2 jetbrains_educational-4.0 jetbrains_classroom-4.2 jetbrains_opensource-4.2 )
	Apache-1.1 Apache-2.0 BSD BSD-2 CC0-1.0 CC-BY-2.5 CDDL CDDL-1.1 codehaus CPL-1.0 GPL-2 GPL-2-with-classpath-exception GPL-3 ISC LGPL-2.1 LGPL-3 MIT MPL-1.1 MPL-2.0 OFL trilead-ssh yFiles yourkit W3C ZLIB
"
SLOT="0"
VER="$(ver_cut 1-2)"
KEYWORDS="~amd64"
RESTRICT="bindist mirror splitdebug"
IUSE=""
QA_PREBUILT="opt/${P}/*"
RDEPEND="
	app-accessibility/at-spi2-atk
	dev-libs/libdbusmenu
	dev-util/lldb
	dev-util/lttng-ust
	media-libs/mesa[X(+)]
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	>=x11-libs/libXi-1.3
	>=x11-libs/libXrandr-1.5
"

SIMPLE_NAME="Rider"
MY_PN="rider"
SRC_URI_PATH="rider"
SRC_URI_PN="JetBrains.Rider"
SRC_URI="https://download.jetbrains.com/${SRC_URI_PATH}/${SRC_URI_PN}-${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/JetBrains Rider-${PV}"

src_prepare() {
	default

	local pty4j_path="lib/pty4j-native/linux"
	local ReSharperHost_path="lib/ReSharperHost/"
	local remove_me=( "${pty4j_path}"/ppc64le "${pty4j_path}"/aarch64 "${pty4j_path}"/mips64el "${pty4j_path}"/arm )
	remove_me+=( "${ReSharperHost_path}"/linux-arm "${ReSharperHost_path}"/linux-arm64 "$ReSharperHost_path"/linux-musl-arm64 "${ReSharperHost_path}"/linux-x86 "${ReSharperHost_path}"/macos-arm64 "${ReSharperHost_path}"/macos-x64 "${ReSharperHost_path}"/windows-x64 "${ReSharperHost_path}"/windows-x86 )

	rm -rv "${remove_me[@]}" || die
}

src_install() {
	local dir="/opt/${P}"

	insinto "${dir}"
	doins -r *
	fperms 755 "${dir}"/bin/{"${MY_PN}",format,inspect,ltedit,remote-dev-server}.sh
	fperms 755 "${dir}"/bin/fsnotifier

	fperms 755 "${dir}"/plugins/cidr-debugger-plugin/bin/lldb/linux/bin/{lldb,lldb-argdumper,LLDBFrontend,lldb-server}
	fperms 755 "${dir}"/lib/ReSharperHost/{Rider.Backend.sh,runtime-dotnet.sh}
	fperms 755 "${dir}"/lib/ReSharperHost/linux-x64/{7za,Rider.Backend}
	fperms 755 "${dir}"/lib/ReSharperHost/linux-x64/dotnet/dotnet

	fperms 755 "${dir}"/jbr/bin/{java,javac,jcmd,jdb,jfr,jinfo,jmap,jps,jrunscript,jstack,jstat,keytool,rmiregistry,serialver}
	fperms 755 "${dir}"/jbr/lib/{chrome-sandbox,jcef_helper,jexec,jspawnhelper}

	make_wrapper "${PN}" "${dir}"/bin/"${MY_PN}".sh
	newicon bin/"${MY_PN}".svg "${PN}".svg
	make_desktop_entry "${PN}" "${SIMPLE_NAME} ${VER}" "${PN}" "Development;IDE;"

	# recommended by: https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
	dodir /usr/lib/sysctl.d/
	echo "fs.inotify.max_user_watches = 524288" > "${D}/usr/lib/sysctl.d/30-${PN}-inotify-watches.conf" || die
}
