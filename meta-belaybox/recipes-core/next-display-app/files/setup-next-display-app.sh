#!/bin/bash
IMAGE_TAR="@DATADIR@/next-display-app/next-display-app.tar"

# Check if the image already exists
if ! docker image inspect next-display-app >/dev/null 2>&1; then
    if [ -f "$IMAGE_TAR" ]; then
        /usr/bin/psplash-write "MSG Loading Next.js Display App..." || true
        echo "Image next-display-app not found. Loading from $IMAGE_TAR..."
        docker load -i "$IMAGE_TAR"
    else
        echo "Error: $IMAGE_TAR not found. Cannot load image."
        exit 1
    fi
else
    echo "next-display-app image already exists. Skipping load."
fi
