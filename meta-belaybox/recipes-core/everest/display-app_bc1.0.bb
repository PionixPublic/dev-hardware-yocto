SUMMARY = "Flutter PIONIX Display App"
DESCRIPTION = "Flutter PIONIX Display App"
AUTHOR = "PIONIX"
HOMEPAGE = "https://github.com/PionixPro/display-app"
BUGTRACKER = "https://customer.support.pionix.com/jira/software/c/projects/DA/boards/565"
SECTION = "graphics"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

# Default SRCREV and SRC_URI
SRCREV = "808cbcf62fd5bb85b3c382a011a9cbeccbc02ad6"
SRC_URI = "git://github.com/PionixPublic/display-app.git;branch=development;protocol=https \
           file://display-app.service \
          "

inherit flutter-app
inherit features_check
inherit systemd

S = "${WORKDIR}/git"

SRCREV = "7e3e5feff8d0ac7aaff978992d0446b62ddad159"
do_configure[network] = 'true'
do_compile[network] = 'true'

PR = "r0"

PUBSPEC_APPNAME = "display_app"
FLUTTER_APPLICATION_INSTALL_PREFIX = "/usr/share/flutter"
FLUTTER_BUILD_ARGS = "bundle"

REQUIRED_DISTRO_FEATURES= " systemd"
SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"
SYSTEMD_SERVICE:${PN} = "display-app.service"

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/display-app.service ${D}${systemd_system_unitdir}
    ln -sr ${D}${FLUTTER_INSTALL_DIR}/${FLUTTER_SDK_VERSION}/release ${D}${FLUTTER_INSTALL_DIR}/app
}

FILES:${PN} += "${systemd_system_unitdir}/display-app.service"
