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
        "modules-left": ["hyprland/workspaces", "clock", "custom/weather", "cpu", "custom/gpu", "custom/launcher", "custom/vscode", "custom/chrome", "custom/insomnia", "custom/spotify-thumb-sync", "custom/spotify"],
        "modules-right": ["tray", "custom/power-menu"],

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

        "tray": {
          "spacing": 10
        },

        "cpu": {
          "interval": 15,
          "format": " {usage:>2}%",
          "format-icons": ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"],
        },

        "custom/weather": {
          "exec": "~/.config/waybar/scripts/weather.sh",
          "interval": 1800,
          "format": "{}",
          "tooltip": true
        },

        "clock": {
          "format": "⏰ {:%H:%M}",
          "interval": 60,
          "tooltip": false
        },

        "custom/gpu": {
          "format": "󰏈  {}",
          "exec": "~/.config/waybar/scripts/gpu-status.sh",
          "interval": 90,
          "tooltip": true,
          "tooltip-format": "GPU temp"
        },

        "custom/vscode": {
          "format": "󰘐 ",
          "tooltip": true,
          "tooltip-format": "Visual Studio Code",
          "interval": 600,
          "on-click": "code --enable-features=UseOzonePlatform --ozone-platform=wayland"
        },

        "custom/chrome": {
          "format": "󰊯 ",
          "tooltip": true,
          "tooltip-format": "Google Chrome",
          "interval": 600,
          "on-click": "google-chrome-stable"
        },

        "custom/insomnia": {
          "format": "󱂛 ",
          "tooltip": true,
          "tooltip-format": "Insomnia",
          "interval": 600,
          "on-click": "insomnia"
        },

        "custom/launcher": {
          "format": "󰌧 ",
          "tooltip": true,
          "tooltip-format": "App Launcher",
          "on-click": "rofi -show drun -config ~/.config/rofi/launcher.rasi"
        },

        "custom/spotify": {
          "format": "{}",
          "exec": "~/.config/waybar/scripts/spotify.sh",
          "return-type": "json",
          "interval": 2,
          "on-click": "playerctl -p spotify play-pause",
          "on-click-right": "playerctl -p spotify next",
          "on-click-middle": "playerctl -p spotify previous",
          "on-scroll-up": "~/.config/eww/spotify-album-popup.sh && eww open spotify_popup",
          "on-scroll-down": "~/.config/eww/spotify-album-popup.sh && eww close spotify_popup",
        },

        "custom/spotify-thumb-sync": {
          "exec": "~/.config/eww/spotify-thumb.sh",
          "interval": 5,
          "return-type": "json",
          "format": ""
        },

        "custom/power-menu": {
          "format": "⏻",
          "tooltip": "Power Menu",
          "on-click": "~/.config/hyprland/scripts/wofi-power-menu.sh"
        }
      }
    '';


    # Define Waybar configuration
    home.file.".config/waybar/config.jsonc".text = ''
      {
        "layer": "top",
        "position": "top",

        "modules-left": ["memory"],
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

        "battery": {
            "format": "<span font='Font Awesome 5 Free 11'>{icon}</span>  {capacity}% - {time}",
            "format-icons": ["", "", "", "", ""],
            "format-time": "{H}h{M}m",
            "format-charging": "<span font='Font Awesome 5 Free'></span>  <span font='Font Awesome 5 Free 11'>{icon}</span>  {capacity}% - {time}",
            "format-full": "<span font='Font Awesome 5 Free'></span>  <span font='Font Awesome 5 Free 11'>{icon}</span>  Charged",
            "interval": 30,
            "states": {
                "warning": 25,
                "critical": 10
            },
            "tooltip-format": "🔋 {capacity}%\n🔁 {cycles} cycles",
            "tooltip-format-charging": "🔌 Charging\n🔋 {capacity}%\n🔁 {cycles} cycles",
            "tooltip-format-full": "✅ Full\n🔋 {capacity}%\n🔁 {cycles} cycles",
            "on-click": "~/.config/waybar/scripts/battery-info.sh"
        },

        "clock": {
          "format": "📅{:%A %d %B %Y}",
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

        "memory": {
          "format": "{icon} {used}/{total}",
          "format-icons": [" "]
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
          "format-ethernet": "󰈀 {ipaddr} total {bandwidthTotalBytes}",
          "format-disconnected": "⚠️ No network",
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
        background-color: rgba(76, 175, 80, 0.0);
        border: none;
        box-shadow: none;
        margin: 0;
        padding: 0;
        border-radius: 0;
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
    
    #clock, #custom-weather, #tray, #custom-power-menu, #cpu, #custom-gpu, #custom-launcher, #custom-vscode, #custom-chrome, #custom-insomnia {
      margin: 12px 0;
      padding: 4px 4px;
      border: 2px solid #c7ab7a;
      border-radius: 8px;
      background-color: rgb(192, 41, 41);
    }

    #custom-spotify {
      border: 2px solid #c7ab7a;
      border-radius: 8px;
      padding: 4px;
      color: white;
    }

    #custom-spotify.Playing {
      background-color: #1db954;
    }

    #custom-spotify.Paused {
      background-color: #888888;
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

    #network, #pulseaudio, #clock, #memory, #battery, #bluetooth, #workspaces, #language, #custom-notifications, #window {
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
        LOCATION="Athens,Greece"

        CONDITION=$(curl -s "wttr.in/$LOCATION?format=%C")
        WIND=$(curl -s "wttr.in/$LOCATION?format=%w")
        TEMP=$(curl -s "wttr.in/$LOCATION?format=%t")
        
        # handle bad response
        if [[ -z "$CONDITION" ]] || echo "$CONDITION" | grep -qi "Unknown location"; then
          echo -e "❓\nwttr unavailable"
          exit 0
        fi

        # Basic emoji mapping
        ICON="❓"

        case "$CONDITION" in
          *Clear*|*Sunny*) ICON="☀️" ;;
          *Partly*|*Clouds*) ICON="🌤️" ;;
          *Cloudy*) ICON="☁️" ;;
          *Overcast*) ICON="🌥️" ;;
          *Thunder*|*Storm*) ICON="⛈️" ;;
          *Snow*) ICON="❄️" ;;
          *Light*|*Heavy*|*Showers*|*Drizzle*) ICON="🌧️" ;;
          *Mist*|*Fog*) ICON="🌫️" ;;
        esac

        # Output with newline
        echo -e "$ICON$TEMP\n$CONDITION"
      '';
    };

    # Sript for battery info if on laptop
    home.file.".config/waybar/scripts/battery-info.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        BAT_INFO=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E "state|to go|percentage|time to|capacity|cycle-count" | sed 's/^ *//')

        echo "$BAT_INFO" | rofi -dmenu -p "🔋 Battery Info"
      '';
    };

    # Script for battery notifications
    home.file.".config/waybar/scripts/battery-notifications.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        # Check if a battery exists
        BATTERY_PATH=$(upower -e | grep battery | head -n1)
        if [[ -z "$BATTERY_PATH" ]]; then
          exit 0
        fi

        # Get battery level and state
        LEVEL=$(upower -i "$BATTERY_PATH" | awk '/percentage:/ {gsub(/%/, "", $2); print $2}')
        STATE=$(upower -i "$BATTERY_PATH" | awk '/state:/ {print $2}')

        # Send notification if low and discharging
        if [[ "$STATE" == "discharging" && "$LEVEL" -le 15 ]]; then
          notify-send -u critical "⚠️ Battery Low" "Level: $LEVEL%"
        fi
      '';
    };

    # Script for gpu temp based on vendor
    home.file.".config/waybar/scripts/gpu-status.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        # detect GPU vendor
        if lspci | grep -i "nvidia" > /dev/null; then
            # nvidia
            read -r TEMP FAN <<< $(nvidia-smi --query-gpu=temperature.gpu,fan.speed --format=csv,noheader,nounits | tr ',' ' ')
            echo "$TEMP°C"
        elif lspci | grep -qi "amd"; then
            # AMD – look for hwmon with 'amdgpu' in name
            for dir in /sys/class/hwmon/hwmon*; do
                if grep -q "amdgpu" "$dir/name"; then
                    RAW_TEMP=$(cat "$dir/temp1_input")
                    TEMP=$((RAW_TEMP / 1000))
                    echo "$TEMP°C"
                    exit 0
                fi
            done
            echo "AMD GPU temp not found"
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

    # script for spotify
    home.file.".config/waybar/scripts/spotify.sh" = {
      executable = true;
      text = ''
      #!/usr/bin/env bash

      if ! (playerctl --list-all 2>/dev/null | grep -q spotify); then
        echo '{"text": ""}'
        exit 0
      fi

      status=$(playerctl status -p spotify 2>/dev/null)
      if [ "$status" != "Playing" ] && [ "$status" != "Paused" ]; then
        exit 0
      fi

      artist=$(playerctl metadata -p spotify artist)
      title=$(playerctl metadata -p spotify title)

      short_title=$(echo "$title" | cut -c1-10)
      short_artist=$(echo "$artist" | cut -c1-9)

      icon=""
      bgcolor="#888888" # paused = grey
      [ "$status" = "Playing" ] && icon="" && bgcolor="#1db954"

      text="$short_artist -\n$short_title"
      tooltip="$title by $artist"

      echo "{\"text\": \"$text\", \"tooltip\": \"$tooltip\", \"class\": \"$status\"}"
      echo '{"text": ""}'
      exit 0

      '';
    };

    # script for spotify pop-up using eww
    home.file.".config/eww/spotify-album-popup.sh" = {
      executable = true;
      text = ''
      #!/usr/bin/env bash

      title=$(playerctl metadata -p spotify title)
      artist=$(playerctl metadata -p spotify artist)
      arturl=$(playerctl metadata -p spotify mpris:artUrl | sed 's/open.spotify.com/i.scdn.co/')

      wget -q "$arturl" -O /tmp/spotify_cover.jpg

      eww update EWW_SPOTIFY_TITLE="$title"
      eww update EWW_SPOTIFY_ARTIST="$artist"
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
