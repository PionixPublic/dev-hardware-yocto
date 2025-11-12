# autoinstall
Autoinstall works by looking after files called `autoinstall.raucb` in the root folder of inserted devices.
If it will find one, will try to install it (must be a valid signed RAUC bundle).

WARNING: This is a potential security risk in production.

# boot-install-reset
This is for testing purposes only!!!
It will try to update the target everytime the target boots, then reset in an endless loop.