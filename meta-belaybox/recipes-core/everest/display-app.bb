SUMMARY = "Flutter PIONIX Display App"
DESCRIPTION = "Flutter PIONIX Display App"
AUTHOR = "PIONIX"
HOMEPAGE = "https://github.com/PionixPublic/display-app"
BUGTRACKER = "https://customer.support.pionix.com/jira/software/c/projects/DA/boards/565"
SECTION = "graphics"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

# Default SRCREV and SRC_URI
SRC_URI = "git://github.com/rckstrh/display-app.git;branch=fix/cloud-connector;protocol=https \
           file://display-app.service \
          "
SRCREV = "1d745d5e3ff4379da1938cfc75475b932e55d905"

inherit flutter-app
inherit features_check
inherit systemd

# meta-flutter's pub cache tasks read BB_NUMBER_THREADS to size pbzip2. The
# variable is in BB_HASHCONFIG_IGNORE_VARS but not in BB_BASEHASH_IGNORE_VARS,
# so a changed thread count keeps the parse cache valid while the worker's
# reparse computes a different basehash ("The metadata is not deterministic").
# Keep it out of the task signatures, as poky does for its own users of it.
do_archive_pub_cache[vardepsexclude] += "BB_NUMBER_THREADS"
do_restore_pub_cache[vardepsexclude] += "BB_NUMBER_THREADS"

S = "${WORKDIR}/git"

do_configure[network] = "1"
do_compile[network] = "1"

PR = "r1"

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
