LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PV = "0.1"
INSANE_SKIP:${PN} = "already-stripped useless-rpaths arch file-rdeps"

SRC_URI = "file://test.sh \
           file://test.service \
          "

S = "${UNPACKDIR}"

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/test.service ${D}${systemd_system_unitdir}
    install -d -m 0755 ${D}/usr/bin
    install -m 0755 ${S}/test.sh ${D}/usr/bin/
}

FILES:${PN} += "/usr/bin/ "
FILES:${PN} += "/usr/bin/test.sh "
FILES:${PN} += "${systemd_system_unitdir}/test.service"

inherit systemd

SYSTEMD_AUTO_ENABLE:${PN} = "enable"
SYSTEMD_PACKAGES = "${PN}"

SYSTEMD_SERVICE:${PN} = "test.service"

