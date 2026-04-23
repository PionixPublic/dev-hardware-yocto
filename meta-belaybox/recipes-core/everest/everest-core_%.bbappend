FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://tryboot"

# disable the everest.service (as it's provided by everest-belaybox)
SYSTEMD_SERVICE:${PN}:remove = "everest.service"

do_install:append() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/tryboot ${D}${sbindir}/

    # remove everest.service as it's provided by everest-belaybox
    rm -f ${D}${systemd_system_unitdir}/everest.service
    # also remove the directories if they are now empty to avoid search path QA issues
    rmdir --ignore-fail-on-non-empty -p ${D}${systemd_system_unitdir} || true
}

FILES:${PN} += "${sbindir}/tryboot"
