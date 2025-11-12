FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://tryboot"

do_install:append() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/tryboot ${D}${sbindir}/
}

FILES:${PN} += "${sbindir}/tryboot"
