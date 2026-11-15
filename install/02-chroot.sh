#!/usr/bin/env bash
# Runs inside arch-chroot, called by 01-live-iso.sh.
set -euo pipefail
: "${HOSTNAME_:?}" "${USERNAME_:?}" "${ROOT_PART:?}"
TZ_NAME="${TZ_NAME:-UTC}"
SRC=/root/arch-mbp

ln -sf "/usr/share/zoneinfo/$TZ_NAME" /etc/localtime
hwclock --systohc
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "$HOSTNAME_" > /etc/hostname

# Wi-Fi: BCM4360 (14e4:43a0) needs the wl driver. Others use in-kernel brcmfmac.
if lspci -nn | grep -qi '14e4:43a0'; then
  echo "Wi-Fi chip: BCM4360 -> using broadcom-wl-dkms"
  install -Dm644 "$SRC/system/etc/modprobe.d/broadcom-wl.conf" /etc/modprobe.d/broadcom-wl.conf
else
  echo "Wi-Fi chip is not a BCM4360 -> removing broadcom-wl-dkms, using brcmfmac"
  lspci -nn | grep -i network || true
  pacman -Rns --noconfirm broadcom-wl-dkms || true
fi

install -Dm644 "$SRC/system/etc/modprobe.d/hid_apple.conf" /etc/modprobe.d/hid_apple.conf

mkinitcpio -P

# systemd-boot (also writes the EFI/BOOT fallback path that Apple firmware finds)
bootctl install
PARTUUID="$(blkid -s PARTUUID -o value "$ROOT_PART")"
cat > /boot/loader/loader.conf <<EOF
default arch.conf
timeout 2
editor no
EOF
cat > /boot/loader/entries/arch.conf <<EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root=PARTUUID=$PARTUUID rw quiet nowatchdog
EOF

useradd -m -G wheel -s /bin/bash "$USERNAME_"
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
cp -r "$SRC" "/home/$USERNAME_/arch-mbp"
chown -R "$USERNAME_:$USERNAME_" "/home/$USERNAME_/arch-mbp"

if [ -n "${USER_PASS:-}" ]; then
  echo "$USERNAME_:$USER_PASS" | chpasswd
  passwd -l root        # root locked, use sudo
else
  echo "Set the root password:";  passwd
  echo "Set the password for $USERNAME_:"; passwd "$USERNAME_"
fi

# Optional Wi-Fi profile so first boot can reach the network without ethernet
if [ -n "${WIFI_SSID:-}" ]; then
  install -d -m 755 /etc/NetworkManager/system-connections
  umask 077
  cat > /etc/NetworkManager/system-connections/firstboot.nmconnection <<EOF
[connection]
id=$WIFI_SSID
uuid=$(cat /proc/sys/kernel/random/uuid)
type=wifi
autoconnect=true

[wifi]
mode=infrastructure
ssid=$WIFI_SSID

[wifi-security]
key-mgmt=wpa-psk
psk=$WIFI_PSK

[ipv4]
method=auto

[ipv6]
method=auto
EOF
  chmod 600 /etc/NetworkManager/system-connections/firstboot.nmconnection
  umask 022
fi

# First-boot automation: run 03-post.sh once after the first boot, then reboot.
if [ -n "${USER_PASS:-}" ]; then
  { echo "INSTALL_CAMERA=${INSTALL_CAMERA:-0}"; [ -n "${THEME:-}" ] && echo "THEME=$THEME"; true; } > /var/lib/arch-mbp-firstboot
  echo "$USERNAME_ ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99-firstboot
  chmod 440 /etc/sudoers.d/99-firstboot
  sed "s/__USER__/$USERNAME_/g" "$SRC/system/etc/systemd/system/arch-mbp-firstboot.service" \
    > /etc/systemd/system/arch-mbp-firstboot.service
  systemctl enable arch-mbp-firstboot.service NetworkManager-wait-online.service
fi

systemctl enable NetworkManager fstrim.timer
