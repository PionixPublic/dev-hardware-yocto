FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://tryboot"

# disable the systemd service
SYSTEMD_SERVICE:${PN} = ""

do_install:append() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/tryboot ${D}${sbindir}/

    # remove systemd service
    rm -rf ${D}${systemd_system_unitdir} ${D}/usr/lib/systemd
}

FILES:${PN} += "${sbindir}/tryboot"

# there are issues with pybind11 and the sstate cache
#
#   CMake Error in lib/everest/framework/everestpy/src/everest/CMakeLists.txt:
#     Imported target "pybind11_json" includes non-existent path
#
# INTERFACE_INCLUDE_DIRECTORIES can point outside of the build area
# when built by a different Yocto project.

# Option 1 - disable PY support
# EXTRA_OECMAKE:append = " -DEVEREST_ENABLE_PY_SUPPORT=OFF"

# Option 2 provide the location to cmake
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://0001-Enable-pybind11-include-directories-to-be-set.patch"

EXTRA_OECMAKE:append = " -DPYBIND11_INTERFACE_INCLUDE_DIRECTORIES=${STAGING_INCDIR}/${PYTHON_DIR}"

# add to CMakeLists.txt
# if (PYBIND11_INTERFACE_INCLUDE_DIRECTORIES)
#     set_target_properties(pybind11::pybind11 PROPERTIES
#             INTERFACE_INCLUDE_DIRECTORIES ${PYBIND11_INTERFACE_INCLUDE_DIRECTORIES}
#     )
#     set_target_properties(pybind11_json PROPERTIES
#             INTERFACE_INCLUDE_DIRECTORIES ${PYBIND11_INTERFACE_INCLUDE_DIRECTORIES}
#     )
# endif()
