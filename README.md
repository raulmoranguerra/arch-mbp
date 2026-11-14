# arch-mbp

Arch Linux on a 2015 15" retina MacBook Pro (MacBookPro11,x): sway, retro Gruvbox, tuned for efficiency.

Sway, Waybar and mako structure adapted from [Ruixi-rebirth/sway-dotfiles](https://github.com/Ruixi-rebirth/sway-dotfiles) (GPL-3.0, so this repo is GPL-3.0 too). A local clone of the original sits in `upstream/` for reference. It is git-ignored and never installed.

## Layout

| Path | What |
|---|---|
| `install/01-live-iso.sh` | From the live ISO: partition, format, pacstrap, then run step 2 |
| `install/02-chroot.sh` | Inside the chroot: locale, user, systemd-boot, Wi-Fi driver choice |
| `install/03-post.sh` | After first boot: packages, AUR, services, power tuning, stow dotfiles |
| `dotfiles/` | Stow package: sway, waybar, foot, fuzzel, mako, swaylock, bash |
| `system/etc/` | tlp, zram, sysctl, journald, modprobe settings |

## Install

1. Update macOS firmware if you still can. The disk is wiped, so back up first.
2. Write the Arch ISO to a USB stick. Hold Option at boot and pick the EFI drive.
3. Get a network on the live ISO: USB-C ethernet or phone USB tether. The Broadcom Wi-Fi does not work until after install.
4. Put this folder on the live ISO (git clone from your own remote, or copy it from a second USB stick), then:

```bash
TZ_NAME=Europe/Madrid ./install/01-live-iso.sh /dev/sda myhost myuser
```

Check the disk name with `lsblk` first (`/dev/sda` is typical on this model, `/dev/nvme0n1` if swapped). Set `TZ_NAME` to your timezone.

5. Reboot, hold Option, pick "Linux Boot Manager", log in on tty1, then:

```bash
nmtui                      # connect Wi-Fi
~/arch-mbp/install/03-post.sh
```

Add `INSTALL_CAMERA=1` before the command to also build the FaceTime HD camera driver. Log out and back in on tty1 and sway starts.

## Things to verify on the real machine

- AUR package names (`mbpfan-git`, `gruvbox-gtk-theme-git`) and the GTK theme name set in `sway/config` can drift. If the theme does not apply, run `gsettings get org.gnome.desktop.interface gtk-theme` after picking one with `nwg-look` or check `ls /usr/share/themes`.
- Wi-Fi: the script picks `broadcom-wl-dkms` only if the chip is a BCM4360 (`14e4:43a0`), otherwise the in-kernel `brcmfmac`.
- 11,5 models with the AMD GPU: check it powers down with `sudo powertop` or `cat /sys/kernel/debug/vgaswitcheroo/switch`.
- Waybar CPU temperature path assumes `coretemp` (Intel). Check `ls /sys/devices/platform/coretemp.0/hwmon`.
- Not encrypted. Add LUKS if the laptop leaves the house.

## Wallpapers

`dotfiles/.config/wallpapers/` has seven pixel-art wallpapers (`ruins.png` is the default; others: `castle`, `pacman`, `fortress-sunset`, `glowing-tree`, `city-dusk`, `iso-city`) taken from the MIT-licensed [frenzyexists/wallpapers](https://github.com/frenzyexists/wallpapers) collection (licence text alongside). The individual artists are not credited in that repo. To switch, edit the `output * bg` line in the sway config.

## Keys

Super is the Command key. `Super+Return` terminal, `Super+d` launcher, `Super+Shift+q` close, `Super+Escape` lock, `Super+Shift+e` power menu, `Super+1..9` workspaces, `Super+r` resize mode. Full list in `dotfiles/.config/sway/config`.

## Efficiency choices

No display manager, no animations or blur, integer HiDPI scale 2, one static wallpaper (no wallpaper daemon), zram instead of swap, tlp with battery-first settings, Waybar polling at 5 to 30 second intervals, text labels instead of icon fonts.
