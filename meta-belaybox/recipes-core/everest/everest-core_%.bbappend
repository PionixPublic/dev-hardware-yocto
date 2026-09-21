FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://tryboot"

# disable the systemd services shipped by everest-core; belaybox provides its
# own everest.service via the everest-belaybox recipe and does not use the
# chargebridge application
SYSTEMD_SERVICE:${PN} = ""
SYSTEMD_SERVICE:chargebridge = ""

do_install:append() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/tryboot ${D}${sbindir}/

    # remove systemd service
    rm -rf ${D}${systemd_system_unitdir} ${D}/usr/lib/systemd
}

FILES:${PN} += "${sbindir}/tryboot"
