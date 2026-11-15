[ -f ~/.bashrc ] && . ~/.bashrc

# Fallback only: greetd/tuigreet normally starts sway. Other TTYs stay plain shells.
if [ -z "${WAYLAND_DISPLAY:-}" ] && [ "$(tty)" = "/dev/tty1" ]; then
  export XDG_CURRENT_DESKTOP=sway
  export XDG_SESSION_TYPE=wayland
  export MOZ_ENABLE_WAYLAND=1
  export QT_QPA_PLATFORM=wayland
  export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
  export ELECTRON_OZONE_PLATFORM_HINT=wayland
  export LIBVA_DRIVER_NAME=i965
  export _JAVA_AWT_WM_NONREPARENTING=1
  exec sway
fi
