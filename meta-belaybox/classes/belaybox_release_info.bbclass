# Complete the release metadata written by meta-everest's
# everest_version_file.bbclass, which the display app shows on its About
# screen.
#
# The display app requires a description and a license for every component
# and discards the whole file if one is missing, which meta-everest does not
# provide. Fill them in from pkgdata, and add the version of this yocto repo
# (same string as in the ssh motd) as the first component.

inherit everest_version_file

python do_belaybox_release_info() {
    import json
    import os
    import subprocess
    import oe.packagedata

    release_file = d.getVar('IMAGE_ROOTFS') + d.getVar('EVEREST_RELEASE_FILE')
    with open(release_file, encoding='utf-8') as f:
        release = json.load(f)

    for component in release['components']:
        info = {}
        pkg_info = os.path.join(d.getVar('PKGDATA_DIR'), 'runtime', component['name'])
        if os.path.exists(pkg_info):
            info = oe.packagedata.read_pkgdatafile(pkg_info)
        component.setdefault('description', info.get('SUMMARY', ''))
        component.setdefault('license', info.get('LICENSE', ''))

    # do_rootfs runs under pseudo, where git sees itself as root and may
    # refuse the repo as not owned by the user, so run it outside of pseudo
    repo = os.path.dirname(d.getVar('FILE'))
    env = dict(os.environ, PSEUDO_UNLOAD='1')
    try:
        toplevel = subprocess.check_output(['git', '-C', repo, 'rev-parse', '--show-toplevel'],
                                           env=env, text=True).strip()
        version = subprocess.check_output(['git', '-C', repo, 'describe', '--dirty', '--all', '--long'],
                                          env=env, text=True).strip()
    except (OSError, subprocess.CalledProcessError) as e:
        bb.warn("Unable to determine yocto repo version: %s" % e)
        toplevel, version = repo, 'unknown'

    release['components'].insert(0, {
        'name': os.path.basename(toplevel),
        'version': version,
        'description': d.getVar('SUMMARY') or '',
        'license': d.getVar('LICENSE') or '',
    })

    with open(release_file, 'w', encoding='utf-8') as f:
        json.dump(release, f, indent=2)
}

# must run after do_everest_generate_version, which is appended by the class
# inherited above
ROOTFS_POSTPROCESS_COMMAND:append = " do_belaybox_release_info;"
