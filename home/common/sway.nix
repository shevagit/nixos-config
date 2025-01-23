{ pkgs, ... }:{
  home.packages = with pkgs; [
    sway                # The Sway window manager
    swaybg              # Background utility for Wayland
    waybar              # A customizable status bar
    wl-clipboard        # Clipboard management
    grim                # Screenshot utility
    slurp               # Area selection for screenshots
    xdg-desktop-portal-wlr # Portal for Wayland applications
    alacritty           # Terminal (example)
  ];

  programs.sway = {
    enable = true;
  };
}

{
  home.file.".config/sway/config".text = ''
    set $mod Mod4
    bindsym $mod+Return exec alacritty
    bindsym $mod+d exec wofi --show drun
    # exec swaybg -i ~/wallpaper.jpg -m fill
    output * bg #000000 solid_color

    # Configure monitors
    # The first monitor (2K resolution, landscape)
    output HDMI-A-1 resolution 2560x1440 position 0,0

    # The second monitor (Full HD, portrait mode)
    output DP-1 resolution 1080x1920 transform 90 position 2560,0
  '';
}
