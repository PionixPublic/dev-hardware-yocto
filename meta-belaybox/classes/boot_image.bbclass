#
# Creates the boot image folder structure
#

def do_prepare_boot_image(d):
    import os
    import re
    from glob import glob

    hdddir = "%s/boot.%s" % (d.getVar("WORKDIR"), "pionix")
    kernel_dir = d.getVar("DEPLOY_DIR_IMAGE")
    if not kernel_dir:
        bb.build.die("Error: Can't find the kernel image!")

    boot_files = d.getVar("IMAGE_BOOT_FILES")
    if not boot_files:
        bb.build.die("Error: IMAGE_BOOT_FILES is empty or not defined!")

    #
    # Process IMAGE_BOOT_FILES since contains either glob entries or names that must change on the installed medium
    #
    #   IMAGE_BOOT_FILES = "bcm2835-bootfiles/*" (this installs all the files from the "bcm2835-bootfiles" folder)
    #   IMAGE_BOOT_FILES = "bcm2835-bootfiles/*;boot/" (this copies all the files from the "bcm2835-bootfiles" folder into "boot" folder)
    #   IMAGE_BOOT_FILES = "u-boot.img uImage;kernel" (u-boot.img keeps the name uImage should change the name to kernel)
    #
    deploy_files = []
    for src_entry in re.findall(r'[\w;\-\./\*]+', boot_files):
        if ';' in src_entry:
            dst_entry = tuple(src_entry.split(';'))
            if not dst_entry[0] or not dst_entry[1]:
                bb.build.die("Error: IMAGE_BOOT_FILES is malformed!")
        else:
            # by default install files under their basename
            dst_entry = (src_entry, src_entry)

        bb.note(f"INFO: Destination entry: ({src_entry}, {src_entry})")
        deploy_files.append(dst_entry)

    install_task = []
    for deploy_entry in deploy_files:
        src, dst = deploy_entry
        if '*' in src:
            entry_name_fn = os.path.basename
            if dst != src:
                # unless a target name was given, then treat name
                # as a directory and append a basename
                entry_name_fn = lambda name: os.path.join(dst, os.path.basename(name))

            srcs = glob(os.path.join(kernel_dir, src))

            bb.note(f"INFO: Globbed sources: {', '.join(srcs)}")
            for entry in srcs:
                src = os.path.relpath(entry, kernel_dir)
                entry_dst_name = entry_name_fn(entry)
                install_task.append((src, entry_dst_name))
                bb.note(f"INFO: Installation task entry: ({src}, {entry_dst_name})")
        else:
            # by default install files under their basename
            install_task.append((src, dst))
            bb.note(f"INFO: Installation task entry: ({src}, {dst})")

    install_files = []
    for task in install_task:
        src_path, dst_path = task
        bb.note(f"INFO: Install {src_path} as {dst_path}")
        bb.note(f"INFO: Actual install {os.path.join(kernel_dir, src_path)} as {os.path.join(hdddir, dst_path)}")
        install_files.append((os.path.join(kernel_dir, src_path),
                             os.path.join(hdddir, dst_path)))

    return install_files

def runtool(cmdln_or_args):
    """ wrapper for most of the subprocess calls
    input:
        cmdln_or_args: can be both args and cmdln str (shell=True)
    return:
        rc, output
    """
    import subprocess
    import shutil

    if isinstance(cmdln_or_args, list):
        cmd = cmdln_or_args[0]
        shell = False
    else:
        import shlex
        cmd = shlex.split(cmdln_or_args)[0]
        shell = True

    sout = subprocess.PIPE
    serr = subprocess.STDOUT

    try:
        process = subprocess.Popen(cmdln_or_args, stdout=sout,
                                stderr=serr, shell=shell)
        sout, serr = process.communicate()
        # combine stdout and stderr, filter None out and decode
        out = ''.join([out.decode('utf-8') for out in [sout, serr] if out])
    except OSError as err:
        if err.errno == 2:
            # [Errno 2] No such file or directory
            bb.error('Cannot run command: %s, lost dependency?' % cmd)
        else:
            bb.error('Unknown error')
    return process.returncode, out

def _exec_cmd(cmd_and_args, as_shell=False):
    """
    Execute command, catching stderr, stdout

    Need to execute as_shell if the command uses wildcards
    """
    args = cmd_and_args.split()
    if as_shell:
        ret, out = runtool(cmd_and_args)
    else:
        ret, out = runtool(args)
    out = out.strip()
    if ret != 0:
        bb.error("_exec_cmd: %s returned '%s' instead of 0\noutput: %s" % (cmd_and_args, ret, out))
    bb.note(f"_exec_cmd: output for {cmd_and_args} (rc = {ret}): {out}")
    return ret, out

def exec_cmd(cmd_and_args, as_shell=False):
    """
    Execute command, return output
    """
    return _exec_cmd(cmd_and_args, as_shell)[1]

python do_install_boot_img() {
    install_files = do_prepare_boot_image(d)

    # we install the image parts
    for install_entry in install_files:
        src, dst = install_entry
        install_cmd = f"install -m  0644 -D {src} {dst}"
        exec_cmd(install_cmd)
    # we generate the image as ext4
    hdddir = "%s/boot.%s" % (d.getVar("WORKDIR"), "pionix")
    exec_cmd(f"tar -cJf {d.getVar('DEPLOY_DIR_IMAGE')}/boot.tar.xz -C {hdddir} .")
}

addtask install_boot_img before do_image after do_rootfs
