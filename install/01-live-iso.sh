#!/usr/bin/env bash
# Run from the Arch live ISO (UEFI boot, wired or tethered network).
# DESTROYS the target disk. Usage: ./01-live-iso.sh /dev/sda HOSTNAME USERNAME
set -euo pipefail

DISK="${1:?usage: $0 /dev/DISK HOSTNAME USERNAME}"
HOSTNAME_="${2:?hostname missing}"
USERNAME_="${3:?username missing}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

[ -d /sys/firmware/efi ] || { echo "Not booted in UEFI mode"; exit 1; }
[ -b "$DISK" ] || { echo "$DISK is not a block device"; exit 1; }
ping -c1 -W3 archlinux.org >/dev/null || { echo "No network. Use ethernet or phone USB tether."; exit 1; }

lsblk "$DISK"
echo
echo "This will ERASE EVERYTHING on $DISK."
read -r -p "Type the disk path again to confirm: " confirm
[ "$confirm" = "$DISK" ] || { echo "Aborted."; exit 1; }

case "$DISK" in
  *nvme*|*mmcblk*) P="${DISK}p" ;;
  *) P="$DISK" ;;
esac

timedatectl set-ntp true
sgdisk --zap-all "$DISK"
sgdisk -n1:0:+512M -t1:ef00 -c1:EFI  "$DISK"
sgdisk -n2:0:0     -t2:8300 -c2:root "$DISK"
partprobe "$DISK"; sleep 1

mkfs.fat -F32 "${P}1"
mkfs.ext4 -F -L arch "${P}2"
mount -o noatime "${P}2" /mnt
mkdir -p /mnt/boot
mount "${P}1" /mnt/boot

pacstrap -K /mnt base linux linux-headers linux-firmware intel-ucode \
  networkmanager sudo base-devel git vim pciutils dkms broadcom-wl-dkms

genfstab -U /mnt > /mnt/etc/fstab
sed -i 's/relatime/noatime/' /mnt/etc/fstab

mkdir -p /mnt/root
cp -r "$REPO_DIR" /mnt/root/arch-mbp
arch-chroot /mnt env HOSTNAME_="$HOSTNAME_" USERNAME_="$USERNAME_" \
  TZ_NAME="${TZ_NAME:-UTC}" ROOT_PART="${P}2" \
  /root/arch-mbp/install/02-chroot.sh

echo
echo "Done. Run: umount -R /mnt && reboot (hold Option and pick 'Linux Boot Manager')."
echo "After login, run ~/arch-mbp/install/03-post.sh"
