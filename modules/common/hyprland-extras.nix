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

        "modules-left": ["hyprland/workspaces", "custom/launcher", "custom/vscode", "custom/chrome"],
        "modules-center": ["hyprland/window"],
        "modules-right": ["clock", "cpu", "memory", "battery", "network", "pulseaudio", "hyprland/language"],

        "hyprland/window": {
          "separate-outputs": true
        },
        "hyprland/language": {
          "format": "{}",
          "format-en": "🇺🇸",
          "format-gr": "🇬🇷",
          "on-click": "hyprctl switchxkblayout current next"
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
        },
        "network": {
          "interface": "eno2",
          "format-wifi": "{icon}",
          "format-icons": ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"],
          "format-ethernet": "🌐",
          "format-linked": "{ifname} 󰈀",
          "format-disconnected": "󰤫",
          "interval": 1,
          "tooltip-format": "{ifname} via {gwaddr}",
          "on-click": "alacritty -e nmtui"
        },
        "pulseaudio": {
          "format": "{icon} {volume}%  {format_source}",
          "format-bluetooth": "{icon} {volume}%  {format_source}",
          "format-bluetooth-muted": " {icon}  {format_source}",
          "format-muted": " {format_source}",
          "format-source": " {volume}%",
          "format-source-muted": "",
          "format-icons": {
            "headphone": "",
            "hands-free": "",
            "headset": "",
            "phone": "",
            "portable": "",
            "car": "",
            "default": [
              "",
              "",
              ""
            ]
          },
          "on-click": "pavucontrol"
        },

        "custom/launcher": {
          "exec": "~/.config/waybar/launcher.sh",
          "format": "{}",
          "on-click": "rofi -show drun"
        },

        "custom/vscode": {
          "exec": "echo 'vscode'",         // Outputs the Visual Studio Code icon.
          "interval": 600,           // The icon is static; update every 10 minutes.
          "on-click": "code",        // Runs the command to open VS Code when clicked.
          "tooltip": "Launch Visual Studio Code"
        },

        "custom/chrome": {
          "exec": "echo 'chrome'",         // Outputs the Visual Studio Code icon.
          "interval": 600,           // The icon is static; update every 10 minutes.
          "on-click": "google-chrome-stable",        // Runs the command to open VS Code when clicked.
          "tooltip": "Launch Chrome"
        }
      }
    '';

    # Define Waybar styling
    home.file.".config/waybar/style.css".text = ''
      * {
        font-family: "JetBrains Mono", "Font Awesome", monospace;
        font-size: 12px;
        color: #ffffff;
        background: #1e1e2e;
      }

      #clock {
        font-size: 14px;
        padding: 0 50px;
      }

      #cpu {
        padding: 0 10px;
      }

      #memory {
        padding: 0 10px;
      }

      #network {
        padding: 0 10px;
      }

      #pulseadio {
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

      #custom-launcher {
        padding: 0 10px;
      }

      #custom-vscode {
        padding: 0 10px;
      }

      #custom-chrome {
        padding: 0 10px;
      }

      #custom-language {
        padding: 0 10px;
      }
    '';

    # Script for language settings
    home.file.".config/waybar/language.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        LAYOUT=$(hyprctl devices | grep "active keymap:" | uniq | sed 's/.*active keymap: //')
        echo " $LAYOUT"
        while true; do
          sleep 1
        done
      '';
    };

    # Script for app launcher
    home.file.".config/waybar/launcher.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        echo ""
        while true; do
          sleep 1
        done
      '';
    };
  };
}