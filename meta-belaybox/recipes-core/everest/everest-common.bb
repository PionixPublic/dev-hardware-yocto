LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
INSANE_SKIP:${PN} = "already-stripped useless-rpaths arch file-rdeps"

SRC_URI = "file://get_remote_modem_info.sh \
          "
PV = "0.1"

do_install() {
    install -d ${D}${bindir}
    install -m 0700 ${UNPACKDIR}/get_remote_modem_info.sh ${D}${bindir}/get_remote_modem_info.sh
}

FILES:${PN} += "${bindir}/get_remote_modem_info.sh \
                "
# Define the package
PACKAGES = "${PN}"
