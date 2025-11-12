#!/bin/bash

if [ -d "/factory_data/rauc" ]; then
    # nothing to do, rauc backend file structure already exists
    echo "Rauc file structure already exists, skipping execution."
else
    # rauc backend file structure doesn't exist, this is the first time use afer flash, initializing
    # assume both partitions exist and are in good state
    echo "Rauc file structure not detected, creating it."
    echo "Assume 2 valid root partitions, booted the first partit."
    mount -o remount,rw /factory_data
    mkdir -p -m 0755 /factory_data/rauc
    echo "system0" > /factory_data/rauc/primary
    echo "good" > /factory_data/rauc/system0
    echo "good" > /factory_data/rauc/system1
    mount -o remount,ro /factory_data
    echo "Rauc initialization complete."
fi

echo "Service not needed anymore, disable it."
systemctl disable rauc-init
echo "Done."
