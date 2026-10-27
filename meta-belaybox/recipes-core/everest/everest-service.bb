SUMMARY = "EVerest systemd unit, common to all hardware targets"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# everest.service is the same on every image, so the RAUC commit gate, the
# rauc-commit ordering and the cloud-connector config only know one name.
# Each image pulls in exactly one everest-service-<target> package with the
# target's drop-in.
SRC_URI = "file://everest.service \
           file://10-belaybox.conf \
           "

S = "${WORKDIR}"
PR = "r0"

inherit systemd

do_install() {
    install -d ${D}${systemd_system_unitdir}/everest.service.d
    install -m 0644 ${WORKDIR}/everest.service ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/10-belaybox.conf ${D}${systemd_system_unitdir}/everest.service.d/

    install -d ${D}${sysconfdir}/everest
    ln -s -r ${D}/usr ${D}${sysconfdir}/everest/selected-everest
}

PACKAGES = "${PN}-belaybox ${PN}"

FILES:${PN} = "${systemd_system_unitdir}/everest.service \
               ${sysconfdir}/everest/selected-everest \
               "
RDEPENDS:${PN} = "everest-core mosquitto"

FILES:${PN}-belaybox = "${systemd_system_unitdir}/everest.service.d/10-belaybox.conf"
RDEPENDS:${PN}-belaybox = "${PN}"
ALLOW_EMPTY:${PN}-belaybox = "0"

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"
SYSTEMD_SERVICE:${PN} = "everest.service"
