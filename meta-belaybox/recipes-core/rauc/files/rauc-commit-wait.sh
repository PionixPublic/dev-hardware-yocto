#!/bin/sh
# post_reboot_health_check for cloud-connector's rauc-updater plugin.
# Waits until rauc-commit.service has decided about the booted slot.
#   exit 0 -> the slot was committed
#   exit 1 -> rauc-commit-gate.sh refused it (Result=exec-condition) or the
#             commit failed; the plugin then marks the slot bad and reboots
# Runs as the unprivileged cloud-connector user, systemctl show needs no root.
# The plugin's timeout_secs must cover the gate's TimeoutStartSec (420 s).

UNIT=rauc-commit.service

while :; do
    state=$(systemctl show -p ActiveState --value $UNIT)
    result=$(systemctl show -p Result --value $UNIT)
    case "$state/$result" in
        active/*)
            echo "$UNIT is active, slot committed"
            exit 0 ;;
        failed/*|*/exec-condition)
            echo "$UNIT did not commit the slot ($state, $result)"
            exit 1 ;;
    esac
    sleep 5
done
