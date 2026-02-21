include yakalo-image.inc

IMAGE_BOOT_FILES:append = " devicetree/tpm-slb9670-overlay.dtbo;overlays/tpm-slb9670.dtbo devicetree/mcp2515-can0-spi1-overlay.dtbo;overlays/mcp2515-can0-spi1.dtbo"

CORE_IMAGE_EXTRA_INSTALL += " \
    linux-firmware-rpidistro-bcm43455 \
"
