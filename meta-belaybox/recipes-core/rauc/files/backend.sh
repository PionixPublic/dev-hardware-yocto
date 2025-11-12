#!/bin/bash
# Will be called with the following parameters:
# get-primary: output active slot bootname, return 0 on success, !=0 on error
# set-primary <slot.bootname> -> returns 0 on success, !=0 on error
# get-state <slot.bootname> -> return boot state of specific slot, returns good/bad on stdout, returns 0 on success, !0 on error
# set-state <slot.bootname> <state> (good: last boot was successful, bad: last boot failed). return 0 on success, !0 on error

create_boot() {
  mkdir -p $boot/$2/
  # copy boot files
  cp -r /$1/* $boot/$2/
}

get_mount_and_make_writable() {
  if mount | grep -q "$1"; then
    mount_path=$(mount | grep "$1" | awk '{print $3}')
  else
    mount_path=`mktemp -d`
    mount $1 $mount_path
  fi
  mount -o remount,rw $mount_path
  echo $mount_path
}

case $1 in

  "get-current")
    if [ -f "/factory_data/rauc/primary" ]; then
       cat /factory_data/rauc/primary
       exit 0
    fi
    exit 2
    ;;

  "get-primary")
    if [ -f "/factory_data/rauc/primary" ]; then
       cat /factory_data/rauc/primary
       exit 0
    fi
    exit 2
    ;;

  "set-primary")
    boot=$(get_mount_and_make_writable "/dev/mmcblk0p1")
    boot_a=$(get_mount_and_make_writable "/dev/mmcblk0p2")
    boot_b=$(get_mount_and_make_writable "/dev/mmcblk0p3")

    rm -f $boot/tryboot.txt
    if [ $2 == "system1" ]; then
        if [ ! -d "$boot/system0" ]; then
          # make sure we have a system to return to
          create_boot "$boot_a" "system0"
          cp "$boot_a/start4cd.elf" "$boot/0strt4cd.elf"
          cp "$boot_a/fixup4cd.dat" "$boot/0fxup4cd.dat"
          sed -i 's/mmcblk0p6/mmcblk0p5/g' "$boot/system0/cmdline.txt"
        fi
        # now create the new boot env
        create_boot "$boot_b" $2
        cp "$boot_b/start4cd.elf" "$boot/1strt4cd.elf"
        cp "$boot_b/fixup4cd.dat" "$boot/1fxup4cd.dat"
        cp "$boot_b/config.txt" "$boot/tryboot_tmp.txt"
        sed -i 's/mmcblk0p5/mmcblk0p6/g' "$boot/system1/cmdline.txt"
        # the overlay
        rm -rf "$boot/overlays"
        cp -r "$boot_b/overlays" "$boot"
    else
        if [ ! -d "$boot/system1" ]; then
          # make sure we have a system to return to
          create_boot "$boot_b" "system1"
          cp "$boot_b/start4cd.elf" "$boot/1strt4cd.elf"
          cp "$boot_b/fixup4cd.dat" "$boot/1fxup4cd.dat"
          sed -i 's/mmcblk0p5/mmcblk0p6/g' "$boot/system1/cmdline.txt"
        fi
        # now create the new boot env
        create_boot "$boot_b" $2
        cp "$boot_a/start4cd.elf" "$boot/0strt4cd.elf"
        cp "$boot_a/fixup4cd.dat" "$boot/0fxup4cd.dat"
        cp "$boot_a/config.txt" "$boot/tryboot_tmp.txt"
        sed -i 's/mmcblk0p6/mmcblk0p5/g' "$boot/system0/cmdline.txt"
        # the overlay
        rm -rf "$boot/overlays"
        cp -r "$boot_a/overlays" "$boot"
    fi

    # start preparing the tryboot.txt
    echo -e "\n" >> "$boot/tryboot_tmp.txt"
    echo "[all]" >> "$boot/tryboot_tmp.txt"
    echo "gpu_mem=16" >> "$boot/tryboot_tmp.txt"

    # we customize tryboot.txt to boot the new system
    if [ $2 == "system1" ]; then
        echo "start_file=1strt4cd.elf" >> "$boot/tryboot_tmp.txt"
        echo "fixup_file=1fxup4cd.dat" >> "$boot/tryboot_tmp.txt"
    else
        echo "start_file=0strt4cd.elf" >> "$boot/tryboot_tmp.txt"
        echo "fixup_file=0fxup4cd.dat" >> "$boot/tryboot_tmp.txt"
    fi
    echo "os_prefix=/$2/" >> "$boot/tryboot_tmp.txt"
    mv "$boot/tryboot_tmp.txt" "$boot/tryboot.txt"

    umount "/dev/mmcblk0p1"
    umount "/dev/mmcblk0p2"
    umount "/dev/mmcblk0p3"
    
    # now mark for rauc which system should boot
    mount -o remount,rw /factory_data
    mkdir -p /factory_data/rauc
    rm /factory_data/rauc/primary
    echo $2>/factory_data/rauc/primary
    mount -o remount,ro /factory_data
    exit 0
    ;;

  "get-state")
    if [ -f "/factory_data/rauc/$2" ]; then
       cat /factory_data/rauc/$2
       exit 0
    fi
    exit 3
    ;;

  "set-state")
    mount -o remount,rw /factory_data
    echo $3>/factory_data/rauc/$2
    mount -o remount,ro /factory_data
    exit 0
    ;;

  none | *)
    echo Invalid argument.
    exit 1
    ;;
esac
