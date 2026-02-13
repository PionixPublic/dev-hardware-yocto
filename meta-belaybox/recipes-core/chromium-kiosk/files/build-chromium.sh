#!/bin/bash
# Check if the image already exists
if ! docker image inspect rpi-chromium >/dev/null 2>&1; then
    echo "First boot detected: Building rpi-chromium Docker image..."
    # Build the image using the Dockerfile we installed
    docker build -t rpi-chromium /etc/chromium-kiosk/
else
    echo "rpi-chromium image already exists. Skipping build."
fi

# Ensure Wayland permissions are open before starting
chmod 777 /run/wayland-0 2>/dev/null || true
