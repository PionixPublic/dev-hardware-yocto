#!/bin/bash

make_boot_persistent() {
    dosfsck -w -r -a -V -t /dev/mmcblk0p1
    mount -o remount,rw /boot
    cp /boot/tryboot.txt /boot/config.txt 2>>/dev/null
    rm -f /boot/tryboot.txt
    mount -o remount,ro /boot
}

if modprobe dm-verity; then 
    source <(rauc status --output-format=shell)
    if { [ "$RAUC_SLOT_STATE_3" = "booted" ] && grep -qF "$RAUC_SLOT_BOOTNAME_3" /boot/tryboot.txt; } || \
       { [ "$RAUC_SLOT_STATE_1" = "booted" ] && grep -qF "$RAUC_SLOT_BOOTNAME_1" /boot/tryboot.txt; }; then
        make_boot_persistent
    else
        # We couldn't boot that partition, just check the partition and delete the file
        dosfsck -w -r -a -V -t /dev/mmcblk0p1
        rm -f /boot/tryboot.txt 2>>/dev/null
    fi
fi
