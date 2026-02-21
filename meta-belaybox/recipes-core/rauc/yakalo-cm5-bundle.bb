include yakalo-bundle.inc

RAUC_BUNDLE_COMPATIBLE = "Belaybox-CM5"

RAUC_SLOT_rootfs = "yakalo-cm5-image"
RAUC_SLOT_rootfs[fstype] = "ext4"

RAUC_SLOT_boot = "yakalo-cm5-image"
RAUC_SLOT_boot[fstype] = "tar.xz"
RAUC_SLOT_boot[file] = "boot.tar.xz"
