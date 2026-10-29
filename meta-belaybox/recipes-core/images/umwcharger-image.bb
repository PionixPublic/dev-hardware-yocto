require image_common.inc

SUMMARY = "EVerest image for PIONIX Micro Megawat Charger"

CORE_IMAGE_EXTRA_INSTALL += "\
        ${DISPLAY_PACKAGES} \
        python3-jinja2 \
        python3-pyyaml \
        python3-requests \
        python3-paho-mqtt \
        python3-dbus \
        python3-python-dotenv \
        pionix-control \
        motd-umwcharger \
        radvd \
"

IMAGE_HOSTNAME = "umwcharger"

CC_DEVICE_MODEL ?= "uMWCharger"
