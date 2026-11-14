#!/usr/bin/env bash
# One command on the Arch live ISO (wired or tethered network):
#   bash <(curl -fsSL https://raw.githubusercontent.com/raulmoranguerra/arch-mbp/master/install/bootstrap.sh)
# Asks everything up front, then installs, reboots, and finishes setup on first boot by itself.
set -euo pipefail

export HOSTNAME_="${HOSTNAME_:-archbook-pro}"
export USERNAME_="${USERNAME_:-rmg}"
export TZ_NAME="${TZ_NAME:-Europe/Madrid}"
export INSTALL_CAMERA="${INSTALL_CAMERA:-0}"
TARBALL_URL="https://github.com/raulmoranguerra/arch-mbp/archive/refs/heads/master.tar.gz"

[ -d /sys/firmware/efi ] || { echo "Not booted in UEFI mode"; exit 1; }
ping -c1 -W3 archlinux.org >/dev/null || { echo "No network. Plug in ethernet or tether a phone by USB."; exit 1; }

# Target disk: the one internal, non-removable, non-USB disk
mapfile -t cands < <(lsblk -dpnro NAME,TYPE,RM,TRAN | awk '$2=="disk" && $3=="0" && $4!="usb" {print $1}')
if [ "${#cands[@]}" -eq 1 ]; then
  DISK="${cands[0]}"
else
  echo "Could not pick the internal disk automatically."
  lsblk -dpno NAME,SIZE,MODEL
  read -r -p "Disk to erase (e.g. /dev/sda): " DISK
fi
[ -b "$DISK" ] || { echo "$DISK is not a block device"; exit 1; }

echo
lsblk -po NAME,SIZE,MODEL,FSTYPE "$DISK"
echo
echo "Host: $HOSTNAME_   User: $USERNAME_   Timezone: $TZ_NAME   Disk: $DISK"
read -r -p "Type 'erase' to wipe $DISK and install: " ok
[ "$ok" = "erase" ] || { echo "Aborted."; exit 1; }

while :; do
  read -r -s -p "Password for $USERNAME_ (also used for sudo): " USER_PASS; echo
  read -r -s -p "Repeat password: " again; echo
  [ -n "$USER_PASS" ] && [ "$USER_PASS" = "$again" ] && break
  echo "Passwords did not match or were empty. Try again."
done
read -r -p "Wi-Fi SSID for first boot (blank = rely on ethernet): " WIFI_SSID
WIFI_PSK=""
[ -n "$WIFI_SSID" ] && read -r -s -p "Wi-Fi password: " WIFI_PSK && echo
read -r -p "Build the FaceTime HD camera driver too? [y/N]: " cam
[ "$cam" = "y" ] && INSTALL_CAMERA=1

export USER_PASS WIFI_SSID WIFI_PSK INSTALL_CAMERA CONFIRMED=1

# The live ISO has no git, so fetch the repo as a tarball.
if [ ! -d /root/arch-mbp ]; then
  mkdir -p /root/arch-mbp
  curl -fsSL "$TARBALL_URL" | tar -xz --strip-components=1 -C /root/arch-mbp
fi
/root/arch-mbp/install/01-live-iso.sh "$DISK" "$HOSTNAME_" "$USERNAME_"

echo
echo "Install finished. Unplug the USB stick now. Rebooting in 25 seconds."
echo "First boot will install everything else by itself (about 15-30 minutes), then reboot once more."
echo "If the Mac shows the USB again, hold Option at power-on and pick Linux Boot Manager."
sleep 25
umount -R /mnt
reboot
