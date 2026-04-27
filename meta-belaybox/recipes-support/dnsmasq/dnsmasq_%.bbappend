FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SYSTEMD_AUTO_ENABLE = "enable"

SRC_URI:append = " file://dnsmasq.conf \
                   file://10-wait-for-usb-eth.conf"

do_install:append() {
    install -m 0644 ${WORKDIR}/dnsmasq.conf ${D}${sysconfdir}/dnsmasq.conf
    install -d ${D}${systemd_system_unitdir}/dnsmasq.service.d
    install -m 0644 ${WORKDIR}/10-wait-for-usb-eth.conf ${D}${systemd_system_unitdir}/dnsmasq.service.d/10-wait-for-usb-eth.conf
}

FILES:${PN} += "${systemd_system_unitdir}/dnsmasq.service.d/*"
