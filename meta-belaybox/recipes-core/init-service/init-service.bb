SUMMARY = "Customization and configuration of the RAUC package"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r0"
INSANE_SKIP:${PN} = "already-stripped usrmerge useless-rpaths arch file-rdeps"

SRC_URI = "file://init-service.service \
           file://init-hostname.sh \
           file://set-hostname.service \
          "

S = "${WORKDIR}"

do_install() {
    install -d ${D}${systemd_system_unitdir}
    install -d ${D}/usr/bin
    install -m 0644 ${WORKDIR}/init-service.service ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/set-hostname.service ${D}${systemd_system_unitdir}
    install -m 0755 ${WORKDIR}/init-hostname.sh ${D}/usr/bin
}

FILES:${PN} += "${systemd_system_unitdir}/init-service.service"
FILES:${PN} += "${systemd_system_unitdir}/set-hostname.service"
FILES:${PN} += "/usr/bin "
FILES:${PN} += "/usr/bin/init-hostname.sh "


# Define the package
PACKAGES = "${PN}"

inherit systemd

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE:${PN} = "init-service.service  set-hostname.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"
