{
  home-manager.users.sheva = {
    programs.waybar = {
      enable = true;
    };

    # left-bar-config.jsonc
    home.file.".config/waybar/left-bar-config.jsonc".text = ''
      {
        "layer": "top",
        "position": "left",
        "modules-left": ["hyprland/workspaces", "clock", "custom/weather", "custom/gpu", "tray"],

        "hyprland/workspaces": {
          "format": "{name} {windows}",
          "format-window-separator": " ",
          "window-rewrite-default": "",
          "window-rewrite": {
              "class<firefox> title<.*youtube.*>": "", // Windows whose titles contain "youtube"
              "class<firefox>": "", // Windows whose classes are "firefox"
              "class<firefox> title<.*gitlab.*>": "", // Windows whose class is "firefox" and title contains "github". Note that "class" always comes first.
              "zsh": "", // Windows that contain "foot" in either class or title. For optimization reasons, it will only match against a title if at least one other window explicitly matches against a title.
              "slack": "",
              "steam": "",
              "spotify": "",
              "telegram-desktop": "",
              "Google-chrome": "",
              "discord": "",
              "signal": "",
              "compass": "",
              "element": "",
              "Visual Studio Code": "",
              "title<.*vim.*>": "",
              //"title<.*is sharing your screen>": """
              },
                "show-special": true,
                "special-visible-only": true
        },

        "clock": {
          "format": "📅{:%A\n%d %B\n%Y}",
          "tooltip-format": "<tt><small>{calendar}</small></tt>",
          "calendar": {
            "mode"          : "month",
            "mode-mon-col"  : 3,
            "weeks-pos"     : "right",
            "on-scroll"     : 1,
            "on-click-right": "mode",
            "format": {
                "months":     "<span color='#ffead3'><b>{}</b></span>",
                "days":       "<span color='#ecc6d9'><b>{}</b></span>",
                "weeks":      "<span color='#99ffdd'><b>W{}</b></span>",
                "weekdays":   "<span color='#ffcc66'><b>{}</b></span>",
                "today":      "<span color='#ff6699'><b><u>{}</u></b></span>"
                },
        },
        "actions": {
            "on-click-right": "mode",
            "on-click-forward": "tz_up",
            "on-click-backward": "tz_down",
            "on-scroll-up": "shift_up",
            "on-scroll-down": "shift_down"
            }
        },

        "tray": {
          "spacing": 10
        },

        "custom/gpu": {
          "format": "{}",
          "exec": "~/.config/waybar/gpu-status.sh",
          "interval": 30,
          "tooltip": true,
          "tooltip-format": "GPU Temp &amp; Fan"
        },

        "custom/weather": {
          "exec": "~/.config/waybar/scripts/weather.sh",
          "interval": 600,
          "format": "🌤️ {}",
          "tooltip": true
        }
      }
    '';


    # Define Waybar configuration
    home.file.".config/waybar/config.jsonc".text = ''
      {
        "layer": "top",
        "position": "top",

        "modules-left": ["custom/launcher", "custom/vscode", "custom/chrome", "custom/insomnia", "cpu", "memory"],
        "modules-center": ["hyprland/window"],
        "modules-right": ["clock", "bluetooth", "network", "pulseaudio", "battery", "hyprland/language", "custom/notifications"],


        "hyprland/window": {
          "separate-outputs": true
        },
        "hyprland/language": {
          "format": "{}",
          "format-en": "🇺🇸",
          "format-gr": "🇬🇷",
          "on-click": "hyprctl switchxkblayout current next"
        },

        "cpu": {
          "interval": 15,
          "format": " {usage:>2}%",
          "format-icons": ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"],
        },

        "memory": {
          "format": "{icon} {used}|{total}",
          "format-icons": [" "]
        },

        "battery": {
          "bat": "BAT0",
          "adapter": "AC",
          "interval": 90,
          "states": {
            "warning": 30,
            "critical": 15
          },
          "format": "{icon} {capacity}%",
          "format-time": "{icon} {capacity}% {time}",
          "format-icons": [" ", " ", " ", " ", " "],
          "tooltip-format": "Capacity: {capacity}%"
        },

        "wlr/taskbar": {
          "format": "{icon}",
          "icon-size": 14,
          "icon-theme": "Numix-Circle",
          "tooltip-format": "{title}",
          "on-click": "activate",
          "on-click-middle": "close"
        },

        "network": {
          "interval": 30,
          "format-wifi": "  {essid} ({signalStrength}%)",
          "format-ethernet": "󰈀 {ipaddr}",
          "format-disconnected": "⚠️ No network",
          "tooltip-format": "{ifname} via {gwaddr}",
          "on-click": "alacritty -e nmtui"
        },

        "clock": {
          "format": "⏰ {:%H:%M}",
          "interval": 60,
          "tooltip": false
          },

        "pulseaudio": {
          "format": "{icon} {volume}%  {format_source}",
          "format-bluetooth": "{icon} {volume}%  {format_source}",
          "format-bluetooth-muted": " {icon}  {format_source}",
          "format-muted": " {format_source}",
          "format-source": " {volume}%",
          "format-source-muted": "",
          "format-icons": {
            "headphone": " ",
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
          "on-click": "pavucontrol",
          "on-scroll-up": "pactl set-sink-volume @DEFAULT_SINK@ +5%",
          "on-scroll-down": "pactl set-sink-volume @DEFAULT_SINK@ -5%"
        },

        "bluetooth": {
          "format": " {status}",
          "format-connected": "󰂯 {num_connections}",
          "format-disconnected": "󰂲 Off",
          "tooltip": true,
          "on-click": "env GDK_BACKEND=x11 blueman-manager"
        },

        "custom/vscode": {
          "format": " ",
          "tooltip": true,
          "tooltip-format": "Visual Studio Code",
          "interval": 600,
          "on-click": "code"
        },

        "custom/chrome": {
          "format": " ",
          "tooltip": true,
          "tooltip-format": "Google Chrome",
          "interval": 600,
          "on-click": "google-chrome-stable"
        },

        "custom/insomnia": {
          "format": " ",
          "tooltip": true,
          "tooltip-format": "Insomnia",
          "interval": 600,
          "on-click": "insomnia"
        },

        "custom/launcher": {
          "format": " ",
          "tooltip": true,
          "tooltip-format": "App Launcher",
          "on-click": "rofi -show drun -config ~/.config/rofi/launcher.rasi"
        },

        "custom/notifications": {
            "format": "🔔 {}",
            "exec": "swaync-client --count",
            "on-click": "swaync-client -t",
            "tooltip": false,
            "interval": 2
        }
      }
    '';

    # left-bar-style.css
    home.file.".config/waybar/left-bar-style.css".text = ''
    * {
      font-family: "FiraMono Nerd Font";
      font-size: 12px;
      font-weight: bold;
      color: white;
    }

    #waybar {
      background-color: rgba(0, 0, 0, 0.7);
      border-radius: 12px;
      padding: 8px;
      margin: 6px;
    }
    #workspaces {
        text-shadow: 2px 1px 2px #a0a0a0;
        background: none;
    }

    #workspaces button {
        text-shadow: 2px 1px 2px #1e1e3f;
        border-top: 5px solid #b877db;
        background-color: rgba(46, 52, 64, 0.7);
        margin: 0px 2px;
        padding: 1px 7px;
        font-size: 10px;
        border-radius: 10px;
    }

    #workspaces:hover {
        background-color:rgb(11, 64, 11);
    }

    #workspaces button:active {
        background-color: rgb(105, 204, 43);
        border-top: 5px solid #b877db;
    }

    #workspaces button.visible {
        color: #87ceeb;
        border-top: 5px solid #ff9f00;
    }
    
    #clock, #custom-weather, #custom-gpu, #tray {
      margin: 12px 0;
      padding: 6px 10px;
      border: 2px solid #c7ab7a;
      border-radius: 8px;
      background-color: #2b2b2b;
    }
    '';

    # Define Waybar styling
    home.file.".config/waybar/style.css".text = ''
    * {
        font-family: "FiraMono Nerd Font";
        font-size: 12px;
        font-weight: bold;
        color: white;
    }

    #network, #pulseaudio, #clock, #cpu, #memory, #bluetooth, #workspaces, #language, #custom-launcher, #custom-vscode, #custom-chrome, #custom-insomnia, #custom-notifications, #window {
        border-radius: 10px;
        border: 2px solid #c7ab7a;
        padding: 2px 10px;
        background-color: rgb(192, 41, 41);
        margin: 0 2px;
    }

    #waybar {
        background-color: rgba(76, 175, 80, 0.0);
        border: none;
        box-shadow: none;
        margin: 0;
        padding: 0;
        border-radius: 0;
    }

    window#waybar {
        padding: 0;
        margin: 0;
    }

    #window {
        color: black;
        background-color: #b877db;
        border: none;
    }

    #waybar.empty #window {
        background: none;
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

    # scrfipt for weather
    home.file.".config/waybar/scripts/weather.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        # Get the weather
        CONDITION=$(curl -s wttr.in?format="%C")
        WIND=$(curl -s wttr.in?format="%w")
        WEATHER=$(curl -s wttr.in?format="%t")

        # Print the weather with a newline
        echo -e "$WEATHER\n$CONDITION"

      '';
    };

    # Script for language settings
    home.file.".config/waybar/gpu-status.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        # detect GPU vendor
        if lspci | grep -i "nvidia" > /dev/null; then
            # nvidia
            read -r TEMP FAN <<< $(nvidia-smi --query-gpu=temperature.gpu,fan.speed --format=csv,noheader,nounits | tr ',' ' ')
            echo "GPU:$TEMP°C"
        elif lspci | grep -i "amd" > /dev/null; then
            # amd
            TEMP=$(cat /sys/class/drm/card0/device/hwmon/hwmon0/temp1_input)
            TEMP=$((TEMP / 1000)) # Convert millidegrees to degrees Celsius
            FAN=$(cat /sys/class/drm/card0/device/hwmon/hwmon0/pwm1)
            echo "GPU:$TEMP°C"
        else
            echo "No supported GPU detected."
        fi
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

    home.file.".config/rofi/launcher.rasi".text = ''
      configuration {
          font:				"Cascadia Code 12";
          show-icons:				true;
          icon-theme:				"Arc-X-D";
          display-drun:			"Apps";
          drun-display-format:		"{name}";
          scroll-method:			0;
          disable-history:			false;
          sidebar-mode:			false;
      }

      window {
          background-color: @background;
          border:           0;
          padding:          30;
      }
      listview {
          lines:                          10;
          columns:                        3;
      }
      mainbox {
          border:  0;
          padding: 0;
      }
      message {
          border:       2px 0px 0px ;
          border-color: @separatorcolor;
          padding:      1px ;
      }
      textbox {
          text-color: @foreground;
      }
      listview {
          fixed-height: 0;
          border:       8px 0px 0px ;
          border-color: @separatorcolor;
          spacing:      8px ;
          scrollbar:    false;
          padding:      2px 0px 0px ;
      }
      element {
          border:  0;
          padding: 1px ;
      }
      element-text {
          background-color: inherit;
          text-color:       inherit;
      }
      element.normal.normal {
          background-color: @normal-background;
          text-color:       @normal-foreground;
      }
      element.normal.urgent {
          background-color: @urgent-background;
          text-color:       @urgent-foreground;
      }
      element.normal.active {
          background-color: @active-background;
          text-color:       @active-foreground;
      }
      element.selected.normal {
          background-color: @selected-normal-background;
          text-color:       @selected-normal-foreground;
      }
      element.selected.urgent {
          background-color: @selected-urgent-background;
          text-color:       @selected-urgent-foreground;
      }
      element.selected.active {
          background-color: @selected-active-background;
          text-color:       @selected-active-foreground;
      }
      element.alternate.normal {
          background-color: @alternate-normal-background;
          text-color:       @alternate-normal-foreground;
      }
      element.alternate.urgent {
          background-color: @alternate-urgent-background;
          text-color:       @alternate-urgent-foreground;
      }
      element.alternate.active {
          background-color: @alternate-active-background;
          text-color:       @alternate-active-foreground;
      }
      scrollbar {
          width:        4px ;
          border:       0;
          handle-color: @normal-foreground;
          handle-width: 8px ;
          padding:      0;
      }
      mode-switcher {
          border:       2px 0px 0px ;
          border-color: @separatorcolor;
      }
      button {
          spacing:    0;
          text-color: @normal-foreground;
      }
      button.selected {
          background-color: @selected-normal-background;
          text-color:       @selected-normal-foreground;
      }
      inputbar {
          spacing:    0;
          text-color: @normal-foreground;
          padding:    1px ;
      }
      case-indicator {
          spacing:    0;
          text-color: @normal-foreground;
      }
      entry {
          spacing:    0;
          text-color: @normal-foreground;
      }
      prompt {
          spacing:    0;
          text-color: @normal-foreground;
      }
      inputbar {
          children:   [ prompt,textbox-prompt-colon,entry,case-indicator ];
      }
      textbox-prompt-colon {
          expand:     false;
          str:        ":";
          margin:     0px 0.3em 0em 0em ;
          text-color: @normal-foreground;
      }
    '';
  };
}
