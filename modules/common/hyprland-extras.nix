
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
        "bluetooth": {
        // "controller": "controller1", // specify the alias of the controller if there are more than 1 on the system
        // "format": "󰂯 {status}",
        // format-* handles every state, so default format is not necessary.
        "format-on": "󰂯",
        "format-off": "󰂲",
        "format-disabled": "", // an empty format will hide the module
        "format-connected": "󰂱 {num_connections}",
        // "tooltip-format": "{controller_alias}\t{controller_address}",
        // "tooltip-format-connected": "{controller_alias}\t{controller_address}\n\n{device_enumerate}",
        "tooltip-format-connected": "{device_enumerate}",
        "tooltip-format-enumerate-connected": "{device_alias}\t{device_address}"
        },
        "network": {
        // "interface": "wlp2*", // (Optional) To force the use of this interface
        // "format-wifi": "{essid} ({signalStrength}%) ",
        "format-wifi": "{icon}",
        "format-icons": ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"],
        // "format-ethernet": "{ipaddr}/{cidr} 󰈀",
        "format-ethernet": "󰈀",
        "format-linked": "{ifname} 󰈀",
        "format-disconnected": "󰤫",
        // "format-alt": "{ifname}: {ipaddr}/{cidr}",
        "tooltip-format": "{ifname} via {gwaddr}",
        "on-click": "~/.config/rofi/rofi-wifi-menu"
        },
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
