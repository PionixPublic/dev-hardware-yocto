#!/bin/bash

# /boot is checked by systemd-fsck before it is mounted (fstab pass 1). Do not
# fsck it here, it is mounted and the kernel would keep a stale view of a repair.
make_boot_persistent() {
    mount -o remount,rw /boot
    cp /boot/tryboot.txt /boot/config.txt 2>>/dev/null
    rm -f /boot/tryboot.txt
    mount -o remount,ro /boot
}

if modprobe dm-verity; then 
    source <(rauc status --output-format=shell)
    if { [ "$RAUC_SLOT_STATE_3" = "booted" ] && grep -sqF "$RAUC_SLOT_BOOTNAME_3" /boot/tryboot.txt; } || \
       { [ "$RAUC_SLOT_STATE_1" = "booted" ] && grep -sqF "$RAUC_SLOT_BOOTNAME_1" /boot/tryboot.txt; }; then
        make_boot_persistent
    else
        # We couldn't boot that partition, just delete the file
        if [ -f /boot/tryboot.txt ]; then
            mount -o remount,rw /boot
            rm -f /boot/tryboot.txt
            mount -o remount,ro /boot
        fi
    fi
fi
