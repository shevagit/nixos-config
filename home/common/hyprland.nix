{
  home.file.".config/hypr/hyprland.conf".text = ''
    # Example Hyprland configuration
    monitor=DP-3,2560x1440@60,0x0
    monitor=DP-2,1080x1920@60,2560x0,transform,90

    # Background wallpaper
    #exec-once=swaybg -o DP-3 -i ~/wallpapers/landscape.jpg -m fill
    #exec-once=swaybg -o DP-2 -i ~/wallpapers/portrait.jpg -m fill

    # Keybindings
    bind=MOD,Return,exec,alacritty
    bind=MOD+d,exec,wofi --show drun

    # Cursor fix for NVIDIA
    env=WLR_NO_HARDWARE_CURSORS,1

    # Animations and general config
    sensitivity=1.0
    layout=master
    decoration:active_opacity=1.0
    decoration:inactive_opacity=0.8
  '';
}