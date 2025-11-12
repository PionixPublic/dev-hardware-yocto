SUMMARY = "Customization of wpa_supplication - we overwrite the default one"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PV = "0.1"
INSANE_SKIP:${PN} = "already-stripped useless-rpaths arch file-rdeps"

SRC_URI = "file://wpa-supplicant.service"

S = "${WORKDIR}"

do_install() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/wpa-supplicant.service ${D}${systemd_system_unitdir}/wpa-supplicant.service
}

FILES_${PN} += "${systemd_system_unitdir}/wpa-supplicant.service"

inherit systemd

SYSTEMD_AUTO_ENABLE:${PN} = "enable"
SYSTEMD_PACKAGES = "${PN}"

SYSTEMD_SERVICE:${PN} = "wpa-supplicant.service"

