SUMMARY = "Customization and configuration of the RAUC package"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r0"
INSANE_SKIP:${PN} = "already-stripped usrmerge useless-rpaths arch file-rdeps"

SRC_URI = "file://overlayfs-init.service \
           file://overlayfs-init.sh \
          "

S = "${WORKDIR}"

do_install() {
    install -d -m 0755 ${D}/overlay
    install -d ${D}${systemd_system_unitdir}
    install -d ${D}/usr/bin
    install -m 0644 ${WORKDIR}/overlayfs-init.service ${D}${systemd_system_unitdir}
    install -m 0755 ${WORKDIR}/overlayfs-init.sh ${D}/usr/bin
}

FILES:${PN} += "/overlay "
FILES:${PN} += "${systemd_system_unitdir}/overlayfs-init.service"
FILES:${PN} += "/usr/bin "
FILES:${PN} += "/usr/bin/overlayfs-init.sh "

# Define the package
PACKAGES = "${PN}"

inherit systemd
SYSTEMD_AUTO_ENABLE:${PN} = "enable"
SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE:${PN} = "overlayfs-init.service"


