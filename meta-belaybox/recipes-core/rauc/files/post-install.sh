#!/bin/bash
set -e
echo "Post install processing"
env

# Which partition was updated?
#
# Do not derive it from RAUC_CURRENT_BOOTNAME and fixed slot numbers: the
# RAUC_SLOT_*_<n> numbering is hash ordered, and RAUC_CURRENT_BOOTNAME is the
# kernel's root= device (e.g. /dev/mmcblk0p5) on older RAUC versions but a
# bootname (e.g. system0) on RAUC >= 1.15, which asks the bootloader backend
# for it. Use the rootfs slot RAUC is installing to (RAUC_TARGET_SLOTS) and only
# use the booted slot to make sure we never touch it.

# root= of the running kernel, resolved to a real device node
booted_root=
for arg in $(cat /proc/cmdline); do
    case "$arg" in
        root=*) booted_root=${arg#root=} ;;
    esac
done
[ -n "$booted_root" ] && booted_root=$(readlink -f "$booted_root" 2>/dev/null || echo "$booted_root")

RAUC_SLOT_UPDATED=
for n in $RAUC_TARGET_SLOTS; do
    eval "class=\$RAUC_SLOT_CLASS_$n device=\$RAUC_SLOT_DEVICE_$n bootname=\$RAUC_SLOT_BOOTNAME_$n"
    [ "$class" = "rootfs" ] || continue

    if [ -n "$RAUC_SLOT_UPDATED" ]; then
        echo "More than one rootfs slot is being updated, can't identify the partition to post process ..."
        exit 1
    fi

    if [ "$device" = "$booted_root" ] \
        || [ "$device" = "$RAUC_CURRENT_BOOTNAME" ] \
        || { [ -n "$bootname" ] && [ "$bootname" = "$RAUC_CURRENT_BOOTNAME" ]; }; then
        echo "Updated slot $device is the booted one, refusing to post process it ..."
        exit 1
    fi

    RAUC_SLOT_UPDATED=$device
done

if [ -z "$RAUC_SLOT_UPDATED" ]; then
    echo "Can't identify which is the boot partition and what partition was updated ..."
    # Execute default action here
    exit 1
fi

echo "Mount $RAUC_SLOT_UPDATED to post processing"
ROOTFSNEW=`mktemp -d`
mount $RAUC_SLOT_UPDATED $ROOTFSNEW
echo "Delete the contents of boot folder from the new rootfs since it shadows the actual boot when booted"
rm -rf $ROOTFSNEW/boot/*
umount $RAUC_SLOT_UPDATED

# check if we need to update fw files on boot partition as well. only write if they really changed!

# notify for system reboot / installation finished some how
echo "Mount you can boot the new updated partition by executing at command line: reboot '0 tryboot'"
exit 0
