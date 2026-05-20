{ config, pkgs, lib, ... }: {
  imports = [
    ../../home
    ../../home/common
  ];
  # override home manager configuration
  wayland.windowManager.hyprland.settings.bind = [
    # Brightness control (F5/F6)
    ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
    ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
  ];

  wayland.windowManager.hyprland.settings.gesture = [
    "3, horizontal, workspace"
  ];

  # Lock screen on lid close via DMS
  wayland.windowManager.hyprland.settings.bindl = [
    ", switch:on:Lid Switch, exec, dms ipc call lock lock"
  ];

  wayland.windowManager.hyprland.settings.monitor = [
    # catch-all fallback — laptop's built-in display will use its preferred mode
    ",preferred,auto,1"
  ];

  # host-specific packages
  home.packages = with pkgs; [
    libnotify
  ];

}
