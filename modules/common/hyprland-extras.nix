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
      "modules-left": ["custom/workspaces"],
      "modules-center": ["clock"],
      "modules-right": ["cpu", "memory", "battery"],
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
      },
      "custom/workspaces": {
        "exec": "~/.config/waybar/hyprland-workspaces.sh",
        "interval": 1
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

    #custom-workspaces {
      padding: 0 5px;
      font-weight: bold;
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
