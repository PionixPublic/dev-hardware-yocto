# show welcome greeting
do_install:append () {
    sed -i -e 's:^#PrintMotd yes*$:PrintMotd yes:g' ${D}${sysconfdir}/ssh/sshd_config
}
