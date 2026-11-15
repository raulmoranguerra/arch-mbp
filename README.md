# arch-mbp

Arch Linux on a 2015 15" retina MacBook Pro (MacBookPro11,x): Hyprland in black and white, tuned for efficiency.

The look and Waybar/rofi/kitty/dunst styling are adapted from [ad1822/hyprdots](https://github.com/ad1822/hyprdots) (MIT, licence in `LICENSE-hyprdots`). The first iteration was based on [Ruixi-rebirth/sway-dotfiles](https://github.com/Ruixi-rebirth/sway-dotfiles) (GPL-3.0, so this repo is GPL-3.0 too).

## Layout

| Path | What |
|---|---|
| `install/01-live-iso.sh` | From the live ISO: partition, format, pacstrap, then run step 2 |
| `install/02-chroot.sh` | Inside the chroot: locale, user, systemd-boot, Wi-Fi driver choice |
| `install/03-post.sh` | After first boot: packages, AUR, services, power tuning, stow dotfiles |
| `stow/common/` | Shared stow package: Hyprland config (Lua), Waybar, kitty, rofi, dunst, fish, starship |
| `stow/theme-catppuccin/` | Catppuccin Mocha look (optional) with pixel-art wallpapers |
| `stow/theme-mono/` | Black and white look (default for both Macs) with monochrome wallpapers |
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

5. When it says so, unplug the USB stick. The Mac reboots, a first-boot service installs everything else (about 15 to 30 minutes, log in `/var/log/arch-mbp-firstboot.log`) and reboots once more. Then log in on tty1 and Hyprland starts. If the Mac shows the USB again, hold Option and pick Linux Boot Manager.

SSH is on after first boot (key-only, no passwords): `ssh rmg@archbook-pro.local`. The authorised key is in `system/ssh/authorized_keys`.

Manual path: run `install/01-live-iso.sh DISK HOST USER` yourself, reboot, then run `install/03-post.sh` (add `INSTALL_CAMERA=1` for the camera driver). Without the bootstrap there is no first-boot service.

During first boot the user has passwordless sudo, removed again when the service succeeds. If it fails (for example no network), check the log, fix it, and reboot to retry.

## Things to verify on the real machine

- Fans are left to the Mac's own controller (`mbpfan` fails on current kernels, which dropped `fan*_output`). Check with `cat /sys/class/hwmon/hwmon*/fan*_input`. The Hyprland config is Lua for Hyprland 0.57, so some option names may need adjusting on the real machine (check `hyprctl configerrors`).
- Wi-Fi: the script picks `broadcom-wl-dkms` only if the chip is a BCM4360 (`14e4:43a0`), otherwise the in-kernel `brcmfmac`.
- 11,5 models with the AMD GPU: check it powers down with `sudo powertop` or `cat /sys/kernel/debug/vgaswitcheroo/switch`.
- Waybar CPU temperature path assumes `coretemp` (Intel). Check `ls /sys/devices/platform/coretemp.0/hwmon`.
- Not encrypted. Add LUKS if the laptop leaves the house.

## Wallpapers

`stow/theme-catppuccin/.config/wallpapers/` has sixteen wallpapers (mostly pixel art) (`ctp-evening-sky.jpg` is the default, from the MIT-licensed Catppuccin wallpaper set (`ctp-*.jpg`, licence alongside); the pixel art is `ruins.png` and friends; others: `castle`, `pacman`, `fortress-sunset`, `glowing-tree`, `city-dusk`, `iso-city`, `night-moons`, `moonlit-bridge`, `sepia-street`, `bamboo-moon`, `castle-hike`, plus cyberpunk-style `neon-diamond`, `neon-shibuya`, `retro-car`, `vaporwave`) taken from the MIT-licensed [frenzyexists/wallpapers](https://github.com/frenzyexists/wallpapers) collection (licence text alongside). The individual artists are not credited in that repo. To switch, edit the `path` line in `~/.config/hypr/hyprpaper.conf`.

The black and white theme (`stow/theme-mono/`) has six monochrome wallpapers from the same collection: `moon` (default), `stars-rocket`, `shuttle`, `night-station`, `storm-rail`, `mountain`.

## Machines and themes

The installer reads the Mac model from DMI and picks defaults: `MacBookAir*` gets host `archbook-air`, theme `mono`, scale 1 (1440x900, not Retina). Anything else (the 2015 Pro) gets host `archbook-pro`, theme `mono` (also `catppuccin`), scale 2. Override with `HOSTNAME_`, `THEME` (`catppuccin` or `mono`) and `SCALE` before the command. The scale lives in a generated `~/.config/hypr/host.lua`, the look in the stowed `~/.config/hypr/theme.lua`.

To add a theme, copy a `stow/theme-*` folder, change the colours, and set `THEME=yourname`.

## Keys

Mod is the Option (Alt) key. Command and Control are swapped, so Cmd+C/V/T/W work like macOS in apps (Cmd+Shift+C/V in the terminal). `Option+Return` terminal (kitty), `Option+d` launcher (rofi), `Option+Shift+q` close, `Option+Escape` log out to the tuigreet login, `Option+Shift+e` power menu, `Option+1..9` workspaces, `Option+=`/`Option+-` resize column, `Option+Tab` previous workspace. Full list in `stow/common/.config/hypr/hyprland.lua`.

## Battery notes

Measured on the 2015 Pro: about 13 W with the screen on at 10% brightness, 17 to 18 W at 65%, and 7 W with the screen off. The panel has no self-refresh, so the CPU package cannot sleep deeply while the screen is lit; brightness and screen-off time are the levers that matter. The screen dims after 2 minutes idle, turns off at 5 and the laptop suspends at 10. The boot entry uses `acpi_osi=!Darwin`, which lets the firmware power down Thunderbolt (about 0.7 W); plug Thunderbolt devices in before power-on, or remove that option.

## Efficiency choices

No display manager, no animations or blur, integer HiDPI scale 2, one static wallpaper (no wallpaper daemon), zram instead of swap, tlp with battery-first settings, Waybar polling at 5 to 30 second intervals, text labels instead of icon fonts.
