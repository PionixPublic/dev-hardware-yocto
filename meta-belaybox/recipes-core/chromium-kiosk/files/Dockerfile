FROM debian:trixie-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium libgl1-mesa-dri libgles2 libegl1 libwayland-client0 libwayland-egl1 \
    && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["chromium"]
