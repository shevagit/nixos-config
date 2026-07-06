{ config, pkgs, lib, osConfig, ... }:
let
  host = osConfig.networking.hostName;
in
                                                                          
{
  programs.terminator = {
    enable = true;
  };
  wayland.windowManager.hyprland = {
    enable = true;
    # Migrated to the Lua config generator (2026-07-02). The whole config lives in
    # ./hyprland.lua and is injected via extraConfig below. `settings` MUST stay
    # empty: with configType = "lua" the module serializes `settings` into hl.*()
    # calls, so the old hyprlang keys ($mod, bind, monitor, ...) would render as
    # broken Lua. Roll back with `git revert` of this commit (restores hyprlang +
    # the settings block), then rebuild.
    configType = "lua";
    extraConfig = builtins.readFile ./hyprland.lua;
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

  # DMS restart script
  home.file.".config/hyprland/scripts/dms-restart.sh" = {
    text = ''
      #!/usr/bin/env bash
      # Quick restart script for DMS when it freezes
      # Bound to SUPER+L for quick access

      # Restart DMS
      systemctl --user restart dms

      # Wait for DMS notification service to be ready
      sleep 2

      # Send notification via DMS's built-in notification service
      ${pkgs.libnotify}/bin/notify-send "DMS" "Bar restarted" -t 2000
    '';
    executable = true;
  };

  # DMS lock recovery script — run from TTY when DMS lock screen crashes
  home.file.".config/hyprland/scripts/unlock.sh" = {
    text = ''
      #!/usr/bin/env bash
      # Recovery script for when DMS lock screen crashes
      # Usage: from TTY (Ctrl+Alt+F2), login and run: ~/unlock.sh

      echo "Unlocking session..."
      loginctl unlock-session

      # Restart DMS so the bar comes back
      systemctl --user restart dms

      sleep 2
      echo "Done. Switch back to Hyprland with Ctrl+Alt+F1"
    '';
    executable = true;
  };

  # Symlink unlock.sh to home dir for easy TTY access
  home.file."unlock.sh" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.config/hyprland/scripts/unlock.sh";
  };

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

      # Move the focused window to the next available workspace.
      # Under the Lua config backend `hyprctl dispatch <arg>` is evaluated as Lua
      # (`return hl.dispatch(<arg>)`), so the classic string form fails. Note that
      # `hl.dsp.exec_raw("...")` runs its argument as a *shell* command (that is how
      # logout does `exec_raw("exit 0")`), NOT a dispatcher — so it silently no-ops.
      # The real move-window-to-workspace dispatcher is hl.dsp.window.move.
      hyprctl dispatch "hl.dsp.window.move({ workspace = $next_workspace })"
    '';
  };
    home.file.".config/hyprland/scripts/move-to-next-empty.sh".executable = true;

  # keychain manages its own ssh-agent; do not enable services.ssh-agent
  # alongside it as they conflict (stale sockets / duplicate agents)
  programs.keychain = {
    enable = true;
    keys = [
      "nix${host}-p"
      "nix${host}-w"
      "nix${host}-gl"
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
          path = "${pkgs.sddm-astronaut}/share/sddm/themes/sddm-astronaut-theme/Backgrounds/japanese_aesthetic.png";
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
