SUMMARY = "Mount point for the persistent /etc and /var overlay partition"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r1"

# The overlays themselves are mounted by the preinit generated from
# files/belaybox-preinit.sh.in (IMAGE_FEATURES overlayfs-etc, see
# recipes-core/images/image_common.inc) before systemd starts.

S = "${WORKDIR}"

do_install() {
    install -d -m 0755 ${D}/overlay
}

FILES:${PN} += "/overlay"
ALLOW_EMPTY:${PN} = "1"

PACKAGES = "${PN}"
