require recipes-core/images/core-image-base.bb

SUMMARY = "EVerest image for PIONIX uMWCar development kit"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

IMAGE_BOOT_FILES:append = "devicetree/tpm-slb9670-overlay.dtbo;overlays/tpm-slb9670.dtbo devicetree/mcp2515-can0-spi1-overlay.dtbo;overlays/mcp2515-can0-spi1.dtbo"
# IMAGE_CLASSES:append = "populate_lic"

inherit boot_image
inherit everest_version_file

include image_common.inc

CORE_IMAGE_EXTRA_INSTALL += "\
        ${COMMON_PACKAGES} \
        openjdk \
        python3-jinja2 \
        python3-pyyaml \
        python3-requests \
        python3-paho-mqtt \
        python3-dbus \
        python3-python-dotenv \
        pionix-control \
        motd-umwcar \
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

# these should not be missing anymore nowadays (python3-iso15118 should have proper dependencies)
# pip3 install environs pydantic aiofile py4j

WKS_FILE = "belay-partition-setup.wks.in"

ENABLE_UART="1"
export BELAYBOX_UPDATE_CHANNEL = "${@'STABLE' if d.getVar('BELAYBOX_UNSTABLE') == '0' else 'UNSTABLE'}"

inherit extrausers
EXTRA_USERS_PARAMS = "\
    usermod -p '\$6\$eIBRUc5cdOdQGN6R\$fi.NN7ra6MIPycWlEp/u6Ys1TwDZRhe98rvG1MljmQolByGlgnnuywtsNymOaUhYqJH8NJuLiZXvccNQJW61F0' root; \
    "

# Function to set hostname
set_custom_hostname_car() {
    echo "umwcar" > ${IMAGE_ROOTFS}/etc/hostname
}

# Add the function to the post-processing commands
ROOTFS_POSTPROCESS_COMMAND += "set_custom_hostname_car; "
