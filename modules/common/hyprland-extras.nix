
{
home-manager.users.sheva = {
  programs.waybar = {
    enable = true;
  };

    # Define Waybar configuration
    home.file.".config/waybar/config.jsonc".text = ''
      {
        "layer": "top",
        "position": "top",
        "modules-left": ["hyprland/workspaces"],
        "modules-center": ["clock", "hyprland/window"],
        "modules-right": ["cpu", "memory", "battery"],
        },
        "hyprland/window": {
          "separate-outputs": true
        },
        "clock": {
          "format": "{:%A, %d %B %Y, %H:%M}"
        },
        "battery": {
          "format": "{percent}%"
        },
        "cpu": {
          "format": "CPU: {usage}%"
        },
        "memory": {
          "format": "RAM: {used} / {total} GB"
        }
      }
    '';

    # Define Waybar styling
    home.file.".config/waybar/style.css".text = ''
      * {
        font-family: "JetBrains Mono", monospace;
        font-size: 12px;
        color: #ffffff;
        background: #1e1e2e;
      }

      #clock {
        font-size: 14px;
        padding: 0 10px;
      }

      #workspaces button {
        border: none;
        padding: 5px;
        margin: 2px;
        background-color: #2e3440;
        color: #ffffff;
        border-radius: 5px;
      }

      #workspaces button.active {
        background-color: #88c0d0;
        color: #ff0000;
      }
    '';

    home.file.".config/waybar/hyprland-workspaces.sh".text = ''
    #!/usr/bin/env bash
    # This script outputs the current workspaces for Hyprland in a format suitable for Waybar.
    # It uses hyprctl to get workspace info in JSON format and jq to process it.

    # Get JSON output of workspaces
    json=$(hyprctl workspaces -j)

    # Process each workspace:
    #   • Print the workspace name.
    #   • Mark the active workspace with an asterisk (you can change this indicator as you like).
    workspaces=$(echo "$json" | jq -r '.[] | if .active then "\(.name)*" else "\(.name)" end' | tr '\n' ' ')

    # Output the workspaces line (trim any trailing space)
    echo "$workspaces" | sed 's/[[:space:]]*$//'
    '';
    home.file.".config/waybar/hyprland-workspaces.sh".executable = true;

  };
}
