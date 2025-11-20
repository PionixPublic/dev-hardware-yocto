FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://tryboot"

# disable the systemd service
SYSTEMD_SERVICE:${PN} = ""

do_install:append() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/tryboot ${D}${sbindir}/

    # remove systemd service
    rm -rf ${D}${systemd_system_unitdir} ${D}/usr/lib/systemd
}

FILES:${PN} += "${sbindir}/tryboot"
