# Shared by all RAUC bundle recipes in this layer. A bundle recipe sets
# BUNDLE_IMAGE, RAUC_BUNDLE_COMPATIBLE and the default of CLOUD_EDITION_ID,
# then requires this file.
#
# Everything the Pionix Cloud matches on is overridable from local.conf or
# auto.conf, e.g. to upload the bundles to your own cloud organisation:
#
#   FIRMWARE_VERSION = "1.2.0"
#   CLOUD_EDITION_ID:pn-umwcharger-bundle = "com.example.charger"
#   UMWCHARGER_RAUC_COMPATIBLE = "MyCharger"
#
# The cloud reports the booted slot's bundle version, so FIRMWARE_VERSION must
# be the version the bundle is uploaded with (pionixcli bundle upload --version).
# RAUC_BUNDLE_COMPATIBLE comes from <PRODUCT>_RAUC_COMPATIBLE (conf/layer.conf),
# which also sets the compatible in the image's /etc/rauc/system.conf.

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit bundle

FIRMWARE_VERSION ??= "${PV}"
RAUC_BUNDLE_VERSION = "${FIRMWARE_VERSION}"

# cc-plugin-rauc-updater takes the edition from this manifest section on a
# cloud OTA. No section when no edition is set.
CLOUD_EDITION_ID ??= ""
RAUC_META_SECTIONS += "${@'pionixcloud' if d.getVar('CLOUD_EDITION_ID') else ''}"
RAUC_META_pionixcloud[edition-id] = "${CLOUD_EDITION_ID}"
# meta-rauc does not track the meta sections, rebuild the manifest on a change
do_configure[vardeps] += "RAUC_BUNDLE_VERSION RAUC_META_SECTIONS CLOUD_EDITION_ID"

RAUC_BUNDLE_SLOTS = "rootfs boot"

RAUC_SLOT_rootfs = "${BUNDLE_IMAGE}"
RAUC_SLOT_rootfs[fstype] = "ext4"

RAUC_SLOT_boot = "${BUNDLE_IMAGE}"
RAUC_SLOT_boot[fstype] = "tar.xz"
RAUC_SLOT_boot[file] = "boot.tar.xz"

RAUC_BUNDLE_FORMAT ?= "verity"

# Bundle hook: runs on the installing (old) system, see bundle-hook.sh
SRC_URI += "file://bundle-hook.sh"
RAUC_BUNDLE_HOOKS[file] = "bundle-hook.sh"
RAUC_SLOT_rootfs[hooks] = "post-install"

#
# Generated with: openssl req -x509 -newkey rsa:4096 -keyout pionix.key.pem -out pionix.cert.pem -days 3650 -nodes
#
# Country Name (2 letter code) [AU]:DE
# State or Province Name (full name) [Some-State]:BW
# Locality Name (eg, city) []:Bad Schoenborn
# Organization Name (eg, company) [Internet Widgits Pty Ltd]:company
# Organizational Unit Name (eg, section) []:Pionix
# Common Name (e.g. server FQDN or YOUR name) []:pionix.de
# Email Address []:office@pionix.de
#
RAUC_KEY_FILE = "${THISDIR}/files/pionix.key.pem"
RAUC_CERT_FILE = "${THISDIR}/files/pionix.cert.pem"
