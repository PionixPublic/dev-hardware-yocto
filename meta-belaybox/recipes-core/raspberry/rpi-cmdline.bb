SUMMARY = "cmdline.txt file used to boot the kernel on a Raspberry Pi device"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

COMPATIBLE_MACHINE = "^rpi$"
INHIBIT_DEFAULT_DEPS = "1"
inherit deploy nopackages

do_compile() {
    # ro
    #echo "console=tty3 root=/dev/mmcblk0p2 rootfstype=ext4 fsck.repair=yes rootwait noswap fastboot ro quiet vt.global_cursor_default=0" > "${WORKDIR}/cmdline.txt"
    # rw
    #echo "console=serial0,115200 console=tty3 root=/dev/mmcblk0p5 rootfstype=ext4 fsck.repair=yes rootwait noswap fastboot quiet vt.global_cursor_default=0" > "${WORKDIR}/cmdline.txt"
    echo "console=tty3 root=/dev/mmcblk0p5 rootfstype=ext4 fsck.repair=yes rootwait noswap fastboot quiet vt.global_cursor_default=0" > "${WORKDIR}/cmdline.txt"
}

do_deploy() {
    install -d "${DEPLOYDIR}/${BOOTFILES_DIR_NAME}"
    install -m 0644 "${WORKDIR}/cmdline.txt" "${DEPLOYDIR}/${BOOTFILES_DIR_NAME}"
}

addtask deploy before do_build after do_install
do_deploy[dirs] += "${DEPLOYDIR}/${BOOTFILES_DIR_NAME}"

PACKAGE_ARCH = "${MACHINE_ARCH}"
