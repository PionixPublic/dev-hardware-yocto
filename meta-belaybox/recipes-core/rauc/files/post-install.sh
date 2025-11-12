#!/bin/bash
set -e
echo "Post install processing"
env

# correct rootfs - we need to copy the kernel and then delete /boot folder from the installed rootfs
if [[ "$RAUC_CURRENT_BOOTNAME" == "$RAUC_SLOT_DEVICE_1" ]]; then
    RAUC_SLOT_UPDATED=$RAUC_SLOT_DEVICE_3
elif [[ "$RAUC_CURRENT_BOOTNAME" == "$RAUC_SLOT_DEVICE_3" ]]; then
    RAUC_SLOT_UPDATED=$RAUC_SLOT_DEVICE_1
else
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
