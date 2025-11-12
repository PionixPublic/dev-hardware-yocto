# How to use Belaybox and build an Yocto image

## Step 1: Clone this repository
Create a folder (e.g. pionix) where everything will be placed.

```
mkdir pionix
cd pionix
git clone git@github.com:PionixPublic/dev-hardware-yocto.git
```

## Step 2: Run the setup tool
We are using a tool part of this repository (you find it in the root folder) to sync and initialize the meta layers and prepare everything for the build.
The tool supports 2 operations `init` and `sync`.

```
$ ./setup --help
usage: setup [-h] [--init] [--sync] [--sync_method {fetch,pull}]

Creates the layer structure and synchronizes it

optional arguments:
  -h, --help            show this help message and exit
  --init                Initializes the entire Yocto structure
  --sync                Synchronizes the layers to the given revision or to the given branch HEAD
  --sync_method {fetch,pull}
                        Synchronization method
```

The very first time you want to initialize the layers so all you have to do is to run the tool with the argument `--init`:
```
$ ./setup --init
```

The tool will run and sync the repositories.
Eventually, if you make any changes to the layers or somebody made changes and you want to sync those changes locally you run it with the option `--sync`. This allows you to sync locally the changes made in the upstream. If you made changes as well to the layers you want to sync, you might want to specify how to sync (`fetch` or `pull`) so that you can have the possibility to rebase or merge the changes. By default the method is `fetch` if no argument is provided.

## Step 3: Build the image
The Belaybox repo comes with a build directory (containing only the config folder).
In the config folder there is a default configuration file `local.conf` and the layers configuration `bblayers.conf`.

### Configure the build
There are a lot of configuration parameters available, however, the most interesting ones are:

```
# Build with EVERYTHING to synchronized to HEAD revision
BELAYBOX_UNSTABLE = "1"
```
You can change them to your needs before building.

### Build the image
To start building the image you need to source the yocto environment:

```
$ source ../source/poky/oe-init-build-env
### Shell environment set up for builds. ###

You can now run 'bitbake <target>'

Common targets are:
    core-image-minimal
    core-image-full-cmdline
    core-image-sato
    core-image-weston
    meta-toolchain
    meta-ide-support

You can also run generated qemu images with a command like 'runqemu qemux86'

Other commonly useful commands are:
 - 'devtool' and 'recipetool' handle common recipe tasks
 - 'bitbake-layers' handles common layer tasks
 - 'oe-pkgdata-util' handles common target package tasks
```
You are ready to build an image or a bundle that you can flash with rauc tool.
If you just want the image run:

```
$ bitbake belaybox-image
```

If you want the rauc bundle, run:

```
$ bitbake belaybox-bundle
```

Depending on your computer you might need to go for a coffee a walk or both.
Let it run. At the end you should see something like this:

```
$ bitbake belaybox-bundle
Loading cache: 100% |###################################################################################| Time: 0:00:00
Loaded 4433 entries from dependency cache.
NOTE: Resolving any missing task queue dependencies

Build Configuration:
BB_VERSION           = "2.0.0"
BUILD_SYS            = "x86_64-linux"
NATIVELSBSTRING      = "universal"
TARGET_SYS           = "arm-poky-linux-gnueabi"
MACHINE              = "raspberrypi4"
DISTRO               = "poky"
DISTRO_VERSION       = "4.0.16"
TUNE_FEATURES        = "arm vfp cortexa7 neon vfpv4 thumb callconvention-hard"
TARGET_FPU           = "hard"
meta
meta-poky
meta-yocto-bsp       = "HEAD:b3e316e8486e5462c3c71a9c8248779a5c253385"
meta-arm
meta-arm-toolchain   = "HEAD:b187fb9232ca0a6b5f8f90b4715958546fc41d73"
meta-raspberrypi     = "HEAD:9dc6673d41044f1174551120ce63501421dbcd85"
meta-oe
meta-multimedia
meta-networking
meta-python
meta-perl            = "HEAD:fda737ec0cc1d2a5217548a560074a8e4d5ec580"
meta-lts-mixins      = "HEAD:b8a6349ec476c0a38436be7503ef963f49c2c461"
meta-rauc            = "HEAD:ed6dc67ffb143a4c4fac01e0b7e8a60fc6260b85"
meta-flutter         = "HEAD:2626dfec92ffd3dbf810d571b9f7ede13bf56591"
meta-clang           = "HEAD:312ff1c39b1bf5d35c0321e873417eb013cea477"
meta-security
meta-tpm             = "HEAD:cc20e2af2ae1c74e306f6c039c4963457c4cbd0f"
meta-everest         = "HEAD:65fdec15eb6c6503ea5e43b6884253ba1284d58e"
meta-belaybox        = "kirkstone:bb4fe6e950e268c6d24a4f25dced8ebcd63fdaa5"

Initialising tasks: 100% |###################################################################################| Time: 0:00:02
Sstate summary: Wanted 2847 Local 2844 Mirrors 0 Missed 3 Current 0 (99% match, 0% complete)
NOTE: Executing Tasks
NOTE: Tasks Summary: Attempted 6953 tasks of which 6938 didn't need to be rerun and all succeeded.
```
The image file or the bundle will be located in the subfolder of the `build` folder: `tmp/deploy/images/raspberrypi4/` and are called `belaybox-image-raspberrypi4.wic.bz2` respectivelly `belaybox-bundle-raspberrypi4.raucb`.

