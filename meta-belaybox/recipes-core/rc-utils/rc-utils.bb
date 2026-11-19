LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENCE;md5=4c01239e5c3a3d133858dedacdbca63c"

SRC_URI = "git://github.com/raspberrypi/utils.git;branch=master;protocol=https"

inherit cmake

SRCREV = "6b669633d75d22d45d5218e5af6d7a83db52e42c"
PR = "r0"

python () {
    if d.getVar('BELAYBOX_UNSTABLE', True) == "1":
        d.setVar('SRCREV', "${AUTOREV}")
}
python () {
    if d.getVar('BELAYBOX_UNSTABLE', True) == "1":
        d.setVar('PV', "1.0+git${SRCPV}")
}


DEPENDS = "dtc"
RDEPENDS:${PN} += "bash perl"

FILES:${PN} += "${datadir}/bash-completion/*"
