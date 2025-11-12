SUMMARY = "Customization and configuration of the RAUC package"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r0"
INSANE_SKIP:${PN} = "already-stripped usrmerge useless-rpaths arch file-rdeps"

SRC_URI = "file://.profile \
           file://backend.sh \
           file://info-provider.sh \
           file://pre-install.sh \
           file://post-install.sh \
           file://raspberrypi-rauc.rules \
           file://rauc.conf \
           file://check_system_health.sh \
           "

S = "${WORKDIR}"

do_install() {
    install -d -m 0755 ${D}/${bindir}
    install -d -m 0755 ${D}/home/root
    install -d -m 0755 ${D}/mnt/rauc
    install -d -m 0755 ${D}/factory_data
    install -d -m 0755 ${D}/usr/lib/rauc
    install -d -m 0755 ${D}/etc/modules-load.d/
    install -d -m 0755 ${D}/etc/udev/mount.blacklist.d
    install -m 0755 ${WORKDIR}/.profile ${D}/home/root/
    install -m 0755 ${WORKDIR}/backend.sh ${D}/usr/lib/rauc/
    install -m 0755 ${WORKDIR}/info-provider.sh ${D}/usr/lib/rauc/
    install -m 0755 ${WORKDIR}/pre-install.sh ${D}/usr/lib/rauc/
    install -m 0755 ${WORKDIR}/post-install.sh ${D}/usr/lib/rauc/
    install -m 0644 ${WORKDIR}/rauc.conf ${D}/etc/modules-load.d/
    install -m 0644 ${WORKDIR}/raspberrypi-rauc.rules ${D}/etc/udev/mount.blacklist.d/

    install -m 0755 ${WORKDIR}/check_system_health.sh ${D}/${bindir}
}

FILES:${PN} += "/mnt/rauc "
FILES:${PN} += "/factory_data "
FILES:${PN} += "/home/root/.profile "
FILES:${PN} += "/usr/lib/rauc/backend.sh "
FILES:${PN} += "/usr/lib/rauc/info-provider.sh "
FILES:${PN} += "/usr/lib/rauc/pre-install.sh "
FILES:${PN} += "/usr/lib/rauc/post-install.sh "
FILES:${PN} += "/etc/udev/mount.blacklist.d/raspberrypi-rauc.rules "
FILES:${PN} += "/etc/modules-load.d/rauc.conf "
FILES:${PN} += "${bindir}/check_system_health.sh "

# Define the package
PACKAGES = "${PN}"

