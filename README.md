# arch-mbp

Arch Linux on a 2015 15" retina MacBook Pro (MacBookPro11,x): sway, retro Gruvbox, tuned for efficiency.

Sway, Waybar and mako structure adapted from [Ruixi-rebirth/sway-dotfiles](https://github.com/Ruixi-rebirth/sway-dotfiles) (GPL-3.0, so this repo is GPL-3.0 too). A local clone of the original sits in `upstream/` for reference. It is git-ignored and never installed.

## Layout

| Path | What |
|---|---|
| `install/01-live-iso.sh` | From the live ISO: partition, format, pacstrap, then run step 2 |
| `install/02-chroot.sh` | Inside the chroot: locale, user, systemd-boot, Wi-Fi driver choice |
| `install/03-post.sh` | After first boot: packages, AUR, services, power tuning, stow dotfiles |
| `stow/common/` | Shared stow package: sway keybinds, Waybar layout, bash, power menu |
| `stow/theme-gruvbox/` | Retro Gruvbox look (default for the 2015 Pro) with pixel-art wallpapers |
| `stow/theme-mono/` | Black and white look (default for the 2017 Air) with monochrome wallpapers |
| `system/etc/` | tlp, zram, sysctl, journald, modprobe settings |

## Install

1. Update macOS firmware if you still can. The disk is wiped, so back up first.
2. Write the Arch ISO to a USB stick. Hold Option at boot and pick the EFI drive.
3. Get a network on the live ISO: USB-C ethernet or phone USB tether. The Broadcom Wi-Fi does not work until after install.
4. On the live ISO, run one command. It asks everything up front (erase confirmation, password, optional Wi-Fi, camera driver), then runs unattended:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/raulmoranguerra/arch-mbp/master/install/bootstrap.sh)
```

Defaults are host `archbook-pro`, user `rmg`, timezone `Europe/Madrid`, Spanish keyboard (`es`). Override with `HOSTNAME_`, `USERNAME_`, `TZ_NAME`, `KB_LAYOUT` (for example `us`) before the command. With the Spanish layout on an Apple keyboard, `~` is right Option + 4 and `|` is right Option + 1. The internal disk is detected automatically (it asks if there is more than one candidate).

5. When it says so, unplug the USB stick. The Mac reboots, a first-boot service installs everything else (about 15 to 30 minutes, log in `/var/log/arch-mbp-firstboot.log`) and reboots once more. Then log in on tty1 and sway starts. If the Mac shows the USB again, hold Option and pick Linux Boot Manager.

Manual path: run `install/01-live-iso.sh DISK HOST USER` yourself, reboot, then run `install/03-post.sh` (add `INSTALL_CAMERA=1` for the camera driver). Without the bootstrap there is no first-boot service.

During first boot the user has passwordless sudo, removed again when the service succeeds. If it fails (for example no network), check the log, fix it, and reboot to retry.

## Things to verify on the real machine

- AUR package names (`mbpfan-git`, `gruvbox-gtk-theme-git`) and the GTK theme name set in `sway/config` can drift. If the theme does not apply, run `gsettings get org.gnome.desktop.interface gtk-theme` after picking one with `nwg-look` or check `ls /usr/share/themes`.
- Wi-Fi: the script picks `broadcom-wl-dkms` only if the chip is a BCM4360 (`14e4:43a0`), otherwise the in-kernel `brcmfmac`.
- 11,5 models with the AMD GPU: check it powers down with `sudo powertop` or `cat /sys/kernel/debug/vgaswitcheroo/switch`.
- Waybar CPU temperature path assumes `coretemp` (Intel). Check `ls /sys/devices/platform/coretemp.0/hwmon`.
- Not encrypted. Add LUKS if the laptop leaves the house.

## Wallpapers

`stow/theme-gruvbox/.config/wallpapers/` has sixteen wallpapers (mostly pixel art) (`ruins.png` is the default; others: `castle`, `pacman`, `fortress-sunset`, `glowing-tree`, `city-dusk`, `iso-city`, `night-moons`, `moonlit-bridge`, `sepia-street`, `bamboo-moon`, `castle-hike`, plus cyberpunk-style `neon-diamond`, `neon-shibuya`, `retro-car`, `vaporwave`) taken from the MIT-licensed [frenzyexists/wallpapers](https://github.com/frenzyexists/wallpapers) collection (licence text alongside). The individual artists are not credited in that repo. To switch, edit the `output * bg` line in `~/.config/sway/theme.conf`.

The black and white theme (`stow/theme-mono/`) has six monochrome wallpapers from the same collection: `moon` (default), `stars-rocket`, `shuttle`, `night-station`, `storm-rail`, `mountain`.

## Machines and themes

The installer reads the Mac model from DMI and picks defaults: `MacBookAir*` gets host `archbook-air`, theme `mono`, sway scale 1 (1440x900, not Retina). Anything else (the 2015 Pro) gets host `archbook-pro`, theme `gruvbox`, scale 2. Override with `HOSTNAME_`, `THEME` (`gruvbox` or `mono`) and `SCALE` before the command. The scale lives in a generated `~/.config/sway/host.conf`, the look in the stowed `~/.config/sway/theme.conf`.

To add a theme, copy a `stow/theme-*` folder, change the colours, and set `THEME=yourname`.

## Keys

Super is the Command key. `Super+Return` terminal, `Super+d` launcher, `Super+Shift+q` close, `Super+Escape` lock, `Super+Shift+e` power menu, `Super+1..9` workspaces, `Super+r` resize mode. Full list in `stow/common/.config/sway/config`.

## Efficiency choices

No display manager, no animations or blur, integer HiDPI scale 2, one static wallpaper (no wallpaper daemon), zram instead of swap, tlp with battery-first settings, Waybar polling at 5 to 30 second intervals, text labels instead of icon fonts.
