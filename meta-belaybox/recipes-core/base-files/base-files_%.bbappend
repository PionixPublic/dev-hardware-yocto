FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
  file://enable-utf8.sh \
  file://can0.network \
  file://99-wlan0.network \
  file://root-bashrc \
"

do_install:append() {
  install -d -m 0755 ${D}${systemd_unitdir}/network/
  install -m 0644 -D ${UNPACKDIR}/enable-utf8.sh ${D}${sysconfdir}/profile.d/enable-utf8.sh
  install -m 0644 -D ${UNPACKDIR}/can0.network ${D}${systemd_unitdir}/network/
  install -m 0644 -D ${UNPACKDIR}/99-wlan0.network ${D}${systemd_unitdir}/network/
  # root's interactive shell setup; ~/.profile (from rauc-backend) sources it
  install -m 0644 -D ${UNPACKDIR}/root-bashrc ${D}${ROOT_HOME}/.bashrc
}

