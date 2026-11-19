#!/bin/bash
# RAUC_SYSTEM_SERIAL: last 8 characters of the CM4 serial number. The previous
# source, eth0's MAC, is unreliable on this image: the onboard NIC is called
# end0, and eth0 is either missing or the PLC modem with a random MAC.
echo RAUC_SYSTEM_SERIAL=$(tr -dc '0-9a-fA-F' < /proc/device-tree/serial-number | tail -c 8)
