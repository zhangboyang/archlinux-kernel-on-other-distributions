# Install Latest ArchLinux's Kernel on Other Distributions

## Introduction

Do you want to keep up with latest kernel? However, compiling linux kernel by oneself is a time-consuming task. So why not use a pre-compiled kernel directly? :)

This script can install latest archlinux's kernel on non-archlinux distributions (CentOS & Ubuntu are tested). It will install arch's kernel & initrd along with existing kernels. If arch's kernel failed to boot, you may choose existing kernel to boot your machine.

## How to use this script?

Find an archlinux mirror [here](https://www.archlinux.org/mirrorlist/) and run this script like this: (note: the tail of mirror URL should be removed)

```sh
sudo ./get-archlinux-kernel.sh "https://mirrors.kernel.org/archlinux/"
```

After installation, the new kernel & initrd should appear in `/boot`. To load the new kernel, a reboot is required.

## Notes

It is strongly recommend to run this script AFTER **EACH** run of `yum update` or `apt upgrade`, because system upgrades may break existing modifications that previously set up by this script.

## Problems

DKMS is not handled. Also certain software with kernel version requirements may stop working. You may want to upgrade these software after installing the new kernel.

## How does this script work?

This script downloads a bootstrap image of archlinux and set up a tiny archlinux environment. After installing the latest kernel with `pacman`, the kernel & initrd are copied to the host. Although using host's tools to generate initrd is possible, I decided to use arch's native tools in order to improve compatibility.
