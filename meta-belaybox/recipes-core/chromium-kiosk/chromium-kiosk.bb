SUMMARY = "Chromium Kiosk Docker Container and Service"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit systemd

SRC_URI = " \
    file://Dockerfile \
    file://build-chromium.sh \
    file://chromium-kiosk.service \
"

S = "${WORKDIR}"

SYSTEMD_SERVICE:${PN} = "chromium-kiosk.service"
SYSTEMD_AUTO_ENABLE = "enable"

CHROMIUM_KIOSK_URL ?= "http://localhost:3000"

# We need bash for our setup script and docker/weston at runtime
RDEPENDS:${PN} += "bash docker-moby weston-init next-display-app"

do_install() {
    # Install the Dockerfile for the first-boot build
    install -d ${D}${sysconfdir}/chromium-kiosk
    install -m 0644 ${WORKDIR}/Dockerfile ${D}${sysconfdir}/chromium-kiosk/Dockerfile

    # Install the build script
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/build-chromium.sh ${D}${bindir}/build-chromium.sh

    # Install the systemd service
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/chromium-kiosk.service ${D}${systemd_system_unitdir}/chromium-kiosk.service
}

FILES:${PN} += " \
    ${sysconfdir}/chromium-kiosk/Dockerfile \
    ${bindir}/build-chromium.sh \
    ${systemd_system_unitdir}/chromium-kiosk.service \
"
