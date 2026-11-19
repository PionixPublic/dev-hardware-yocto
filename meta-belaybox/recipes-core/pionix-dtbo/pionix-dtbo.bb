FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = " \
	file://tpm-slb9670-overlay.dts \
	file://mcp2515-can0-spi1-overlay.dts \
"
COMPATIBLE_MACHINE = "raspberrypi4"

inherit devicetree

S = "${UNPACKDIR}"

DEPENDS = " dtc-native linux-raspberrypi "
do_deploy[depends] += "linux-raspberrypi:do_deploy"

do_deploy:append () {
    install -d ${DEPLOYDIR}/overlays
    if [ -d ${DEPLOYDIR}/devicetree ]; then
        cp ${DEPLOYDIR}/devicetree/* ${DEPLOY_DIR_IMAGE}
    fi
}
