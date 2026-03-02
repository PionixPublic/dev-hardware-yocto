SUMMARY = "Next.js Display App Docker Container and Service"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit systemd

SRC_URI = " \
    git://git@github.com/PionixPro/next-display-app.git;protocol=ssh;branch=main \
    file://next-display-app.service \
    file://setup-next-display-app.sh \
"

SRCREV = "fe400d38fe2f1f7595b456a4b09520fabfceda8f"

S = "${WORKDIR}/git"

SYSTEMD_SERVICE:${PN} = "next-display-app.service"
SYSTEMD_AUTO_ENABLE = "enable"

# We need bash for our setup script and docker at runtime
RDEPENDS:${PN} += "bash docker-moby"

# This task requires network access to pull base images and npm install
do_compile[network] = "1"

do_compile() {
    # Determine the docker platform based on TARGET_ARCH
    case ${TARGET_ARCH} in
        aarch64) DOCKER_PLATFORM="linux/arm64" ;;
        arm)     DOCKER_PLATFORM="linux/arm/v7" ;;
        x86_64)  DOCKER_PLATFORM="linux/amd64" ;;
        *)       DOCKER_PLATFORM="linux/${TARGET_ARCH}" ;;
    esac

    bbnote "Building Next-Display-App image for ${DOCKER_PLATFORM}..."
    
    # Patch the Dockerfile on-the-fly to run build steps natively on the host (x86_64)
    # instead of emulating ARM via QEMU. This makes the build ~10x faster and avoids OOM.
    # 1. Base stage runs on host platform
    sed -i 's|FROM node:20-alpine AS base|FROM --platform=$BUILDPLATFORM node:20-alpine AS base|g' ${S}/Dockerfile
    # 2. Runner stage remains on target platform (arm)
    sed -i 's|FROM base AS runner|FROM node:20-alpine AS runner|g' ${S}/Dockerfile

    # Cross-compile the image. 
    if ! docker buildx build --platform ${DOCKER_PLATFORM} \
        --build-arg NODE_OPTIONS="--max-old-space-size=4096" \
        -t next-display-app --load ${S}; then
        bberror "Failed to build Next-Display-App image."
        bberror "Please set up docker buildx cross-compilation support on your host."
        exit 1
    fi

    bbnote "Saving image to tarball..."
    docker save next-display-app > ${WORKDIR}/next-display-app.tar
}

do_install() {
    # Install the pre-built image tarball
    install -d ${D}${datadir}/next-display-app
    install -m 0644 ${WORKDIR}/next-display-app.tar ${D}${datadir}/next-display-app/next-display-app.tar

    # Install the setup script
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/setup-next-display-app.sh ${D}${bindir}/setup-next-display-app.sh
    
    # Calculate hash of the actual tarball to detect changes during OTA
    IMAGE_SHA=$(sha256sum ${WORKDIR}/next-display-app.tar | cut -d' ' -f1)
    
    sed -i 's|@DATADIR@|${datadir}|g' ${D}${bindir}/setup-next-display-app.sh
    sed -i "s|@IMAGE_VERSION@|$IMAGE_SHA|g" ${D}${bindir}/setup-next-display-app.sh

    # Install the systemd service
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/next-display-app.service ${D}${systemd_system_unitdir}/next-display-app.service
}

FILES:${PN} += " \
    ${datadir}/next-display-app/next-display-app.tar \
    ${bindir}/setup-next-display-app.sh \
    ${systemd_system_unitdir}/next-display-app.service \
"
