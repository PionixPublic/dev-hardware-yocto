require image_common.inc

SUMMARY = "EVerest image for PIONIX BelayBox development kit"

CORE_IMAGE_EXTRA_INSTALL += "\
        everest-belaybox \
        chromium-kiosk \
        motd-belaybox \
        docker-moby \
        docker-moby-cli \
        weston \
        weston-init \
        mesa \
        mesa-demos \
        kernel-modules \
        linux-firmware-rpidistro-bcm43455 \
"

IMAGE_HOSTNAME = "belaybox"
SYSTEMD_DEFAULT_TARGET = "graphical.target"
