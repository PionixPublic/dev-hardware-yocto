#!/bin/bash

if [ -e "/overlay/OVERLAY_CLEAN" ]; then
    echo "Cleaning flag detected, delete the overlay folders and reinitialize the file structure ..."
    rm -rf /overlay/etc_work
    rm -rf /overlay/etc_upper
    rm -rf /overlay/var_work
    rm -rf /overlay/var_upper
    rm -rf /overlay/logs
    # Remove the cleaning flag to prevent reboot loop and automatically reboot again if successful
    echo "Deleting OVERLAY_CLEAN and rebooting system to complete overlay reset..."
    rm -f /overlay/OVERLAY_CLEAN && reboot
fi

if [ -d "/overlay/etc_work" ]; then
    echo "Overlay /etc file structure already exists, skipping creation."
else
    echo "Create overlay /etc file structure ..."
    mkdir -p -m 0755 /overlay/etc_work
    mkdir -p -m 0755 /overlay/etc_upper
fi

if [ -d "/overlay/var_work" ]; then
    echo "Overlay /var file structure already exists, skipping creation."
else
    echo "Create overlay /var file structure ..."
    mkdir -p -m 0755 /overlay/var_work
    mkdir -p -m 0755 /overlay/var_upper
    mkdir -p -m 0755 /overlay/logs
fi
if [ -d "/overlay/logs" ]; then
    echo "Overlay /log file structure already exists, skipping creation."
else
    echo "Create overlay /log file structure ..."
    mkdir -p -m 0755 /overlay/logs
fi

if [ -f "/var/log" ]; then
    echo "Fix /var/log file structure, for some reason is wrong after a software update!!!"
    rm /var/log
fi
echo "Overlay file structure initialization complete."


echo "Mount the overlay."
mount -t overlay overlay -o lowerdir=/etc,upperdir=/overlay/etc_upper,workdir=/overlay/etc_work /etc
mount -t overlay overlay -o lowerdir=/var,upperdir=/overlay/var_upper,workdir=/overlay/var_work /var
echo "Done."

# on some machines (observed on a rpi based BelayBox) this directory is missing
# creating it every time should not hurt
mkdir -p -m 0755 /var/volatile/log
