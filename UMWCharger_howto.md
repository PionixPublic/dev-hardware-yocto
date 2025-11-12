# Cheat sheet for Yocto based UMWC

## Log files

Log files should be stored in the following folder:

```
/var/everest-logs
```

This folder is also available via HTTP.

## Custom config files

Custom config files should be stored here:

```
/etc/everest/custom_configs
```

## Select the EVerest installation

The image contains a default EVerest installation under /usr. This is used by default. During development you may want to use
a different (e.g. cross compiled development version).
There is a symlink that is used in the systemd services that points to the EVerest installation that should be used:

```
/etc/everest/selected-everest
```

By default it points to ``/usr``. You can change it to ``/var/everest`` and restart ``everest.service`` to use the development version.

## Cross compile

similar to belaybox, use this to install:

```
DESTDIR=dist ninja install/strip && rsync -av dist/var/everest root@10.10.10.14:/var
```

## Updating yocto

You can update with e.g.:

```
rauc install http://10.9.9.5:8000/umwc-bundle-raspberrypi4.raucb
```

Once the update is installed, reboot with tryboot:

```
tryboot
```

After the new boot, if everything looks good, do the following (we dont have the System module running which normally does that):

```
check_system_health.sh
rauc status mark-good
```

Then it is permanent and will not fall back to the previous version on next boot.

## Update MCU

Similar to belaybox: Always ensure no EVerest is running that uses the MCU!

```
systemctl stop everest
umwc_fwupdate /dev/ttyAMA0 myupdate.bin
```
