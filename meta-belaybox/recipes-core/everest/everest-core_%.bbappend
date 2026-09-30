FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://tryboot"

# everest-core is built from the local checkout (file://), so PV would
# default to "git", which is what ended up in everest_release.json and the
# display app. Use the checked out branch and commit instead. setup leaves
# the checkout on a detached HEAD, so take the branch from the refs that
# point at it. '/' is not allowed in PV (it ends up in paths and file names).
#
# This reads .git directly instead of running git: PV is also evaluated when
# the worker re-parses the recipe for fakeroot tasks under pseudo, where git
# intermittently fails, and a different PV there breaks the task.
def everest_core_pv(d):
    import os
    src = os.path.join(d.getVar('EVEREST_CORE_PARENT_PATH'), d.getVar('EVEREST_CORE_REPONAME'))
    gitdir = os.path.join(src, '.git')
    head_file = os.path.join(gitdir, 'HEAD')
    # re-parse when the checkout moves, the parse cache would keep a stale PV
    bb.parse.mark_dependency(d, head_file)

    try:
        with open(head_file) as f:
            head = f.read().strip()
    except OSError:
        return 'git'

    refs = {}
    try:
        with open(os.path.join(gitdir, 'packed-refs')) as f:
            for line in f:
                if line[0] not in '#^':
                    rev, name = line.split()
                    refs[name] = rev
    except OSError:
        pass
    for root, _, files in os.walk(os.path.join(gitdir, 'refs')):
        for name in files:
            path = os.path.join(root, name)
            with open(path) as f:
                refs[os.path.relpath(path, gitdir)] = f.read().strip()

    if head.startswith('ref: '):
        ref = head[len('ref: '):]
        rev = refs.get(ref, '')
        branch = ref[len('refs/heads/'):] if ref.startswith('refs/heads/') else ref
    else:
        rev = head
        # prefer a local branch, else a remote one without the remote name
        heads = sorted(n[len('refs/heads/'):] for n, r in refs.items()
                       if r == rev and n.startswith('refs/heads/'))
        remotes = sorted(n.split('/', 3)[3] for n, r in refs.items()
                         if r == rev and n.startswith('refs/remotes/') and n.count('/') >= 3
                         and not n.endswith('/HEAD'))
        branch = (heads or remotes or [''])[0]

    if not rev:
        return 'git'
    rev = rev[:9]
    if not branch:
        return rev

    return '%s+%s' % (branch.replace('/', '_'), rev)

PV = "${@everest_core_pv(d)}"

# disable the systemd services shipped by everest-core; belaybox provides its
# own everest.service via the everest-belaybox recipe and does not use the
# chargebridge application
SYSTEMD_SERVICE:${PN} = ""
SYSTEMD_SERVICE:chargebridge = ""

do_install:append() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/tryboot ${D}${sbindir}/

    # remove systemd service
    rm -rf ${D}${systemd_system_unitdir} ${D}/usr/lib/systemd
}

FILES:${PN} += "${sbindir}/tryboot"
