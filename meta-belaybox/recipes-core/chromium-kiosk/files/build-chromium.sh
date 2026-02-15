#!/bin/bash
IMAGE_TAR="@DATADIR@/chromium-kiosk/rpi-chromium.tar"

# Check if the image already exists
if ! docker image inspect rpi-chromium >/dev/null 2>&1; then
    if [ -f "$IMAGE_TAR" ]; then
        /usr/bin/psplash-write "MSG Loading Chromium Kiosk..." || true
        echo "Image rpi-chromium not found. Loading from $IMAGE_TAR..."
        docker load -i "$IMAGE_TAR"
    else
        echo "Error: $IMAGE_TAR not found. Cannot load image."
        exit 1
    fi
else
    echo "rpi-chromium image already exists. Skipping load."
fi

# Ensure Wayland permissions are open before starting
chmod 777 /run/wayland-0 2>/dev/null || true
