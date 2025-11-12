LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PV = "0.1"
INSANE_SKIP:${PN} = "already-stripped useless-rpaths arch file-rdeps"

SRC_URI = "file://autoinstall@.service \
           file://autoinstall.sh \
           file://99-autoinstall.rules \
          "

S = "${WORKDIR}"

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/autoinstall@.service ${D}${systemd_system_unitdir}
    install -d -m 0755 ${D}/usr/bin
    install -m 0755 ${WORKDIR}/autoinstall.sh ${D}/usr/bin/
    install -d -m 0755 ${D}/etc/udev/rules.d
    install -m 0755 ${WORKDIR}/99-autoinstall.rules ${D}/etc/udev/rules.d
}

FILES:${PN} += "/usr/bin/ "
FILES:${PN} += "/usr/bin/autoinstall.sh "
FILES:${PN} += "/etc/udev/rules.d/99-autoinstall.rules "
FILES:${PN} += "${systemd_system_unitdir}/autoinstall@.service"

inherit systemd

SYSTEMD_AUTO_ENABLE:${PN} = "enable"
SYSTEMD_PACKAGES = "${PN}"

SYSTEMD_SERVICE:${PN} = "autoinstall@.service"

