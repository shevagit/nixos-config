{ pkgs, ... }:
{
  # NVIDIA Wayland fixes for Qt6/EGL stability (fixes dms/quickshell freezes)
  environment.sessionVariables = {
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __GL_GSYNC_ALLOWED = "0";
    __GL_VRR_ALLOWED = "0";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };
  # Dank Material Shell (DMS) - replaces hyprpanel and waybar
  programs.dms-shell = {
    enable = true;
    systemd.enable = true;
  };
}