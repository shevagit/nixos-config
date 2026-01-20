{
  xdg.gsettings = {
    enable = true;
    extraSettings = {
      "org.gnome.mutter" = {
        "edge-tiling" = true;
      };
    };
  };

  # XDG Desktop Portal for file choosers and other desktop integration
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal
      xdg-desktop-portal-gtk  # Needed for file chooser
    ];
    config.common.default = "*";
  };
}
