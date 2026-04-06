# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg

DESCRIPTION="OpenXcom Extended fork with newer engine and modding features"
HOMEPAGE="https://github.com/MeridianOXC/OpenXcom https://openxcom.org/"
COMMIT="6017f5fec3f6738ae1e997f307a079a1eec28db5"
SRC_URI="https://github.com/MeridianOXC/OpenXcom/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+ CC-BY-SA-4.0 MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="doc"

PATCHES=(
    "${FILESDIR}/${PN}-8.5.8-cmake-4.2-compat.patch"
)

RDEPEND="
    !games-engines/openxcom
    sys-libs/zlib
    media-libs/libglvnd
    media-libs/libsdl[opengl,video]
    media-libs/sdl-gfx:=
    media-libs/sdl-image[png]
    media-libs/sdl-mixer[flac,mikmod,vorbis]
"
DEPEND="${RDEPEND}"
BDEPEND="
    virtual/pkgconfig
    doc? ( app-text/doxygen )
"

S="${WORKDIR}/OpenXcom-${COMMIT}"

DOCS=( README.md )

src_prepare() {
    cmake_src_prepare

    sed -i \
	-e '/include(GNUInstallDirs)/a option ( BUILD_DOCS "Build API documentation with Doxygen" ON )' \
	-e 's:add_subdirectory ( docs ):if ( BUILD_DOCS )\
    add_subdirectory ( docs )\
endif ():' \
	CMakeLists.txt || die
}

src_configure() {
    local mycmakeargs=(
	-DBUILD_PACKAGE=OFF
	-DBUILD_DOCS=$(usex doc ON OFF)
    )

    cmake_src_configure
}

src_compile() {
    cmake_src_compile
    use doc && cmake_build doxygen
}

src_install() {
    use doc && local HTML_DOCS=( "${BUILD_DIR}"/docs/html/. )
    cmake_src_install
}

pkg_postinst() {
    xdg_icon_cache_update

    elog "In order to play, copy GEODATA, GEOGRAPH, MAPS, ROUTES, SOUND,"
    elog "TERRAIN, UFOGRAPH, UFOINTRO and UNITS from the original X-COM game to"
    elog "/usr/share/openxcom/UFO"
    elog
    elog "If you want to play the TFTD mod, copy ANIMS, FLOP_INT, GEODATA,"
    elog "GEOGRAPH, MAPS, ROUTES, SOUND, TERRAIN, UFOGRAPH and UNITS from the"
    elog "original Terror from the Deep game to"
    elog "/usr/share/openxcom/TFTD"
    elog
    elog "If you need translations beyond English, place language files into"
    elog "/usr/share/openxcom/common/Language"
}

pkg_postrm() {
    xdg_icon_cache_update
}
