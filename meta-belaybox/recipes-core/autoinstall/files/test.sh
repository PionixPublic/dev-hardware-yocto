#!/bin/bash


# Give the target some time to settle up
sleep 100
/usr/bin/systemctl stop everest
TIMESTAMP=$(date +"%Y-%m-%d %T")
echo "[$TIMESTAMP] Tell the power REST controller that the update is starting" > /dev/serial0
output=`rauc status`
echo "$output" > /dev/serial0
curl -X POST http://10.9.9.5:5000/trigger
output=`rauc install /overlay/belaybox-bundle-raspberrypi4.raucb`
echo "$output" > /dev/serial0
TIMESTAMP=$(date +"%Y-%m-%d %T")
echo "[$TIMESTAMP] Update has finished, wait for the power off" > /dev/serial0
output=`rauc status`
echo "$output" > /dev/serial0
reboot '0 tryboot'