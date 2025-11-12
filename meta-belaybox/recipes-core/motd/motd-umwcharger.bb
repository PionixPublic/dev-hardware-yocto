SUMMARY = "Motto of the day"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r0"

SRC_URI += "file://motd"
do_deploy[nostamp] = "1"
do_install[nostamp] = "1"

FILES_${PN} += " motd"


# Welcome greeting
do_install() {
    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/motd ${D}${sysconfdir}/motd
    # tag git version
    export GIT_FOLDER="`dirname ${FILE}`"
    echo Version: `git -C ${GIT_FOLDER} describe --dirty --all --long` >> ${D}${sysconfdir}/motd
    echo Build time: `date` >> ${D}${sysconfdir}/motd
    echo Build system: `uname -a` >> ${D}${sysconfdir}/motd
}
