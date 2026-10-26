#!/bin/bash

# /boot is checked by systemd-fsck before it is mounted (fstab pass 1). Do not
# fsck it here, it is mounted and the kernel would keep a stale view of a repair.
make_boot_persistent() {
    mount -o remount,rw /boot
    cp /boot/tryboot.txt /boot/config.txt 2>>/dev/null
    rm -f /boot/tryboot.txt
    mount -o remount,ro /boot
}

# Bootname of the slot we actually booted, from the kernel's root=. Do not use
# the bootloader backend (get-current/get-primary report the intended slot) or
# the hash ordered RAUC_SLOT_*_<n> indices to find it.
booted_bootname() {
    local arg root= n class device
    for arg in $(cat /proc/cmdline); do
        case "$arg" in
            root=*) root=${arg#root=} ;;
        esac
    done
    [ -n "$root" ] || return 1
    root=$(readlink -f "$root" 2>/dev/null || echo "$root")

    # match root= against the rootfs slots RAUC knows about
    for n in $RAUC_SLOTS; do
        eval "class=\$RAUC_SLOT_CLASS_$n device=\$RAUC_SLOT_DEVICE_$n"
        if [ "$class" = "rootfs" ] && [ "$device" = "$root" ]; then
            eval "echo \$RAUC_SLOT_BOOTNAME_$n"
            return 0
        fi
    done

    # fixed partition layout, see system.conf
    case "$root" in
        /dev/mmcblk0p5) echo system0 ;;
        /dev/mmcblk0p6) echo system1 ;;
        *) return 1 ;;
    esac
}

if modprobe dm-verity; then
    source <(rauc status --output-format=shell)
    booted=$(booted_bootname)
    # tryboot.txt selects the slot to try with os_prefix=/<bootname>/
    if [ -n "$booted" ] && grep -sqxF "os_prefix=/$booted/" /boot/tryboot.txt; then
        make_boot_persistent
    else
        # We couldn't boot the slot tryboot.txt names, just delete the file
        if [ -f /boot/tryboot.txt ]; then
            echo "Booted slot '${booted:-unknown}' is not the one in tryboot.txt, dropping it" >&2
            mount -o remount,rw /boot
            rm -f /boot/tryboot.txt
            mount -o remount,ro /boot
        fi
    fi
fi
