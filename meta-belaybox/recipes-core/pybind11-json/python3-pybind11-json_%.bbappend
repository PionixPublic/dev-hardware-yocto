# Ensure we use the native python tools to find paths
inherit python3native

# Force CMake to use the path inside the sysroot (STAGING_INCDIR), 
# preventing it from looking at /usr/include on the host.
EXTRA_OECMAKE += "-DPYTHON_INCLUDE_DIR=${STAGING_INCDIR}/${PYTHON_DIR}"
EXTRA_OECMAKE += "-DPython3_INCLUDE_DIR=${STAGING_INCDIR}/${PYTHON_DIR}"
