#!/bin/bash

if ! [[ $1 =~ ^sd[A-Za-z][0-9]+$ ]]; then
    echo "Not a plugged in partition, ignoring"
    exit 0
fi

LOG_FILE="/var/autoinstall.log"
DEVICE="/dev/$1"

touch $LOG_FILE

echo "################################################" >> "$LOG_FILE"
TIMESTAMP=$(date +"%Y-%m-%d %T")
echo "[$TIMESTAMP] Partition added: $1" >> "$LOG_FILE"
echo "################################################" >> "$LOG_FILE"

MOUNTPOINT=`mktemp -d`
echo "Created a mount point for the device: $MOUNTPOINT" >> "$LOG_FILE"
OUTPUT=$(/usr/bin/mount "$DEVICE" "$MOUNTPOINT" 2>&1)

echo "Check if a file autoinstall.raucb exists in the root of the mount point" >> "$LOG_FILE"

if [ -e "$MOUNTPOINT"/autoinstall.raucb ]; then
    echo "Found an autoinstall.raucb file in the root folder, check if it has a valid signature" >> "$LOG_FILE"
    INFO=`/usr/bin/rauc info "$MOUNTPOINT"/autoinstall.raucb`
    echo $INFO >> "$LOG_FILE"
    echo "Try installing the file" >> "$LOG_FILE"
    OUTPUT=`/usr/bin/rauc install "$MOUNTPOINT"/autoinstall.raucb`
    echo $OUTPUT >> "$LOG_FILE"
    if [ $? -eq 0 ]; then
        echo "Install executed successfully" >> "$LOG_FILE"
        echo "System will reboot in 60 seconds ... " >> "$LOG_FILE"
        /usr/bin/umount "$DEVICE"
        sleep 60
        reboot '0 tryboot'
    else
        echo "Command failed with exit code $?" >> "$LOG_FILE"
        /usr/bin/umount "$DEVICE"
    fi
else
    echo "No file named autoinstall.raucb in the root of the device $1, mounted here: $MOUNTPOINT" >> "$LOG_FILE"
    /usr/bin/umount "$DEVICE"
fi
