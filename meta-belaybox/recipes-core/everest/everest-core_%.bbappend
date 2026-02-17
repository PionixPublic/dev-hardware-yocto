FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://tryboot"

# disable the everest.service (as it's provided by everest-belaybox)
# but keep chargebridge.service
SYSTEMD_SERVICE:${PN} = "chargebridge.service"

do_install:append() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/tryboot ${D}${sbindir}/

    # remove everest systemd service to avoid conflict with everest-belaybox
    rm -f ${D}${systemd_system_unitdir}/everest.service
}

FILES:${PN} += "${sbindir}/tryboot"
