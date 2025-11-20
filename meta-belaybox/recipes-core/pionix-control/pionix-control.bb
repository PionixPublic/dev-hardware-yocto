LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git@github.com/PionixPublic/pionix-control.git;branch=main;protocol=https \
           file://charger_info.yaml \
           file://everest_configs.yaml \
           file://custom_configs \
           file://setup.yaml \
           file://everest-setup.service \
           "

S = "${WORKDIR}/git"

SRCREV = "c9f864a50c63d6202e03be99c1dcf9ef1a37cd69"
PR = "r0"

DEPENDS += " \
    python3-jinja2 \
    python3-pyyaml \
    python3-requests \
    python3-paho-mqtt \
    python3-dbus \
    python3-python-dotenv \
    python3-pyyaml \
"

RDEPENDS:${PN} = " \
    python3-jinja2 \
    python3-pyyaml \
    python3-requests \
    python3-paho-mqtt \
    python3-dbus \
    python3-python-dotenv \
"

INSANE_SKIP:${PN} = "already-stripped useless-rpaths arch file-rdeps"

inherit setuptools3
inherit systemd

SYSTEMD_AUTO_ENABLE:${PN} = "enable"
SYSTEMD_PACKAGES = "${PN}"

SYSTEMD_SERVICE:${PN} += "pionix-control.service"
SYSTEMD_SERVICE:${PN} += "everest-control.service"
SYSTEMD_SERVICE:${PN} += "everest-setup.service"

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -d ${D}${sysconfdir}
    install -d ${D}${sysconfdir}/everest
    install -d ${D}${sysconfdir}/everest/custom_configs
    install -m 0644 ${S}/pionix-control.service ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/everest-control.service ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/everest-setup.service ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/charger_info.yaml ${D}${sysconfdir}/everest
    install -m 0644 ${WORKDIR}/everest_configs.yaml ${D}${sysconfdir}/everest
    install -m 0644 ${WORKDIR}/custom_configs/* ${D}${sysconfdir}/everest/custom_configs/
    install -m 0644 ${WORKDIR}/setup.yaml ${D}${sysconfdir}/everest
    ln -s -r ${D}/usr ${D}/etc/everest/selected-everest
}

FILES:${PN} += "${systemd_system_unitdir}/pionix-control.service \
                ${systemd_system_unitdir}/everest-control.service \
                ${systemd_system_unitdir}/everest-setup.service \
                ${sysconfdir}/everest/* \
               "
