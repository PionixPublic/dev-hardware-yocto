FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

FILES:${PN} += " /var/everest-logs "

do_install:append() {
  install -d -m 0755 ${D}/var/everest-logs
  install -d -m 0755 ${D}/var/everest-logs/session
}
