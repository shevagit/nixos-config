{ pkgs, lib, ... }: 
                                                                          
{
  programs.terminator = {
    enable = true;
  };
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      
      exec-once = [
        #"~/.config/hyprland/scripts/waybars-wrapper.sh"
        "~/.config/hyprland/scripts/bares-wrapper.sh"
        # "swww-daemon"  # Removed - DMS handles wallpapers
        # "~/.config/hyprland/scripts/wallpaper-init.sh"  # Removed - DMS handles wallpapers
        "wl-paste --type text --watch cliphist store"  # Clipboard history for DMS
        "wl-paste --type image --watch cliphist store"  # Image clipboard history
      ];

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
        "DP-4,2560x1440@99.95,2560x0,1"
      ];

      bind = [
        # --- Actions ---
        "$mod, Return, exec, kitty"
        "$mod, d, exec, rofi -show drun -config ~/.config/rofi/launcher.rasi"
        #"$mod SHIFT, r exec, hyprctl reload"

        # Bind SUPER+p to DMS power menu
        "$mod, p, exec, dms ipc call powermenu toggle"
        # logout; to be removed
        "$mod SHIFT, e, exec, hyprctl dispatch exit 0"
        # close active window
        "$mod, q, killactive,"

        "CONTROL, Space, togglefloating,"

        "$mod, F, fullscreen,"


        # move to the next workspace
        "$mod SHIFT, grave, exec, ~/.config/hyprland/scripts/move-to-next-empty.sh"

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

        # move windows to next monitor
        "$mod SHIFT, TAB, movewindow, mon:+1"

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

        "$mod, mouse_up, exec, hyprctl dispatch workspace m+1"
        "$mod, mouse_down, exec, hyprctl dispatch workspace m-1"

        # lock
        "CONTROL_ALT, L, exec, swaylock"

        # Screenshot
        # deprecated: "$mod, Print, exec, grim -g \"$(slurp)\""
        "$mod, Print, exec, grimblast save area /tmp/screenshot.png && swappy -f /tmp/screenshot.png"

        # Volume control
        ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"
        ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"
        ", XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"

        # Wallpaper controls - Removed, DMS handles wallpapers
        # "$mod, w, exec, ~/.config/hyprland/scripts/wallpaper-next.sh"
        # "$mod SHIFT, w, exec, ~/.config/hyprland/scripts/wallpaper-random.sh"

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

      general ={
        gaps_in = 10;
        gaps_out = 20;
      };

      decoration = {
        rounding = 10;
        dim_inactive = true;
        dim_strength = 0.2;
        blur = {
          size = 3;
          passes = 2;
          vibrancy = 0.1696;
        };
        shadow = {
          range = 4;
          render_power = 3;
        };
      };
    };
  };

  # required packages for the hyprland configuration
  home.packages = with pkgs; [
      # waybar  # Disabled - replaced by DMS (Dank Material Shell)
      wl-clipboard
      cliphist  # Clipboard history for DMS
      grim
      slurp
      wofi
      rofi
      nwg-drawer
      swaylock
      pavucontrol
      pulseaudio
      font-awesome
      hyprlock
      
  ] ++ (if pkgs ? nerd-fonts then [
      pkgs.nerd-fonts.fira-code
      pkgs.nerd-fonts.hack
      pkgs.nerd-fonts.jetbrains-mono
    ] else [
      pkgs.nerdfonts
    ]);


  home.file = {
    ".config/hyprland/scripts/waybars-wrapper.sh".text = ''
      #!/usr/bin/env bash
      waybar -c ~/.config/waybar/left-bar-config.jsonc -s ~/.config/waybar/left-bar-style.css &
      sleep 1
      waybar &
    '';
  };
    home.file.".config/hyprland/scripts/waybars-wrapper.sh".executable = true;

  # Old bares-wrapper.sh (hyprpanel + waybar) - replaced by DMS
  # home.file = {
  #   ".config/hyprland/scripts/bares-wrapper.sh".text = ''
  #     #!/usr/bin/env bash
  #     hyprpanel &
  #     sleep 1
  #     waybar -c ~/.config/waybar/left-bar-config.jsonc -s ~/.config/waybar/left-bar-style.css &
  #   '';
  # };
  #   home.file.".config/hyprland/scripts/bares-wrapper.sh".executable = true;

  # DMS (Dank Material Shell) is started via systemd, no wrapper script needed
  home.file = {
    ".config/hyprland/scripts/bares-wrapper.sh".text = ''
      #!/usr/bin/env bash
      # DMS is started via systemd, this script is kept for compatibility
      # Old bars (hyprpanel + waybar) have been replaced by DMS
      exit 0
    '';
  };
    home.file.".config/hyprland/scripts/bares-wrapper.sh".executable = true;

  home.file.".config/wofi/style.css".text = ''
    window {
      background-color: rgba(40, 42, 54, 0.9);
      border-radius: 12px;
      border: 2px solid #6272a4;
    }

    #input {
      margin: 10px;
      padding: 5px;
      border-radius: 8px;
      background-color: rgba(68, 71, 90, 0.8);
      color: #f8f8f2;
    }

    #entry {
      padding: 8px;
      margin: 5px;
      border-radius: 8px;
      background-color: rgba(50, 50, 68, 0.8);
      color: #f8f8f2;
    }

    #entry:selected {
      background-color: #6272a4;
      color: #ffffff;
    }
  '';

  home.file = {
    ".config/hyprland/scripts/move-to-next-empty.sh".text = ''
      #!/usr/bin/env bash

      # Get the currently focused workspace
      current_workspace=$(hyprctl activeworkspace -j | jq -r '.id')

      # Get a list of all active workspaces
      active_workspaces=$(hyprctl workspaces -j | jq -r '.[].id')

      # Find the next available (empty) workspace
      next_workspace=$((current_workspace + 1))

      # Loop until we find an empty workspace
      while [[ $active_workspaces =~ $next_workspace ]]; do
          ((next_workspace++))
          
          # If we exceed a reasonable number of workspaces, wrap around
          if [[ $next_workspace -gt 10 ]]; then  # Adjust the limit as needed
              next_workspace=1
              break
          fi
      done

      # Move the focused window to the next available workspace
      hyprctl dispatch movetoworkspace "$next_workspace"
    '';
  };
    home.file.".config/hyprland/scripts/move-to-next-empty.sh".executable = true;


  # Enable ssh-agent service for keychain to connect to
  # handle ssh keys; gnome-keyring is used for password management
  services.ssh-agent.enable = true;

  programs.keychain = {
    enable = true;
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

      animations = {
          enabled = true;
          bezier = "linear, 1, 1, 0, 0";
      };

      animation = [
        "fadeIn, 1, 5, linear"
        "fadeOut, 1, 5, linear"
        "inputFieldDots, 1, 2, linear"
      ];

      label = [
        {
          monitor = "";
          text = "$TIME";
          font_size = 30;
          font_family = "$font";
          position = "-30, 0";
          halign = "right";
          valign = "top";
        }
        {
          monitor = "";
          text = "cmd[update:60000] date +\"%A, %d %B %Y\"";
          font_size = 25;
          font_family = "$font";
          position = "-30, -150";
          halign = "right";
          valign = "top";
        }
      ];
    };
  };
}
