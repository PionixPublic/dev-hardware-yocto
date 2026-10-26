# Shared by all RAUC bundle recipes in this layer.

# Bundle hook: runs on the installing (old) system, see bundle-hook.sh
SRC_URI += "file://bundle-hook.sh"
RAUC_BUNDLE_HOOKS[file] = "bundle-hook.sh"
RAUC_SLOT_rootfs[hooks] = "post-install"
