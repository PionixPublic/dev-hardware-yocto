SUMMARY = "Configuration for systemd-networkd-wait-online"
DESCRIPTION = "Provides a drop-in for systemd-networkd-wait-online to use --any and a shorter timeout."
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = "file://wait-any.conf"

S = "${WORKDIR}"

do_install() {
    install -d ${D}${systemd_system_unitdir}/systemd-networkd-wait-online.service.d
    install -m 0644 ${WORKDIR}/wait-any.conf ${D}${systemd_system_unitdir}/systemd-networkd-wait-online.service.d/10-wait-any.conf
}

FILES:${PN} += "${systemd_system_unitdir}/systemd-networkd-wait-online.service.d/10-wait-any.conf"

# This is a configuration-only package, so it should be allarch
inherit allarch
