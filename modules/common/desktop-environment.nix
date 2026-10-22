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

  # File manager. gvfs provides trash, MTP and network locations (udisks2,
  # already on, handles USB drives).
  environment.systemPackages = [ pkgs.nautilus ];
  services.gvfs.enable = true;
  # Lands in /etc/xdg/mimeapps.list, so any choice made in
  # ~/.config/mimeapps.list still wins. Without it folders opened in VS Code.
  xdg.mime.defaultApplications."inode/directory" = "org.gnome.Nautilus.desktop";
}