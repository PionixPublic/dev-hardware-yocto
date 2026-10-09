FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
SRC_URI += "file://10-plc.link"

# installed to /usr/lib/systemd/network so that udev sees it before any
# overlay is mounted; poky's systemd-conf already packages that directory
do_install:append() {
  install -d ${D}${systemd_unitdir}/network/
  install -m 0644 ${WORKDIR}/10-plc.link ${D}${systemd_unitdir}/network/
}
