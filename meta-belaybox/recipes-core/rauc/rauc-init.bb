LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PV = "0.1"
INSANE_SKIP:${PN} = "already-stripped useless-rpaths arch file-rdeps"

SRC_URI = "file://rauc-init.service \
           file://rauc-init.sh \
          "

S = "${WORKDIR}"

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/rauc-init.service ${D}${systemd_system_unitdir}
    install -d -m 0755 ${D}/usr/lib/rauc
    install -m 0755 ${WORKDIR}/rauc-init.sh ${D}/usr/lib/rauc/
}

FILES:${PN} += "/usr/lib/rauc/rauc-init.sh "
FILES:${PN} += "${systemd_system_unitdir}/rauc-init.service"

inherit systemd

SYSTEMD_AUTO_ENABLE:${PN} = "enable"
SYSTEMD_PACKAGES = "${PN}"

SYSTEMD_SERVICE:${PN} = "rauc-init.service"

