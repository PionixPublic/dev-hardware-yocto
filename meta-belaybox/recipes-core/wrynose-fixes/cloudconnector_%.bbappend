# meta-pionix-cloud v0.5.1 compatibility for wrynose.
#
# cloudconnector-install.bbclass (and cloudconnector_%.bb for the D-Bus policy)
# read the file:// sources from d.getVar('WORKDIR'), but wrynose unpacks them
# to ${UNPACKDIR}. The path is hard-coded in python, so instead of copying the
# class, stage the unpacked files where it looks for them right before
# do_install. The OCI artifacts fetched by do_fetch_oci already live in
# ${WORKDIR}/cc and ${WORKDIR}/plugins, as the class expects.
#
# Remove once meta-pionix-cloud reads from UNPACKDIR.
cloudconnector_stage_unpacked_files() {
    for f in cloud-connector.service \
             10-cloud-connector-reboot.rules \
             20-cloud-connector-manage-units.rules \
             dbus-cloudconnector-rauc.conf; do
        install -m 0644 ${UNPACKDIR}/$f ${WORKDIR}/$f
    done
}
do_install[prefuncs] += "cloudconnector_stage_unpacked_files"
