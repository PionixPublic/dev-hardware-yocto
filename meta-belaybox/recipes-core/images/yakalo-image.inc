require recipes-core/images/core-image-base.bb

SUMMARY = "EVerest image for PIONIX BelayBox development kit"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

# IMAGE_CLASSES:append = "populate_lic"

inherit boot_image
inherit everest_version_file

include image_common.inc

CORE_IMAGE_EXTRA_INSTALL += "\
        ${COMMON_PACKAGES} \
        everest-belaybox \
        chromium-kiosk \
        next-display-app \
        motd-belaybox \
        docker-moby \
        docker-moby-cli \
        weston \
        weston-init \
        mesa \
        kernel-modules \
"

PACKAGE_EXCLUDE += " \
        dlt-system \
        dlt \
"

CORE_IMAGE_EXTRA_INSTALL += "${@' everest-admin-panel ' if d.getVar('BELAYBOX_UNSTABLE') == '1' else ''}"
CORE_IMAGE_EXTRA_INSTALL += "${@' everest-node-red-flows ' if d.getVar('BELAYBOX_UNSTABLE') == '1' else ''}"

COMPATIBLE_MACHINE = "^rpi$"

DISABLE_SPLASH = "1"
DISABLE_RPI_BOOT_LOGO = "1"

IMAGE_INSTALL:append = " psplash"
IMAGE_FEATURES += " splash "
COPY_LIC_MANIFEST = "1"

WKS_FILE = "belay-partition-setup.wks.in"

ENABLE_UART="1"
export BELAYBOX_UPDATE_CHANNEL = "${@'STABLE' if d.getVar('BELAYBOX_UNSTABLE') == '0' else 'UNSTABLE'}"

inherit extrausers
EXTRA_USERS_PARAMS = "\
    usermod -p '\$6\$eIBRUc5cdOdQGN6R\$fi.NN7ra6MIPycWlEp/u6Ys1TwDZRhe98rvG1MljmQolByGlgnnuywtsNymOaUhYqJH8NJuLiZXvccNQJW61F0' root; \
    "

# Function to set hostname
set_custom_hostname_belaybox() {
    echo "${HOSTNAME_BELAYBOX}" > ${IMAGE_ROOTFS}/etc/hostname
}

HOSTNAME_BELAYBOX ?= "belaybox"

# Add the function to the post-processing commands
ROOTFS_POSTPROCESS_COMMAND += "set_custom_hostname_belaybox; "
SYSTEMD_DEFAULT_TARGET = "graphical.target"
