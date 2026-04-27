LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
INSANE_SKIP:${PN} = "already-stripped useless-rpaths arch file-rdeps"

SRC_URI = "file://config-belaybox-rpi-pwm.yaml \
           file://config-belaybox-rpi-iso.yaml \
           file://config-belaybox-pwm.yaml \
           file://config-belaybox-iso.yaml \
           file://config-kilowatt-k2.yaml \
           file://config-belaybox-pnc.yaml \
           file://ocpp16-pnc-config.json \
           file://everest.service \
           file://everest-rpi.service \
           file://config-sil-rauc.yaml \
           file://config-CB-SAT-DUAL-AC.yaml \
           "
PV = "0.1"

export BELAYBOX_UNSTABLE

do_install() {
    install -d ${D}${systemd_system_unitdir}
    install -d ${D}${sysconfdir}/everest
    install -m 0644 ${WORKDIR}/everest.service ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/everest-rpi.service ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/config-belaybox-pwm.yaml ${D}${sysconfdir}/everest/
    install -m 0644 ${WORKDIR}/config-belaybox-iso.yaml ${D}${sysconfdir}/everest/
    install -m 0644 ${WORKDIR}/config-belaybox-rpi-pwm.yaml ${D}${sysconfdir}/everest/
    install -m 0644 ${WORKDIR}/config-belaybox-rpi-iso.yaml ${D}${sysconfdir}/everest/
    install -m 0644 ${WORKDIR}/config-kilowatt-k2.yaml ${D}${sysconfdir}/everest/
    install -m 0644 ${WORKDIR}/config-belaybox-pnc.yaml ${D}${sysconfdir}/everest/
    install -m 0644 ${WORKDIR}/ocpp16-pnc-config.json ${D}${sysconfdir}/everest/
    ln -s ${sysconfdir}/everest/config-CB-SAT-DUAL-AC.yaml ${D}${sysconfdir}/everest/everest.yaml
    install -m 0644 ${WORKDIR}/config-CB-SAT-DUAL-AC.yaml ${D}${sysconfdir}/everest/
    if [ "$BELAYBOX_UNSTABLE" == "1" ]
    then
        install -d ${D}${bindir}
        install -m 0644 ${WORKDIR}/config-sil-rauc.yaml ${D}${sysconfdir}/everest/config-sil-rauc.yaml
    fi
}

FILES:${PN} += "${datadir}/everest/* \
                ${sysconfdir}/everest/* \
                ${systemd_system_unitdir}/everest.service \
                ${systemd_system_unitdir}/everest-rpi.service \
                "
# Define the package
PACKAGES = "${PN}"

inherit systemd
SYSTEMD_AUTO_ENABLE:${PN} = "enable"
SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE:${PN} += "everest.service"
SYSTEMD_SERVICE:${PN} += "everest-rpi.service"
