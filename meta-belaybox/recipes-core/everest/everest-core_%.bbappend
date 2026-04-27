FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://tryboot \
            file://config-CB-1.yaml \
            file://config-CB-2.yaml \
            "

# disable the everest.service (as it's provided by everest-belaybox)
SYSTEMD_SERVICE:${PN}:remove = "everest.service"

do_install:append() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/tryboot ${D}${sbindir}/

    # remove everest.service as it's provided by everest-belaybox
    rm -f ${D}${systemd_system_unitdir}/everest.service
    # also remove the directories if they are now empty to avoid search path QA issues
    rmdir --ignore-fail-on-non-empty -p ${D}${systemd_system_unitdir} || true

    install -d ${D}/etc/chargebridge
    install -m 0644 ${WORKDIR}/config-CB-1.yaml ${D}/etc/chargebridge/
    install -m 0644 ${WORKDIR}/config-CB-2.yaml ${D}/etc/chargebridge/
}

FILES:${PN} += "${sbindir}/tryboot \
                /etc/chargebridge/config-CB-1.yaml \
                /etc/chargebridge/config-CB-2.yaml \
                "
