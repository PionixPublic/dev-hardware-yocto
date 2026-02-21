FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

RAUC_KEYRING_FILE := "pionix.cert.pem"

RAUC_COMPATIBLE ?= "Belaybox"
RAUC_COMPATIBLE:raspberrypi5 = "Belaybox-CM5"
RAUC_COMPATIBLE:raspberrypi-cm5-io-board = "Belaybox-CM5"

do_install:append() {
    sed -i "s/compatible=Belaybox/compatible=${RAUC_COMPATIBLE}/g" ${D}${sysconfdir}/rauc/system.conf
}