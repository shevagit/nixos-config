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

        "modules-left": ["hyprland/workspaces", "custom/launcher", "custom/vscode", "custom/chrome", "custom/insomnia", "wlr/taskbar"],
        "modules-center": ["hyprland/window"],
        "modules-right": ["clock", "cpu", "memory", "battery", "bluetooth", "network", "pulseaudio", "hyprland/language", "tray", "custom/notifications"],

        "hyprland/workspaces": {
          "persistent_workspaces": {
            "*": 5 // persist 5 workspaces for every monitor
          },
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
              //"title<.* - (.*) - VSCodium>": "codium $1"  // captures part of the window title and formats it into output
              },
                "show-special": true,
                "special-visible-only": true
        },

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
          "format": "{:%A, %d %B %Y, %H:%M}",
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
          "format-cycles": "🔋 {cycles}",
          "format-health": "🔋 {health}",
          "format-icons": ["", "", "", "", ""]
        },

        "cpu": {
          "format": "CPU: {usage}%"
        },

        "memory": {
          "format": "RAM: {used} / {total} GB"
        },

        "tray": {
          "spacing": 10
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

        "custom/launcher": {
          "exec": "~/.config/waybar/launcher.sh",
          "format": "{}",
          "on-click": "rofi -show drun -config ~/.config/rofi/launcher.rasi"
        },

        "custom/vscode": {
          "format": "",
          "interval": 600,
          "on-click": "code",
          "tooltip": "Launch Visual Studio Code"
        },

        "custom/chrome": {
          "format": "",
          "interval": 600,
          "on-click": "google-chrome-stable",
          "tooltip": "Launch Chrome"
        },

        "custom/notifications": {
            "format": "🔔 {}",
            "exec": "swaync-client --count",
            "on-click": "swaync-client -t",
            "tooltip": false,
            "interval": 2
        },
      
        "custom/insomnia": {
          "format": "",
          "interval": 600,
          "on-click": "insomnia",
          "tooltip": "Launch Insomnia"
        }
      }
    '';

    # Define Waybar styling
    home.file.".config/waybar/style.css".text = ''
    * {
        border-radius: 0;
        font-family: "FiraMono Nerd Font";
        font-size: 13px;
        font-weight: 500;
        padding: 0;
        margin: 0;
        margin-right: 2px;
        margin-left: 2px;
        transition-delay: 3s;
        color: #ffffff;
    }

    #waybar {
        background-color: rgba(76, 175, 80, 0.0);
        border: none;
        box-shadow: none;
    }

    window#waybar {
      padding: 0;
      margin: 0;
    }

    #window {
        font-weight: bold;
        color: black;
        background-color: #b877db;
        border-radius: 15px;
        padding-left: 10px;
        padding-right: 10px;
    }

    #waybar.empty #window {
        background: none;
    }

    #workspaces {
        text-shadow: 2px 1px 2px #a0a0a0;
    }

    #workspaces button {
        color: #50C878;
        text-shadow: 2px 1px 2px #1e1e3f;
        border-top: 5px solid #b877db;
        background-color: rgba(46, 52, 64, 0.7);
        border-radius: 1px;
    }

    #workspaces:hover {
        background-color: #303040;
        border-top: 5px solid #b877db;
    }

    #workspaces button:active {
        background-color:rgb(105, 204, 43);
        border-top: 5px solid #b877db;
    }

    #workspaces button.visible {
        color: #87ceeb;
        border-top: 5px solid #ff9f00;
    }

    #clock, #cpu, #memory, #network, #pulseaudio, #bluetooth, #tray, #workspaces, #language, #custom-launcher, #custom-vscode, #custom-chrome, #custom-insomnia, #custom-notifications {
        border-radius: 10px 0px 0px 10px;
        padding: 6px 12px;
        background: rgba(30, 30, 30, 0.6);
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