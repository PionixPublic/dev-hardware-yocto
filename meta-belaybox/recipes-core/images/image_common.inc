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
