# Overlay
We are mounting an overlay on top of /etc and /var folders.
The overlay is expecting a separate partition mounted under /overlay.

You can force the clean up of the partition by creating a file called OVERLAY_CLEAN:
```
# touch /overlay/OVERLAY_CLEAN
```

This will cause that during the next boot, before the partition is mounted, the contents of the overlay to be deleted.