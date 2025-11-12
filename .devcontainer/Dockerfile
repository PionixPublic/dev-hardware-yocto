FROM mcr.microsoft.com/vscode/devcontainers/base:debian-11

RUN apt update && apt install chrpath cpio diffstat gawk lz4 zstd vim file python3-distutils doxygen pybind11-dev pybind11-json-dev -yqq && rm -rf /var/lib/apt/lists/*

# install a recent version of nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
         && apt-get install -y nodejs
