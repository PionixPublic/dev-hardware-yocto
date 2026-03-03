SUMMARY = "Wetty Docker Service"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit systemd

SRC_URI = " \
    file://wetty.service \
    file://setup-wetty.sh \
"

# Define image we want to pull
IMAGE_NAME = "wettyoss/wetty"

SYSTEMD_SERVICE:${PN} = "wetty.service"
SYSTEMD_AUTO_ENABLE = "enable"

# We need bash for our setup script and docker at runtime
RDEPENDS:${PN} += "bash docker-moby"

# This task requires network access to pull the image
do_compile[network] = "1"

do_compile() {
    # Determine the docker platform based on TARGET_ARCH
    case ${TARGET_ARCH} in
        aarch64) DOCKER_PLATFORM="linux/arm64" ;;
        arm)     DOCKER_PLATFORM="linux/arm/v7" ;;
        x86_64)  DOCKER_PLATFORM="linux/amd64" ;;
        *)       DOCKER_PLATFORM="linux/${TARGET_ARCH}" ;;
    esac

    bbnote "Pulling ${IMAGE_NAME} image for ${DOCKER_PLATFORM}..."
    
    # Pull the image for the target platform
    if ! docker pull --platform ${DOCKER_PLATFORM} ${IMAGE_NAME}; then
        bberror "Failed to pull ${IMAGE_NAME} image."
        exit 1
    fi

    bbnote "Saving image to tarball..."
    docker save ${IMAGE_NAME} > ${WORKDIR}/wetty.tar
}

do_install() {
    # Install the pre-built image tarball
    install -d ${D}${datadir}/wetty
    install -m 0644 ${WORKDIR}/wetty.tar ${D}${datadir}/wetty/wetty.tar

    # Install the setup script
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/setup-wetty.sh ${D}${bindir}/setup-wetty.sh
    
    # Calculate hash of the actual tarball to detect changes during OTA
    IMAGE_SHA=$(sha256sum ${WORKDIR}/wetty.tar | cut -d' ' -f1)
    
    sed -i 's|@DATADIR@|${datadir}|g' ${D}${bindir}/setup-wetty.sh
    sed -i "s|@IMAGE_VERSION@|$IMAGE_SHA|g" ${D}${bindir}/setup-wetty.sh

    # Install the systemd service
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/wetty.service ${D}${systemd_system_unitdir}/wetty.service
}

FILES:${PN} += " \
    ${datadir}/wetty/wetty.tar \
    ${bindir}/setup-wetty.sh \
    ${systemd_system_unitdir}/wetty.service \
"
