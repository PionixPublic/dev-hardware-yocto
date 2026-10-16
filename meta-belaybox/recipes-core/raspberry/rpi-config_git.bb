DESCRIPTION = "Commented config.txt file for the Raspberry Pi. \
               The Raspberry Pi config.txt file is read by the GPU before \
               the ARM core is initialised. It can be used to set various \
               system configuration parameters."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

COMPATIBLE_MACHINE = "^rpi$"

SRC_URI = "file://config.txt "
FILES:${PN} = "config.txt"

S = "${WORKDIR}"

PR = "r6"

INHIBIT_DEFAULT_DEPS = "1"

# Wi-Fi antenna of the CM4: internal (PCB), external (U.FL) or none (Wi-Fi off)
WIFI_ANTENNA ??= "external"

inherit deploy nopackages

do_deploy() {
    install -d ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}
    CONFIG=${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt

    cp ${S}/config.txt $CONFIG

    case "${WIFI_ANTENNA}" in
        internal) ANTENNA_CONFIG="dtparam=ant1" ;;
        external) ANTENNA_CONFIG="dtparam=ant2" ;;
        none)     ANTENNA_CONFIG="dtoverlay=disable-wifi" ;;
        *) bbfatal "Invalid value for WIFI_ANTENNA [${WIFI_ANTENNA}]. The value for WIFI_ANTENNA can be internal, external or none." ;;
    esac
    sed -i "s/^@WIFI_ANTENNA_CONFIG@$/$ANTENNA_CONFIG/" $CONFIG
}

do_deploy:append() {
    if grep -q -E '^.{80}.$' ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt; then
        bbwarn "config.txt contains lines longer than 80 characters, this is not supported"
    fi
}

addtask deploy before do_build after do_install
do_deploy[dirs] += "${DEPLOYDIR}/${BOOTFILES_DIR_NAME}"
do_deploy[vardeps] += "WIFI_ANTENNA"

PACKAGE_ARCH = "${MACHINE_ARCH}"
