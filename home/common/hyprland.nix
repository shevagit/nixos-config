{ pkgs, lib, ... }: 
                                                                          
{
  programs.terminator = {
    enable = true;
  };
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      exec-once = "waybar";
    monitor = [
      # cheatsheet: "monitor = name, resolution, position, scale"
      # transform: 
      # 0 -> normal (no transforms)
      # 1 -> 90 degrees
      # 2 -> 180 degrees
      # 3 -> 270 degrees
      # 4 -> flipped
      # 5 -> flipped + 90 degrees
      # 6 -> flipped + 180 degrees
      # 7 -> flipped + 270 degrees
      "DP-1,2560x1440@164,0x0,1"
      "DP-2,1080x1920@60,2560x0,1"
    ];

      # exec-once = "swaybg -o DP-3 -i ~/wallpapers/landscape.jpg -m fill";
      # exec-once = "swaybg -o DP-2 -i ~/wallpapers/portrait.jpg -m fill";
      bind = [
        # --- Actions ---
        "$mod, Return, exec, terminator"
        "$mod, d, exec, wofi --show drun"
        #"$mod SHIFT, r exec, hyprctl reload"

        # Bind SUPER+p to the wofi power menu script.
        "$mod, p, exec, ~/.config/hyprland/scripts/wofi-power-menu.sh"
        "$mod SHIFT, e, exec, hyprctl dispatch exit 0"



        # --- Keyboard Bindings for Moving Windows Between Workspaces ---
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"

      ];

      env = [
        "WLR_NO_HARDWARE_CURSORS=1"
      ];
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

  home.file = {
    ".config/hyprland/scripts/wofi-power-menu.sh".text = ''
      #!/usr/bin/env bash
      # A simple power menu using wofi

      # List the options. Each option on a new line.
      OPTIONS="Lock\nLogout\nRestart\nShutdown"

      # Use wofi in dmenu mode to show the options.
      CHOICE=$(echo -e "$OPTIONS" | wofi --dmenu --prompt "Power Menu" --lines=4 --width=200)

      # Execute the corresponding command based on your selection.
      case "$CHOICE" in
        "Lock")
          # Adjust the lock command if you use a different locker.
          hyprctl dispatch exec swaylock
          ;;
        "Logout")
          # Exits the current Hyprland session.
          hyprctl dispatch exit 0
          ;;
        "Restart")
          systemctl reboot
          ;;
        "Shutdown")
          systemctl poweroff
          ;;
        *)
          # If no valid choice was made, do nothing.
          exit 1
          ;;
      esac
    '';
  };
    home.file.".config/hyprland/scripts/wofi-power-menu.sh".executable = true;
}