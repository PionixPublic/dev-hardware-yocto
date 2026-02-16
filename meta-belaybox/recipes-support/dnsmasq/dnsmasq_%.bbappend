FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://dnsmasq.conf"

do_install:append() {
    install -m 0644 ${WORKDIR}/dnsmasq.conf ${D}${sysconfdir}/dnsmasq.conf
}
