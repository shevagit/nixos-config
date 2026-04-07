{ config, pkgs, lib, ... }: {
  imports = [
    ../../home
    ../../home/common
  ];
  # override home manager configuration
  wayland.windowManager.hyprland.settings.monitor = [
  # office monitor on top
  "DP-1,2560x1440@60,0x0,1"

  # embedded screen below
  "eDP-1,1920x1080@60,0x1440,1"

  # catch-all fallback
  ",preferred,auto,1"
  ];
  
  # host-specific packages
  home.packages = with pkgs; [
    libnotify # add notify-send for battery notifications
  ];

}
