FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
SRC_URI += "file://99-eth1.network"

do_install:append() {
  install -d ${D}${sysconfdir}/systemd/network/
  install -m 0644 ${UNPACKDIR}/99-eth1.network ${D}${sysconfdir}/systemd/network/
}

FILES:${PN} += " /etc/systemd/network/99-eth1.network "
