#!/bin/sh
# Power menu with a confirmation step for the destructive actions.
theme="$HOME/.config/rofi/powermenu.rasi"
up=$(uptime -p | sed 's/^up //')
choice=$(printf 'Suspend\nLogout\nReboot\nShutdown\n' | rofi -dmenu -p "$USER" -mesg "Uptime: $up" -theme "$theme") || exit 0
case "$choice" in
  Suspend) exec systemctl suspend ;;
esac
[ "$(printf 'Yes\nNo\n' | rofi -dmenu -p "$choice?" -mesg "Are you sure?" -theme "$theme")" = "Yes" ] || exit 0
case "$choice" in
  Logout)   hyprctl dispatch exit ;;
  Reboot)   systemctl reboot ;;
  Shutdown) systemctl poweroff ;;
esac
