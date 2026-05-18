LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=ff75ee274f4c77abeee3db089083fec7"

SRC_URI = "git://github.com/MatrixOrbital/HTT-Utility.git;branch=master;protocol=ssh \
           file://0001-Fix-install-stage.patch \
           "

inherit cmake

SRCREV = "ffe5feec0f112e639f32ec7dcf93ab814f2883c3"
PR = "r0"

DEPENDS = "libgudev"
RDEPENDS:${PN} += "bash perl"

FILES:${PN} += "${datadir}/bash-completion/*"
