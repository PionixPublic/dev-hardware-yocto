FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
SRC_URI += "file://10-plc.link \
            file://10-plc.network \
            file://wait-online-any.conf \
"

# installed to /usr/lib/systemd/network so that udev sees it before any
# overlay is mounted; poky's systemd-conf already packages that directory
do_install:append() {
  install -d ${D}${systemd_unitdir}/network/
  install -m 0644 ${WORKDIR}/10-plc.link ${D}${systemd_unitdir}/network/
  install -m 0644 ${WORKDIR}/10-plc.network ${D}${systemd_unitdir}/network/
  install -D -m 0644 ${WORKDIR}/wait-online-any.conf \
    ${D}${systemd_system_unitdir}/systemd-networkd-wait-online.service.d/10-any.conf
}

FILES:${PN} += "${systemd_system_unitdir}/systemd-networkd-wait-online.service.d/"
