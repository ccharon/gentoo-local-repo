EAPI=8

inherit systemd

DESCRIPTION="Little Snitch for Linux binary package"
HOMEPAGE="https://obdev.at/products/littlesnitch-linux/download.html"

MY_PKGREL=1
MY_PN="littlesnitch"

SRC_URI="
    amd64? ( https://obdev.at/downloads/littlesnitch-linux/${MY_PN}-${PV}-${MY_PKGREL}-x86_64.pkg.tar.zst )
    arm64? ( https://obdev.at/downloads/littlesnitch-linux/${MY_PN}-${PV}-${MY_PKGREL}-aarch64.pkg.tar.zst )
    riscv? ( https://obdev.at/downloads/littlesnitch-linux/${MY_PN}-${PV}-${MY_PKGREL}-riscv64.pkg.tar.zst )
"

LICENSE="LittleSnitch-Linux"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~riscv"
RESTRICT="bindist mirror strip"

BDEPEND="app-arch/zstd"

QA_PREBUILT="
    /usr/bin/littlesnitch
"

S="${WORKDIR}/${MY_PN}-${PV}"

src_unpack() {
    mkdir -p "${S}" || die

    local archive=
    if use amd64; then
	archive="${DISTDIR}/${MY_PN}-${PV}-${MY_PKGREL}-x86_64.pkg.tar.zst"
    elif use arm64; then
	archive="${DISTDIR}/${MY_PN}-${PV}-${MY_PKGREL}-aarch64.pkg.tar.zst"
    elif use riscv; then
	archive="${DISTDIR}/${MY_PN}-${PV}-${MY_PKGREL}-riscv64.pkg.tar.zst"
    else
	die "Unsupported ARCH"
    fi

    tar --zstd -xpf "${archive}" -C "${S}" || die "failed to unpack ${archive}"
}

src_install() {
    dobin "${S}"/usr/bin/littlesnitch

    systemd_dounit "${S}"/usr/lib/systemd/system/littlesnitch.service

    dodoc "${S}"/usr/share/doc/littlesnitch/copyright

    insinto /usr/share/metainfo
    doins "${S}"/usr/share/metainfo/at.obdev.littlesnitch.metainfo.xml
}

pkg_postinst() {
    elog "To use Little Snitch for Linux, enable and start the service:"
    elog "  systemctl enable --now littlesnitch.service"
    elog
    elog "Then start the UI with:"
    elog "  littlesnitch"
    elog "or open:"
    elog "  http://localhost:3031/"
}
