#!/bin/bash
IMAGE_TAR="@DATADIR@/next-display-app/next-display-app.tar"
STATE_DIR="/var/lib/next-display-app"
VERSION_FILE="$STATE_DIR/last_loaded_version"
CURRENT_VERSION="@IMAGE_VERSION@"

mkdir -p "$STATE_DIR"

LOAD_REQUIRED=false

# 1. Check if the image exists in docker
if ! docker image inspect next-display-app >/dev/null 2>&1; then
    echo "Image next-display-app not found. Load required."
    LOAD_REQUIRED=true
elif [ -f "$VERSION_FILE" ]; then
    # 2. Check if the version matches the last loaded one
    INSTALLED_VERSION=$(cat "$VERSION_FILE")
    if [ "$INSTALLED_VERSION" != "$CURRENT_VERSION" ]; then
        echo "Version mismatch ($INSTALLED_VERSION -> $CURRENT_VERSION). Update required."
        LOAD_REQUIRED=true
    fi
else
    # 3. No version file found, load to be safe
    echo "No version record found. Load required to ensure consistency."
    LOAD_REQUIRED=true
fi

if [ "$LOAD_REQUIRED" = true ]; then
    if [ -f "$IMAGE_TAR" ]; then
        /usr/bin/psplash-write "MSG Updating Next.js Display App..." || true
        echo "Loading image from $IMAGE_TAR (Version: $CURRENT_VERSION)..."
        if docker load -i "$IMAGE_TAR"; then
            echo "$CURRENT_VERSION" > "$VERSION_FILE"
        else
            echo "Error: Failed to load docker image."
            exit 1
        fi
    else
        echo "Error: $IMAGE_TAR not found. Cannot load image."
        exit 1
    fi
else
    echo "Next-display-app image is already up to date ($CURRENT_VERSION). Skipping load."
fi

