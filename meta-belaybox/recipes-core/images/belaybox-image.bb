require image_common.inc

SUMMARY = "EVerest image for PIONIX BelayBox development kit"

CORE_IMAGE_EXTRA_INSTALL += "\
        ${DISPLAY_PACKAGES} \
        everest-belaybox \
        motd-belaybox \
"

IMAGE_HOSTNAME = "belaybox"
