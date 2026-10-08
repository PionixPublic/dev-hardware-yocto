FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://wpa_supplicant.service"

inherit systemd

# Tell Yocto which service file belongs to this recipe
SYSTEMD_SERVICE:${PN} = "wpa_supplicant.service"

# Enable it: the unit is pulled in by the wlan0 device, so it only starts on
# modules that have WiFi
SYSTEMD_AUTO_ENABLE = "enable"

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/wpa_supplicant.service ${D}${systemd_system_unitdir}/wpa_supplicant.service
}
