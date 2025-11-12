FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
	file://qca7000.cfg \
	file://drm.cfg \
	file://rpi4_fake-kms.cfg \
	file://fb-support.cfg \
	file://overlayfs.cfg \
"

PACKAGE_ARCH = "${MACHINE_ARCH}"

