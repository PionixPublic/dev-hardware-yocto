LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit bundle

RAUC_BUNDLE_COMPATIBLE = "Belaybox"
RAUC_BUNDLE_SLOTS = "rootfs boot"

RAUC_SLOT_rootfs = "umwcharger-image"
RAUC_SLOT_rootfs[fstype] = "ext4"

RAUC_SLOT_boot = "umwcharger-image"
RAUC_SLOT_boot[fstype] = "tar.xz"
RAUC_SLOT_boot[file] = "boot.tar.xz"

RAUC_BUNDLE_FORMAT ?= "verity"

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