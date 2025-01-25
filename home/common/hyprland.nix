{ pkgs, lib, ... }: 
                                                                          
{
  programs.terminator = {
    enable = true;
  };
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
    monitor = [
      "DP-3,2560x1440@164,0x0,scale=1,transform=none"
      "DP-2,1080x1920@60,2560x0,scale=1,transform=90"
    ];


      # exec-once = "swaybg -o DP-3 -i ~/wallpapers/landscape.jpg -m fill";
      # exec-once = "swaybg -o DP-2 -i ~/wallpapers/portrait.jpg -m fill";
      bind = [
        "$mod+Return exec terminator"
        "$mod+d exec wofi --show drun"
        "$mod+Shift+r exec hyprctl reload"
        "$mod+Shift+e exec hyprctl dispatch exit 0"
      ];
      env = [
        "WLR_NO_HARDWARE_CURSORS=1"
      ];

      sensitivity = "1.0";
    };
  };
  home.packages = with pkgs; [
    swaybg               # For setting wallpapers
    waybar               # Status bar
    wl-clipboard         # Clipboard utilities
    grim                 # Screenshot utility
    slurp                # Area selection for screenshots
    wofi                 # Application launcher
    nwg-displays         # GUI for display management for Sway or Hyprland
    swaylock
  ];
}
