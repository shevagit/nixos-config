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
  # office monitor on top
  "DP-2,2560x1440@60,0x0,1"

  # embedded screen below
  "eDP-1,1920x1200@60,0x1440,1"

  # catch-all fallback
  ",preferred,auto,1"
  ];

  wayland.windowManager.hyprland.settings.device = {
    name = "gtch1563:00-2a94:a89b";
    output = "eDP-1";
  };

  # host-specific packages
  home.packages = with pkgs; [
    libnotify
  ];

}
