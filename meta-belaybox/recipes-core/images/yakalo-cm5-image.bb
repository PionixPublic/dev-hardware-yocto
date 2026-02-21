include yakalo-image.inc

SUMMARY = "EVerest image for PIONIX BelayBox CM5 development kit"

# CM5/RPi5 specific overlays (if any)
# For now, we assume standard ones or those picked up by meta-raspberrypi
# IMAGE_BOOT_FILES:append = " ..."

CORE_IMAGE_EXTRA_INSTALL += " \
    linux-firmware-rpidistro-bcm43455 \
    linux-firmware-rpidistro-bcm43456 \
"

HOSTNAME_BELAYBOX = "belaybox-cm5"

COMPATIBLE_MACHINE = "raspberrypi5|raspberrypi-cm5-io-board"
