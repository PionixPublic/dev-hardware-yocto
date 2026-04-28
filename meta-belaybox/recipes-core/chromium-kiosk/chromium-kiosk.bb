SUMMARY = "Chromium Kiosk Docker Container and Service"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit systemd

SRC_URI = " \
    file://Dockerfile \
    file://build-chromium.sh \
    file://chromium-kiosk.service \
"

S = "${WORKDIR}"

SYSTEMD_SERVICE:${PN} = "chromium-kiosk.service"
SYSTEMD_AUTO_ENABLE = "enable"

CHROMIUM_KIOSK_URL ?= "http://172.17.0.1:3000"

# We need bash for our setup script and docker/weston at runtime
RDEPENDS:${PN} += "bash docker-moby weston-init next-display-app"

do_compile[network] = "1"

do_compile() {
    case ${TARGET_ARCH} in
        aarch64) DOCKER_PLATFORM="linux/arm64" ;;
        arm)     DOCKER_PLATFORM="linux/arm/v7" ;;
        x86_64)  DOCKER_PLATFORM="linux/amd64" ;;
        *)       DOCKER_PLATFORM="linux/${TARGET_ARCH}" ;;
    esac

    bbnote "Building rpi-chromium image for ${DOCKER_PLATFORM}..."
    if ! docker buildx build --platform ${DOCKER_PLATFORM} \
        -t rpi-chromium --load ${S}; then
        bberror "Failed to build rpi-chromium Docker image."
        exit 1
    fi

    bbnote "Saving image to tarball..."
    docker save rpi-chromium > ${WORKDIR}/rpi-chromium.tar
}

do_install() {
    # Install the pre-built image tarball
    install -d ${D}${datadir}/chromium-kiosk
    install -m 0644 ${WORKDIR}/rpi-chromium.tar ${D}${datadir}/chromium-kiosk/rpi-chromium.tar

    # Install the build script
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/build-chromium.sh ${D}${bindir}/build-chromium.sh

    # Install the systemd service
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/chromium-kiosk.service ${D}${systemd_system_unitdir}/chromium-kiosk.service
}

FILES:${PN} += " \
    ${datadir}/chromium-kiosk/rpi-chromium.tar \
    ${bindir}/build-chromium.sh \
    ${systemd_system_unitdir}/chromium-kiosk.service \
"
