#!/bin/bash
#
# Hostname "<base>-<last 8 characters of the CM4 serial number>", e.g. belaybox-a6a2d39e.
# Runs on every boot (set-hostname.service) and rewrites /etc/hostname when it differs:
# the image default ("belaybox"), or a stale suffix from an older image that derived it
# from eth0, which on this image is either missing or the PLC modem with a random MAC.

SERIAL=$(tr -dc '0-9a-fA-F' < /proc/device-tree/serial-number 2>/dev/null | tail -c 8)
if [ -z "$SERIAL" ]; then
    echo "No serial number found, keeping the hostname"
    exit 0
fi

CURRENT=$(cat /etc/hostname 2>/dev/null)
BASE=${CURRENT%%-*}
BASE=${BASE:-belaybox}
NEW_HOSTNAME="$BASE-$SERIAL"

if [ "$CURRENT" = "$NEW_HOSTNAME" ]; then
    exit 0
fi

echo "$NEW_HOSTNAME" > /etc/hostname
sed -i "s/^\(127.0.1.1\s\+\).*/\1$NEW_HOSTNAME/" /etc/hosts
hostname "$NEW_HOSTNAME"

echo "Hostname changed to: $NEW_HOSTNAME"
