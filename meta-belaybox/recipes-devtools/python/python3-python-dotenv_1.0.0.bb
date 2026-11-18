SUMMARY = "python-dotenv: Read key-value pairs from a .env file and set them as environment variables"
HOMEPAGE = "https://github.com/theskumar/python-dotenv"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=e914cdb773ae44a732b392532d88f072"

# pionix-control imports dotenv. Until EVerest 2026.10 this recipe came from
# meta-everest (a Josev dependency); scarthgap meta-python has none.
SRC_URI[sha256sum] = "a8df96034aae6d2d50a4ebe8216326c61c3eb64836776504fcca410e5937a3ba"

PYPI_PACKAGE = "python-dotenv"

inherit pypi setuptools3
