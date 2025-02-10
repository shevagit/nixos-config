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


    workspace = [
      "1, monitor:DP-1"
      "2, monitor:DP-2"
      "3, monitor:DP-1"
      "4, monitor:DP-2"
      "5, monitor:DP-1"
      "6, monitor:DP-2"
      "7, monitor:DP-1"
      "8, monitor:DP-2"
      "9, monitor:DP-1"
      "10, monitor:DP-2"
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
        # logout; to be removed
        "$mod SHIFT, e, exec, hyprctl dispatch exit 0"
        # close active window
        "$mod, q, killactive,"

        "CONTROL, Space, togglefloating,"

        "$mod, F, fullscreen,"

        # cycle through workspaces pairs
        "$mod, mouse_down, workspace, r+1"
        "$mod, mouse_up, workspace, r-1"

        # Move focus
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        # move window using keys
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, L, movewindow, r"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, J, movewindow, d"
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"

        # Switch workspaces with mod + [0-9]
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move active window to a workspace with mod + SHIFT + [0-9]
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # next workspace on monitor
        "CONTROL_ALT, right, workspace, m+1"
        "CONTROL_ALT, left, workspace, m-1"

        # lock
        "CONTROL_ALT, L, exec, swaylock"

        # Screenshot
        "$mod, Print, exec, grim -g \"$(slurp)\""

        # Volume control
        ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"
        ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"
        ", XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"

      ];

      bindm = [
        # Move/resize windows with mod + LMB/RMB and dragging
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindowpixel"
      ];

      input = {
        "kb_layout" = "us,gr";
        "kb_options" = "grp:win_space_toggle";
      };

      env = [
        "WLR_NO_HARDWARE_CURSORS=1"
      ];
    };
  };

  # required packages for the hyprland configuration
  home.packages = with pkgs; [
    swaybg               # For setting wallpapers
    waybar               # Status bar
    wl-clipboard         # Clipboard utilities
    grim                 # Screenshot utility
    slurp                # Area selection for screenshots
    wofi                 # Application launcher
    rofi-wayland         # a better wofi for wayland
    nwg-displays         # GUI for display management for Sway or Hyprland
    swaylock
    pavucontrol          # PulseAudio volume control
    pulseaudio           # pactl for volume control
    font-awesome
    nerdfonts
    hyprlock             # Lock screen for Hyprland
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
          hyprlock
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

  home.file = {
    ".config/hyprland/scripts/workspace-cycle.sh".text = ''
      #!/bin/bash
      # Define workspace groups for dual monitors
      workspace_sets=(
          "1 2"
          "3 4"
          "5 6"
      )

      # Get the current workspace number
      current_ws=$(hyprctl activeworkspace | awk '{print $2}')

      # Find the next set of workspaces
      for i in "''${!workspace_sets[@]}"; do
          if [[ " ''${workspace_sets[i]} " == *" $current_ws "* ]]; then
              next_index=$(( (i + 1) % ''${#workspace_sets[@]} ))
              next_workspaces=''${workspace_sets[$next_index]}
              break
          fi
      done

      # Switch both monitors to the new workspace set
      for ws in $next_workspaces; do
          hyprctl dispatch workspace $ws
      done
    '';
  };
    home.file.".config/hyprland/scripts/workspace-cycle.sh".executable = true;


  programs.keychain = {
    enable = true;
    agents = [
      "ssh"
    ];
    keys = [
      "nixsimos-github"
      "ed25519_gitlab"
      "google_compute_engine"
    ];
    extraFlags = [
      "--quiet"
      "--timeout 120"
    ];
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [
        {
          path = "~/Pictures/hyprlock-wallpaper.jpeg";
          blur_passes = 3;
          blur_size = 5;
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "250, 50";
          outline_thickness = 2;
          dots_size = 0.3;
          dots_spacing = 0.2;
          outer_color = "rgba(30, 30, 30, 0.8)";
          inner_color = "rgba(0, 0, 0, 0.8)";
          font_color = "rgb(255, 255, 255)";
          fade_on_empty = false;
        }
      ];
    };
  };
}