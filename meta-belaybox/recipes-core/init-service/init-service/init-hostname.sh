#!/bin/bash

# Get the last 4 characters of the eth0 MAC address and replace ":" with "_"
MAC_ADDRESS=$(cat /sys/class/net/eth0/address)
HOSTNAME_SUFFIX=${MAC_ADDRESS:12}
HOSTNAME_SUFFIX=$(echo $HOSTNAME_SUFFIX | tr -d ':')

# New hostname format (HOSTNAME_BASE is taken from environment)
NEW_HOSTNAME="$(hostname)-$HOSTNAME_SUFFIX"

# Update /etc/hostname
echo "$NEW_HOSTNAME" | tee /etc/hostname > /dev/null

# Update /etc/hosts
sed -i "s/^\(127.0.1.1\s\+\).*/\1$NEW_HOSTNAME/" /etc/hosts
hostname "$NEW_HOSTNAME"
hostnamectl set-hostname "$NEW_HOSTNAME"

# Display the new hostname
echo "Hostname changed to: $NEW_HOSTNAME"
