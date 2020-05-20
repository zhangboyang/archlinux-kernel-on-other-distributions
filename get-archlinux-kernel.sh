#!/bin/bash

TMPDIR=/tmp/tmp_archlinux
ARCHMIRROR="$1"
SUFFIX="-archlinux"

############

if [ -z "${ARCHMIRROR}" ]; then
    echo "Usage:"
    echo "  $0 [ARCHLINUX_MIRROR_URL]"
    echo
    echo "Example:"
    echo "  $0 \"https://mirrors.kernel.org/archlinux/\""
    echo
    exit 1
fi

rm -rf "${TMPDIR}" && mkdir -p "${TMPDIR}" && cd "${TMPDIR}" && (

echo "Downloading latest archlinux bootstrap image ..."
BOOTSTRAP=$( curl -L "${ARCHMIRROR}/iso/latest/sha1sums.txt" | grep -o '[^ ]*bootstrap[^ ]*' | head -n1 )
(curl -L "${ARCHMIRROR}/iso/latest/${BOOTSTRAP}" | tar xz) && cd root.x86_64 && (

sed -i -e 's/^CheckSpace/#CheckSpace/' etc/pacman.conf
echo "Server = ${ARCHMIRROR}/\$repo/os/\$arch" >> etc/pacman.d/mirrorlist

echo "Installing archlinux to temp directory ..."
./bin/arch-chroot "$( pwd )" << 'EOF'
pacman-key --init
pacman-key --populate archlinux
pacstrap /mnt base linux linux-headers linux-firmware lvm2
EOF

echo "Generating initramfs ..."
./bin/arch-chroot "$( pwd )/mnt" << 'EOF'
sed -i /etc/mkinitcpio.conf -e '/HOOK/s/filesystems/lvm2 filesystems/'
mkinitcpio -p linux
EOF

echo "Copying kernel files ..."
KVER=$( ls mnt/lib/modules/ | head -n1 )
[ ! -z "${KVER}" ] && (

cp mnt/boot/vmlinuz-linux /boot/vmlinuz-${KVER}${SUFFIX}
cp mnt/boot/initramfs-linux-fallback.img /boot/initrd.img-${KVER}${SUFFIX}
cp -r mnt/lib/modules/${KVER} /lib/modules/

echo "Uncompressing kernel modules ..."
# workaround compressed kernel modules
cd /lib/modules/${KVER} && (
for i in $( find -type f -name '*.xz' | sort ); do
    xz -f -d $i
    ln -n -f ${i%.xz} $i
done

echo "Running depmod ..."
depmod -a ${KVER}

[ -L /sbin/init ] && (
echo "Creating archlinux style symbolic link for /sbin/init ..."
ln -n -f -s "..$( readlink -f /sbin/init )" /sbin/init
)

echo "Updating grub config ..."
update-grub || (
    [ -e /boot/grub2/grub.cfg ] && grub2-mkconfig --output=/boot/grub2/grub.cfg
) || (
    echo "I don't know how to update grub config."
)

echo
echo "Finished!"
echo "You may want to change grub settings to boot archlinux kernel by default."
echo
) ) ) )
