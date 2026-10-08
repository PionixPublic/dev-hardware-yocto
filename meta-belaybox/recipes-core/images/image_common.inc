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
        python3-iso15118 \
        python3-sqlite3 \
        sqlite3 \
        everest-core \
        everest-common \
        chargebridge \
        libocpp \
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
