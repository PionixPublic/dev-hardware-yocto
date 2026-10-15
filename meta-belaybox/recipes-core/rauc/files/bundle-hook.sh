#!/bin/sh
# RAUC bundle hook. Runs on the system that performs the install.
# slot-post-install (rootfs): replace a buggy running /usr/lib/rauc/backend.sh
# (pre-059f280: set-primary system0 copied boot_b) with the fixed one from the
# freshly written rootfs, before RAUC calls set-primary.
set -e

case "$1" in
slot-post-install)
	[ "$RAUC_SLOT_CLASS" = "rootfs" ] || exit 0
	cur=/usr/lib/rauc/backend.sh
	new="$RAUC_SLOT_MOUNT_POINT/usr/lib/rauc/backend.sh"

	# fixed versions contain exactly one boot_a create_boot; buggy ones none
	grep -qF 'create_boot "$boot_a" $2' "$cur" && exit 0
	grep -qF 'create_boot "$boot_a" $2' "$new" || { echo "bundle backend.sh not fixed" >&2; exit 1; }

	remount_ro=
	if awk '$2=="/" {print $4}' /proc/mounts | grep -q "^ro"; then
		mount -o remount,rw /
		remount_ro=1
	fi
	cp "$new" "$cur.new"
	chmod 0755 "$cur.new"
	mv "$cur.new" "$cur"
	sync
	[ -n "$remount_ro" ] && mount -o remount,ro /
	echo "Patched running $cur (set-primary system0 fix)"
	;;
esac
exit 0
