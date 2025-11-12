RPIFW_DATE ?= "20240306"

RPIFW_SRC_URI ?= "https://github.com/raspberrypi/rpi-firmware/archive/e062f8a50ee8fd36dacbeef6af6aceebf1e1dbc6.zip"
RPIFW_S ?= "${WORKDIR}/rpi-firmware-e062f8a50ee8fd36dacbeef6af6aceebf1e1dbc6"

SRC_URI = "${RPIFW_SRC_URI}"
SRC_URI[sha256sum] = "32c89fafcf8cc89dd9646c8657f4e7ad7dbe0748ce0b74444f8ef9151b069c5b"

PV = "${RPIFW_DATE}"
