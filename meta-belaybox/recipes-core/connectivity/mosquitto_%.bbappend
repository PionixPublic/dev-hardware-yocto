FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://mosquitto.conf \
                   file://mosquitto.service"

inherit systemd

do_install:append() {
    install -m 0644 ${WORKDIR}/mosquitto.conf ${D}${sysconfdir}/mosquitto
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/mosquitto.service ${D}${systemd_system_unitdir}/mosquitto.service
}
