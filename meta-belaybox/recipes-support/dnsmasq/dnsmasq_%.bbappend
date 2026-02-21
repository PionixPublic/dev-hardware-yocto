FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://dnsmasq.conf \
                   file://10-wait-for-end0.conf"

do_install:append() {
    install -m 0644 ${WORKDIR}/dnsmasq.conf ${D}${sysconfdir}/dnsmasq.conf
    install -d ${D}${systemd_system_unitdir}/dnsmasq.service.d
    install -m 0644 ${WORKDIR}/10-wait-for-end0.conf ${D}${systemd_system_unitdir}/dnsmasq.service.d/10-wait-for-end0.conf
}

FILES:${PN} += "${systemd_system_unitdir}/dnsmasq.service.d/*"
