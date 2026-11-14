#!/usr/bin/env bash
# Run as your normal user after the first boot, with network up (nmtui for Wi-Fi).
# Add INSTALL_CAMERA=1 to also build the FaceTime HD camera driver (downloads Apple firmware).
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PKGS=(
  sway swaybg swayidle swaylock waybar foot fuzzel mako
  grim slurp wl-clipboard brightnessctl playerctl
  pipewire pipewire-pulse pipewire-alsa wireplumber
  xdg-desktop-portal-wlr xdg-desktop-portal-gtk polkit xorg-xwayland
  mesa libva-intel-driver libva-utils
  ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji papirus-icon-theme
  tlp thermald zram-generator earlyoom
  stow starship fastfetch btop neovim bash-completion man-db firefox mpv
)
sudo pacman -Syu --needed --noconfirm "${PKGS[@]}"

# AUR helper (prebuilt binary, avoids compiling Rust on the old CPU)
if ! command -v paru >/dev/null; then
  tmp="$(mktemp -d)"
  git clone https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin"
  (cd "$tmp/paru-bin" && makepkg -si --noconfirm)
  rm -rf "$tmp"
fi

AUR=(mbpfan-git gruvbox-gtk-theme-git)
[ "${INSTALL_CAMERA:-0}" = "1" ] && AUR+=(facetimehd-dkms facetimehd-firmware)
paru -S --needed --noconfirm "${AUR[@]}" || \
  echo "WARNING: some AUR packages failed. Check names with: paru -Ss mbpfan gruvbox"

# System tuning
sudo install -Dm644 "$REPO/system/etc/tlp.d/10-mbp.conf"                      /etc/tlp.d/10-mbp.conf
sudo install -Dm644 "$REPO/system/etc/systemd/zram-generator.conf"            /etc/systemd/zram-generator.conf
sudo install -Dm644 "$REPO/system/etc/sysctl.d/99-zram.conf"                  /etc/sysctl.d/99-zram.conf
sudo install -Dm644 "$REPO/system/etc/systemd/journald.conf.d/size.conf"      /etc/systemd/journald.conf.d/size.conf
sudo systemctl daemon-reload
sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket
sudo systemctl enable --now tlp thermald earlyoom
sudo systemctl enable mbpfan 2>/dev/null || sudo systemctl enable mbpfan.service || true
sudo systemctl start systemd-zram-setup@zram0.service || true
sudo sysctl --system >/dev/null

# Dotfiles: move aside anything that would conflict, then symlink with stow
mkdir -p "$HOME/Pictures"
for f in .bashrc .bash_profile; do
  [ -e "$HOME/$f" ] && [ ! -L "$HOME/$f" ] && mv "$HOME/$f" "$HOME/$f.bak"
done
stow -d "$REPO" -t "$HOME" dotfiles
chmod +x "$HOME/.local/bin/powermenu" || true

echo
echo "Done. Log out and back in on tty1 to start sway."
echo "Check power: sudo tlp-stat -s ; sudo powertop (optional) ; systemd-analyze"
