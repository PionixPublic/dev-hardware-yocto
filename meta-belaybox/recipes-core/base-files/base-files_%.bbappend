FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
  file://enable-utf8.sh \
  file://can0.network \
  file://99-wlan0.network \
  file://99-end0.network \
  file://10-enu1u2.network \
  file://10-enu1u3.network \
"

do_install:append() {
  install -d -m 0755 ${D}${systemd_unitdir}/network/
  install -m 0644 -D ${WORKDIR}/enable-utf8.sh ${D}${sysconfdir}/profile.d/enable-utf8.sh
  install -m 0644 -D ${WORKDIR}/can0.network ${D}${systemd_unitdir}/network/
  install -m 0644 -D ${WORKDIR}/99-wlan0.network ${D}${systemd_unitdir}/network/
  install -m 0644 -D ${WORKDIR}/99-end0.network ${D}${systemd_unitdir}/network/
  install -m 0644 -D ${WORKDIR}/10-enu1u2.network ${D}${systemd_unitdir}/network/
  install -m 0644 -D ${WORKDIR}/10-enu1u3.network ${D}${systemd_unitdir}/network/
}