## Step 4: Flash the image or the bundle on your target
For the image solution is possible only if target has an SD Card that you can remove and flash it on the host side.

### Update your target with the belaybox-image
> **Warning:** Before you do this step, please double check which device is your SD Card that you want to flash, otherwise you risk to damage your host system
```
cd pionix/belaybox/build
sudo umount /dev/sd<a,b ... chech this>*
cd tmp/deploy/images/raspberrypi4/
sudo bmaptool copy belaybox-image-raspberrypi4.wic.bz2 /dev/sd<a,b ... chech this>
```

### Update your target with the bundle you just created
There are 2 methods to do this as we speak, as OTA - using a small HTTP server or have the image copied locally on the target (scp, USB stick, etc).


#### Using OTA

##### Run this on your host
```
cd pionix/belaybox/build
cd tmp/deploy/images/raspberrypi4/
ifconfig <check the ip address of your host, you need this in the next step>
pip install rangehttpserver
python3 -m RangeHTTPServer
```

##### Run this on your target
```
rauc install http://<the_ip_address_of_your_host_and_the_port>/belaybox-bundle-raspberrypi4.raucb
```
> **Warning:** This will overwrite the content of your target. Make sure you don't have something that you would like to keep before flashing.

Once the update has finished, you can test the new image with this command: ```reboot '0 tryboot'```

#### Using local copy of the image
Altenate method: you can copy the image on a device (e.g. USB stick) and use the following commands (once the device is mounted on the target):
```
rauc install /<path_to_the_image_file>/belaybox-bundle-raspberrypi4.raucb
tryboot
```
```tryboot``` is an alias to boot the target and try the newly flashed image. A simple reboot will NOT boot the new image.

## Step 5: Update the layers by making changes in setup script
In order to make any changes to the yocto layers (add, remove or update) you have to change the setup script.
If you open the script in a file editor, at the top, you will find listed the layers with the branches and the commit id.
It should look something like this:
```
remotes = [
    {"name": "yocto",        "url": "git://git.yoctoproject.org"},
    {"name": "openembedded", "url": "git://git.openembedded.org"},
    {"name": "github",       "url": "https://github.com"},
    {"name": "github-ssh",   "url": "ssh://git@github.com"}
]

layers = [
    {"rev":"fda737ec0cc1d2a5217548a560074a8e4d5ec580",  "branch":"kirkstone",  "repo":"meta-openembedded",                "path":"meta-openembedded",  "remote":"openembedded"},
    {"rev":"b3e316e8486e5462c3c71a9c8248779a5c253385",  "branch":"kirkstone",  "repo":"poky",                             "path":"poky",               "remote":"yocto"},
    {"rev":"b187fb9232ca0a6b5f8f90b4715958546fc41d73",  "branch":"kirkstone",  "repo":"meta-arm",                         "path":"meta-arm",           "remote":"yocto"},
    {"rev":"9dc6673d41044f1174551120ce63501421dbcd85",  "branch":"kirkstone",  "repo":"meta-raspberrypi",                 "path":"meta-raspberrypi",   "remote":"yocto"},
    {"rev":"6a2f191dc57067cfe87b1a1505b622295bf66fe7",  "branch":"kirkstone",  "repo":"meta-flutter/meta-flutter",        "path":"meta-flutter",       "remote":"github"},
    {"rev":"312ff1c39b1bf5d35c0321e873417eb013cea477",  "branch":"kirkstone",  "repo":"kraj/meta-clang",                  "path":"meta-clang",         "remote":"github"},
    {"rev":"ed6dc67ffb143a4c4fac01e0b7e8a60fc6260b85",  "branch":"kirkstone",  "repo":"rauc/meta-rauc",                   "path":"meta-rauc",          "remote":"github"},
    {"rev":"",                                          "branch":"kirkstone",  "repo":"EVerest/meta-everest",           "path":"meta-everest",      "remote":"github"},
]
```
If you add a layer(s) after you add it, run the script with `--init` option to get its contents locally synchronized and test your change.
If you change the commit id, run it with the option `--sync`.
If somebody else changed the script, once you pull or fetch the changes in the dev-hardware-yocto repository, the script will run automatically to reflect their changes locally. This happens only if you initialized your layers (aka run `setup --init`) at least once.
