# Overlay
`/etc` and `/var` are overlay mounts whose writable layers live on a separate
partition (`/dev/mmcblk0p8`, mounted at `/overlay`):

```
/overlay/etc_upper + /overlay/etc_work  ->  /etc
/overlay/var_upper + /overlay/var_work  ->  /var
```

The overlays are mounted *before* systemd starts, by a preinit script that the
`overlayfs-etc` image feature installs as `/sbin/init` (the real init is renamed
to `/sbin/init.orig`). The script is generated from `files/belaybox-preinit.sh.in`;
the feature is configured in `recipes-core/images/image_common.inc`.

Mounting early matters: systemd reads enabled units, drop-ins and
`/etc/machine-id` from `/etc` when it starts, and it mounts the `/var/volatile`
tmpfs on top of `/var`, so both overlays have to be in place first.

The template is rendered with python `str.format()`: only the class placeholders
(`{OVERLAYFS_ETC_MOUNT_POINT}`, `{OVERLAYFS_ETC_DEVICE}`, `{SBIN_INIT_NAME}`, ...)
may contain curly braces.

## Resetting the overlay
Create the flag file and reboot. The preinit deletes the overlay directories
before mounting them, so no second reboot is needed:
```
# touch /overlay/OVERLAY_CLEAN
# reboot
```

## Debugging
The preinit logs to the kernel log: `journalctl -k | grep PREINIT`.
To boot without the overlays, add `init=/sbin/init.orig` to `cmdline.txt` on the
boot partition.
