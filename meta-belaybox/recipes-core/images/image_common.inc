# Common base of all images in this layer (Belaybox, uMWCharger, Yakalo).
# An image recipe requires this file first and then only adds what is
# specific to it: SUMMARY, its own packages and IMAGE_HOSTNAME.

require recipes-core/images/core-image-base.bb

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

COMPATIBLE_MACHINE = "^rpi$"

# This variable contains ALL the packages that are common to the
# images we want to build. There is a catch however when building
# for QEMU, since certain pacakges are not compatible with that arch.
# For those packages, there is a section in the image that
# is handling the difference

COMMON_PACKAGES = " \
        rpi-gpio \
        rpio \
        pionix-dtbo \
        bcm2835-tests \
        python3-pip \
        python3-ply \
        python3-cffi \
        python3-asyncio-glib \
        python3-cryptography \
        python3-psutil \
        python3-netifaces \
        python3-dateutil \
        python3-sqlite3 \
        sqlite3 \
        everest-core \
        everest-common \
        chargebridge \
        mosquitto \
        fontconfig \
        ttf-roboto \
        tzdata \
        screen \
        openssh \
        nano \
        htop \
        lsof \
        rauc-init \
        rauc-backend \
        init-service \
        overlayfs \
        minicom \
        util-linux \
        coreutils \
        iproute2 \
        tree \
        curl \
        wpa-supplicant \
        autoinstall \
	perf \
        ftxui \
        rsync \
        tcpdump \
        canutils \
        tmux \
        bash-completion \
        bash-completion-extra \
        systemd-bash-completion \
        util-linux-bash-completion \
        iproute2-bash-completion \
        kmod-bash-completion \
        udev-bash-completion \
        tpm2-tools-bash-completion \
        wireguard-tools-bash-completion \
        iotop \
        iperf3 \
        wireless-regdb-static \
        bluez5 \
        stm32flash \
        rc-utils \
        htt-util \
        lighttpd \
        wireguard-tools \
        gdb \
        open-plc-utils \
	tpm2-openssl \
	tpm2-tools \
	tpm2-tss \
	tpm2-abrmd \
	libtss2-tcti-device \
"

CORE_IMAGE_EXTRA_INSTALL += "${COMMON_PACKAGES} cloudconnector"
CORE_IMAGE_EXTRA_INSTALL += "${@' everest-node-red-flows ' if d.getVar('BELAYBOX_UNSTABLE') == '1' else ''}"

# Packages for the images with a display (flutter display-app)
DISPLAY_PACKAGES = " \
        display-app \
        flutter-pi \
        flutter-engine \
"

PACKAGE_EXCLUDE += " \
        dlt-system \
        dlt \
"

IMAGE_BOOT_FILES:append = " devicetree/tpm-slb9670-overlay.dtbo;overlays/tpm-slb9670.dtbo devicetree/mcp2515-can0-spi1-overlay.dtbo;overlays/mcp2515-can0-spi1.dtbo"

inherit boot_image
inherit belaybox_release_info

DISABLE_SPLASH = "1"
DISABLE_RPI_BOOT_LOGO = "1"

IMAGE_INSTALL:append = " psplash"
IMAGE_FEATURES += " splash "
COPY_LIC_MANIFEST = "1"

WKS_FILE = "belay-partition-setup.wks.in"

ENABLE_UART = "1"
export BELAYBOX_UPDATE_CHANNEL = "${@'STABLE' if d.getVar('BELAYBOX_UNSTABLE') == '0' else 'UNSTABLE'}"
# everest_version_file.bbclass (meta-everest) still reads the pre-rename name
export EVEREST_UPDATE_CHANNEL = "${BELAYBOX_UPDATE_CHANNEL}"

inherit extrausers
EXTRA_USERS_PARAMS = "\
    usermod -p '\$6\$eIBRUc5cdOdQGN6R\$fi.NN7ra6MIPycWlEp/u6Ys1TwDZRhe98rvG1MljmQolByGlgnnuywtsNymOaUhYqJH8NJuLiZXvccNQJW61F0' root; \
    "

# Mount the /etc and /var overlays from a preinit script before systemd starts,
# see recipes-core/overlay/README.md
IMAGE_FEATURES += "overlayfs-etc"
OVERLAYFS_ETC_MOUNT_POINT = "/overlay"
OVERLAYFS_ETC_DEVICE = "/dev/mmcblk0p8"
OVERLAYFS_ETC_FSTYPE = "ext4"
OVERLAYFS_ETC_CREATE_MOUNT_DIRS = "0"
OVERLAYFS_ETC_INIT_TEMPLATE = "${BELAYBOX_LAYERDIR}/recipes-core/overlay/files/belaybox-preinit.sh.in"
# the class does not track the template; rebuild the rootfs when it changes
do_rootfs[file-checksums] += "${OVERLAYFS_ETC_INIT_TEMPLATE}:True"

# bash instead of /bin/sh as root's login shell, so that ~/.bashrc and the
# programmable completion (bash-completion) behave as on a desktop distro
EXTRA_USERS_PARAMS:append = " usermod -s /bin/bash root;"

# Base hostname, init-hostname.sh appends the serial number at boot
IMAGE_HOSTNAME ??= "belaybox"

set_image_hostname() {
    echo "${IMAGE_HOSTNAME}" > ${IMAGE_ROOTFS}${sysconfdir}/hostname
}

ROOTFS_POSTPROCESS_COMMAND += "set_image_hostname; "

# cloudconnector and rauc-conf are one package for all images, their configs
# have @VAR@ placeholders filled in per image here. Override in local.conf, e.g.
#   CC_DEVICE_MODEL:pn-umwcharger-image = "MyCharger"
# RAUC_COMPATIBLE must match RAUC_BUNDLE_COMPATIBLE of the image's bundle, both
# come from <PRODUCT>_RAUC_COMPATIBLE in conf/layer.conf.
CC_DEVICE_MODEL ??= "BelayBox"
CC_CONFIG_FILE = "/opt/cloud-connector/cloud-connector.yaml"
RAUC_COMPATIBLE ??= "${BELAYBOX_RAUC_COMPATIBLE}"
RAUC_SYSTEM_CONF = "${sysconfdir}/rauc/system.conf"

fill_image_placeholders() {
    sed -i -e 's|@CC_DEVICE_MODEL@|${CC_DEVICE_MODEL}|g' ${IMAGE_ROOTFS}${CC_CONFIG_FILE}
    sed -i -e 's|@RAUC_COMPATIBLE@|${RAUC_COMPATIBLE}|g' ${IMAGE_ROOTFS}${RAUC_SYSTEM_CONF}
    for f in ${CC_CONFIG_FILE} ${RAUC_SYSTEM_CONF}; do
        if grep -n '@[A-Z_]*@' ${IMAGE_ROOTFS}$f; then
            bbfatal "unfilled placeholder in $f"
        fi
    done
}

ROOTFS_POSTPROCESS_COMMAND += "fill_image_placeholders; "
