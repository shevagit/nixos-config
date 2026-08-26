{ pkgs, ... }:
{
  environment.sessionVariables = {
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };
  # Dank Material Shell (DMS) - replaces hyprpanel and waybar
  programs.dms-shell = {
    enable = true;
    systemd.enable = true;
  };
  # UWSM marks graphical-session ready as soon as Hyprland notifies, which is
  # before lua config/layer-shell is finished. DMS then maps wallpaper, calls
  # `hyprctl reload`, and wedges at ~100% CPU with no dms:bar surfaces.
  # A short delay lets the compositor finish; restarting dms after login also
  # recovers a wedged instance.
  systemd.user.services.dms.serviceConfig.ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
}