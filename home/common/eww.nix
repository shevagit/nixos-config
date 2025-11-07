{ pkgs, ... }:{
    programs.eww = {
      enable = true;
      configDir = ./skel-eww-config;
    };

    # Try a spotify pop-up using eww
    home.file.".config/eww/eww.yuck" = {
    text = ''
      (include "eww_windows.yuck")
      '';
    };

    home.file.".config/eww/eww.scss" = {
    text = ''

        * {
          all: unset;
          font-family: "FiraMono Nerd Font", "JetBrainsMono", "Noto Color Emoji", sans-serif;
          font-size: 12px;
          font-weight: bold;
          color: #ffffff;
        }

        /* Top Bar Styling */
        .top-bar {
          background-color: rgba(20, 20, 30, 0.95);
          backdrop-filter: blur(10px);
          border-bottom: 2px solid rgba(199, 171, 122, 0.3);
          padding: 5px 15px;
          transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        .top-left, .top-right {
          padding: 0 5px;
        }

        .top-center {
          margin: 0 20px;
        }

        /* Top bar buttons */
        .memory-btn, .clock-btn, .bluetooth-btn, .network-btn, 
        .volume-btn, .battery-btn, .layout-btn, .notifications-btn {
          background: linear-gradient(135deg, rgba(192, 41, 41, 0.8), rgba(150, 30, 30, 0.8));
          border: 2px solid #c7ab7a;
          border-radius: 12px;
          padding: 6px 12px;
          margin: 0 2px;
          box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
          transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        .memory-btn:hover, .clock-btn:hover, .bluetooth-btn:hover, .network-btn:hover,
        .volume-btn:hover, .battery-btn:hover, .layout-btn:hover, .notifications-btn:hover {
          background: linear-gradient(135deg, rgba(220, 50, 50, 0.9), rgba(180, 40, 40, 0.9));
          border-color: #d4c89a;
          transform: translateY(-1px);
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
        }

        .window-title {
          background: linear-gradient(135deg, rgba(184, 119, 219, 0.9), rgba(150, 90, 180, 0.9));
          border: 2px solid rgba(199, 171, 122, 0.6);
          border-radius: 15px;
          padding: 8px 20px;
          font-weight: bold;
          color: #000000;
          box-shadow: 0 2px 10px rgba(184, 119, 219, 0.3);
          min-width: 200px;
          transition: all 0.3s ease;
        }

        .window-title:hover {
          box-shadow: 0 4px 15px rgba(184, 119, 219, 0.5);
          transform: scale(1.02);
        }

        /* Left Bar Styling */
        .left-bar {
          background-color: rgba(20, 20, 30, 0.95);
          backdrop-filter: blur(10px);
          border-right: 2px solid rgba(199, 171, 122, 0.3);
          padding: 10px 8px;
          transition: all 0.3s ease;
        }

        /* Workspaces */
        .workspaces-section {
          margin-bottom: 15px;
        }

        .workspace {
          background: linear-gradient(135deg, rgba(46, 52, 64, 0.8), rgba(40, 45, 55, 0.8));
          border: 2px solid #b877db;
          border-radius: 12px;
          padding: 8px 12px;
          margin: 2px 0;
          font-size: 11px;
          min-width: 50px;
          text-align: center;
          box-shadow: 0 2px 6px rgba(0, 0, 0, 0.2);
          transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        .workspace:hover {
          background: linear-gradient(135deg, rgba(60, 70, 85, 0.9), rgba(55, 65, 80, 0.9));
          border-color: #c98adb;
          transform: scale(1.05) translateX(3px);
          box-shadow: 0 3px 8px rgba(0, 0, 0, 0.3);
        }

        .workspace.active {
          background: linear-gradient(135deg, rgba(105, 204, 43, 0.9), rgba(85, 170, 30, 0.9));
          border-color: #ff9f00;
          color: #000000;
          box-shadow: 0 3px 10px rgba(105, 204, 43, 0.4);
          animation: pulse 2s infinite;
        }

        @keyframes pulse {
          0%, 100% { box-shadow: 0 3px 10px rgba(105, 204, 43, 0.4); }
          50% { box-shadow: 0 3px 15px rgba(105, 204, 43, 0.7); }
        }

        /* Left bar buttons */
        .left-clock, .weather-btn, .cpu-btn, .gpu-btn,
        .launcher-btn, .vscode-btn, .chrome-btn, .insomnia-btn,
        .power-btn, .restart-btn {
          background: linear-gradient(135deg, rgba(192, 41, 41, 0.8), rgba(150, 30, 30, 0.8));
          border: 2px solid #c7ab7a;
          border-radius: 10px;
          padding: 8px 10px;
          margin: 2px 0;
          box-shadow: 0 2px 6px rgba(0, 0, 0, 0.2);
          min-width: 60px;
          text-align: center;
          transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        .left-clock:hover, .weather-btn:hover, .cpu-btn:hover, .gpu-btn:hover,
        .launcher-btn:hover, .vscode-btn:hover, .chrome-btn:hover, .insomnia-btn:hover,
        .power-btn:hover, .restart-btn:hover {
          background: linear-gradient(135deg, rgba(220, 50, 50, 0.9), rgba(180, 40, 40, 0.9));
          border-color: #d4c89a;
          transform: translateX(3px) scale(1.02);
          box-shadow: 0 4px 10px rgba(0, 0, 0, 0.4);
        }

        /* Spotify widget special styling */
        .spotify-btn {
          border: 2px solid #c7ab7a;
          border-radius: 10px;
          padding: 8px 10px;
          margin: 2px 0;
          background: linear-gradient(135deg, rgba(136, 136, 136, 0.8), rgba(100, 100, 100, 0.8));
          box-shadow: 0 2px 6px rgba(0, 0, 0, 0.2);
          min-width: 60px;
          text-align: center;
          transition: all 0.3s ease;
        }

        .spotify-btn:hover {
          transform: translateX(3px) scale(1.02);
          box-shadow: 0 4px 10px rgba(0, 0, 0, 0.4);
        }

        /* Power popup */
        .power-popup {
          background-color: rgba(20, 20, 30, 0.95);
          backdrop-filter: blur(15px);
          border: 2px solid #c7ab7a;
          border-radius: 15px;
          padding: 20px;
          box-shadow: 0 8px 32px rgba(0, 0, 0, 0.6);
          animation: slideInUp 0.3s ease;
        }

        @keyframes slideInUp {
          from {
            opacity: 0;
            transform: translateY(20px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }

        .power-popup button {
          background: linear-gradient(135deg, rgba(192, 41, 41, 0.8), rgba(150, 30, 30, 0.8));
          border: 2px solid #c7ab7a;
          border-radius: 10px;
          padding: 12px 16px;
          font-size: 14px;
          color: #ffffff;
          transition: all 0.2s ease;
          min-width: 140px;
          margin: 4px 0;
        }

        .power-popup button:hover {
          background: linear-gradient(135deg, rgba(220, 50, 50, 0.9), rgba(180, 40, 40, 0.9));
          border-color: #d4c89a;
          transform: scale(1.05);
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
        }

        .power-popup label {
          color: #ffffff;
          font-weight: bold;
        }

        /* Spotify popup and thumb */
        .spotify-thumb {
          margin: 12px 0;
          padding: 4px;
          border: 2px solid #c7ab7a;
          border-radius: 8px;
          background-color: rgba(20, 20, 30, 0.9);
          transition: all 0.3s ease;
        }

        .spotify-thumb:hover {
          border-color: #1db954;
          box-shadow: 0 4px 12px rgba(29, 185, 84, 0.3);
        }

        .spotify-popup {
          background-color: rgba(20, 20, 30, 0.95);
          backdrop-filter: blur(15px);
          border-radius: 15px;
          border: 2px solid #1db954;
          padding: 15px;
          color: white;
          box-shadow: 0 8px 32px rgba(0, 0, 0, 0.6);
          animation: slideInUp 0.3s ease;
        }

        /* Smooth animations for all interactive elements */
        button {
          cursor: pointer;
        }

        /* Tooltips */
        tooltip {
          background-color: rgba(30, 30, 40, 0.95);
          border: 1px solid #c7ab7a;
          border-radius: 8px;
          padding: 8px 12px;
          color: #ffffff;
          font-size: 11px;
        }

    '';
    };

    # eww_windows.yuck
    home.file.".config/eww/eww_windows.yuck" = {
    text = ''

    (defwindow power_popup
      :monitor 0
      :geometry (geometry :x 850 :y 420 :width 220 :height 240)
      :stacking "overlay"
      :visible false
      (box
        :class "power-popup"
        :orientation "vertical"
        :spacing 15
        :halign "center"
        :valign "center"
        :space-evenly true

        (button :onclick "hyprlock" (label :text "🔒 Lock"))
        (button :onclick "hyprctl dispatch exit 0" (label :text "🚪 Logout"))
        (button :onclick "systemctl reboot" (label :text "🔄 Reboot"))
        (button :onclick "systemctl poweroff" (label :text "⏻ Shutdown"))
      )
    )

    (defwindow spotify_thumb
      :monitor 0
      :geometry (geometry :x 12 :y 120 :width 48 :height 48)
      :stacking "overlay"
      (box
        :class "spotify-thumb"
        (image :path "/tmp/spotify_cover.jpg" :width 40 :height 40)
      )
    )

    (defwindow spotify_popup
      :monitor 0
      :geometry (geometry :x 100 :y 100 :width 250 :height 250)
      :stacking "overlay"
      :visible false
      (box
        :class "spotify-popup"
        :orientation "vertical"
        :spacing 10
        (image
          :path "/tmp/spotify_cover.jpg"
          :width 200
          :height 200
        )
      )
    )

    (defpoll weather :interval "1800s" "curl -s 'wttr.in?format=1'")
    (defpoll gpu_temp :interval "10s" "~/.config/waybar/scripts/gpu-status.sh")
    (defpoll memory :interval "3s" "free -h | awk \"/^Mem:/ {print \\\" \\\" \\$3 \\\"/\\\" \\$2}\"")
    (defpoll cpu_usage :interval "3s" "top -bn1 | grep Cpu | awk \"{print \\$2}\" | cut -d\"%\" -f1")
    (defpoll active_window :interval "1s" "hyprctl activewindow -j | jq -r '.title' 2>/dev/null || echo 'Desktop'")
    (defpoll workspaces :interval "1s" "hyprctl workspaces -j | jq -r 'map(select(.id > 0)) | sort_by(.id) | map(.id) | join(\",\")'")
    (defpoll active_workspace :interval "0.5s" "hyprctl activeworkspace -j | jq -r '.id'")
    (defpoll volume :interval "1s" "pactl get-sink-volume @DEFAULT_SINK@ | awk \"{print \\$5}\" | tr -d \"%\"")
    (defpoll bluetooth :interval "5s" "bluetoothctl show | grep \"Powered: yes\" > /dev/null && echo \"󰂯\" || echo \"󰂲\"")
    (defpoll network :interval "5s" "nmcli -t -f ACTIVE,SSID dev wifi | awk -F: \"\\$1==\\\"yes\\\" {print \\\"  \\\" \\$2}\" | head -1 || echo \"󰈀 Ethernet\"")
    (defpoll battery :interval "30s" "upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null | grep percentage | awk \"{print \\$2}\" || echo \"\"")
    (defpoll layout :interval "1s" "hyprctl devices | grep \"active keymap:\" | head -1 | sed \"s/.*active keymap: //\" | awk \"{if(\\$0 ~ /Greek/) print \\\"🇬🇷\\\"; else print \\\"🇺🇸\\\"}\"")
    (defpoll notifications :interval "2s" "swaync-client --count")
    (defpoll spotify_info :interval "2s" "~/.config/eww/scripts/spotify.sh")
    (defpoll current_date :interval "60s" "date '+%A %d %B %Y'")
    (defpoll current_time :interval "60s" "date '+%H:%M'")
    (defpoll notification_text :interval "2s" "count=$(swaync-client --count); if [ $count -gt 0 ]; then echo \"🔔 $count\"; else echo \"🔔\"; fi")
    (defpoll ws1_class :interval "0.5s" "active=$(hyprctl activeworkspace -j | jq -r '.id'); if [ \"$active\" = \"1\" ]; then echo \"workspace active\"; else echo \"workspace\"; fi")
    (defpoll ws2_class :interval "0.5s" "active=$(hyprctl activeworkspace -j | jq -r '.id'); if [ \"$active\" = \"2\" ]; then echo \"workspace active\"; else echo \"workspace\"; fi")
    (defpoll ws3_class :interval "0.5s" "active=$(hyprctl activeworkspace -j | jq -r '.id'); if [ \"$active\" = \"3\" ]; then echo \"workspace active\"; else echo \"workspace\"; fi")
    (defpoll ws4_class :interval "0.5s" "active=$(hyprctl activeworkspace -j | jq -r '.id'); if [ \"$active\" = \"4\" ]; then echo \"workspace active\"; else echo \"workspace\"; fi")

    (defwindow top_bar
      :monitor 0
      :geometry (geometry :x 0 :y 0 :width "100%" :height 35)
      :stacking "bottom"
      :anchor "top left right"
      :exclusive true
      :visible true
      (box
        :class "top-bar"
        :orientation "horizontal"
        
        ; Left section
        (box
          :class "top-left"
          :halign "start"
          :hexpand false
          (button :class "memory-btn" :tooltip "Memory usage" (label :text memory))
        )
        
        ; Center section
        (box
          :class "top-center"
          :halign "center"
          :hexpand true
          (button :class "window-title" :tooltip "Active window" 
            (label :text active_window :limit-width 50)
          )
        )
        
        ; Right section
        (box
          :class "top-right"
          :halign "end"
          :hexpand false
          :spacing 5
          
          (button :class "clock-btn" :tooltip "Click for calendar"
            :onclick "gnome-calendar || zenity --calendar"
            (label :text "📅{current_date}")
          )
          
          (button :class "bluetooth-btn" :tooltip "Bluetooth"
            :onclick "env GDK_BACKEND=x11 blueman-manager"
            (label :text bluetooth)
          )
          
          (button :class "network-btn" :tooltip "Network settings"
            :onclick "alacritty -e nmtui"
            (label :text network)
          )
          
          (button :class "volume-btn" :tooltip "Volume control"
            :onclick "pavucontrol"
            (label :text "🔊 {volume}%")
          )
          
          (button :class "battery-btn" :tooltip "Battery info" 
            :visible {battery != ""}
            (label :text "🔋 {battery}")
          )
          
          (button :class "layout-btn" :tooltip "Switch keyboard layout"
            :onclick "hyprctl switchxkblayout current next"
            (label :text layout)
          )
          
          (button :class "notifications-btn" :tooltip "Notifications"
            :onclick "swaync-client -t"
            (label :text notification_text)
          )
        )
      )
    )

    (defwindow left_bar
      :monitor 0
      :geometry (geometry :x 0 :y 35 :width 80 :height "calc(100% - 35px)")
      :stacking "bottom"
      :anchor "left top bottom"
      :exclusive true
      :visible true
      (box
        :class "left-bar"
        :orientation "vertical"
        :spacing 8
        
        ; Workspaces section
        (box
          :class "workspaces-section"
          :orientation "vertical"
          :spacing 4
          
          (button 
            :class ws1_class
            :onclick "hyprctl dispatch workspace 1"
            :tooltip "Workspace 1"
            (label :text "1")
          )
          (button 
            :class ws2_class
            :onclick "hyprctl dispatch workspace 2"
            :tooltip "Workspace 2"
            (label :text "2")
          )
          (button 
            :class ws3_class
            :onclick "hyprctl dispatch workspace 3"
            :tooltip "Workspace 3"
            (label :text "3")
          )
          (button 
            :class ws4_class
            :onclick "hyprctl dispatch workspace 4"
            :tooltip "Workspace 4"
            (label :text "4")
          )
        )
        
        ; Main widgets
        (box
          :class "main-widgets"
          :orientation "vertical"
          :spacing 8
          :valign "start"
          
          (button :class "left-clock" :tooltip "Current time"
            (label :text "⏰\n{current_time}")
          )
          
          (button :class "weather-btn" :tooltip "Weather in Athens"
            (label :text weather)
          )
          
          (button :class "cpu-btn" :tooltip "CPU usage"
            (label :text " {cpu_usage}%")
          )
          
          (button :class "gpu-btn" :tooltip "GPU temperature"
            (label :text gpu_temp)
          )
          
          ; App launchers
          (button :class "launcher-btn" :tooltip "App Launcher"
            :onclick "rofi -show drun -config ~/.config/rofi/launcher.rasi"
            (label :text "󰌧")
          )
          
          (button :class "vscode-btn" :tooltip "Visual Studio Code"
            :onclick "code --enable-features=UseOzonePlatform --ozone-platform=wayland"
            (label :text "󰘐")
          )
          
          (button :class "chrome-btn" :tooltip "Google Chrome"
            :onclick "google-chrome-stable"
            (label :text "󰊯")
          )
          
          (button :class "insomnia-btn" :tooltip "Insomnia"
            :onclick "insomnia"
            (label :text "󱂛")
          )
          
          ; Spotify widget
          (button :class "spotify-btn" :tooltip "Spotify controls"
            :onclick "playerctl -p spotify play-pause"
            :onrightclick "playerctl -p spotify next"
            :onmiddleclick "playerctl -p spotify previous"
            (label :text spotify_info)
          )
        )
        
        ; Bottom widgets
        (box
          :class "bottom-widgets"
          :orientation "vertical"
          :spacing 8
          :valign "end"
          
          (button :class "power-btn" :tooltip "Power Menu"
            :onclick "eww open power_popup"
            (label :text "⏻")
          )
          
          (button :class "restart-btn" :tooltip "Restart EWW"
            :onclick "pkill eww && sleep 1 && eww daemon && eww open top_bar && eww open left_bar"
            (label :text "🔄")
          )
        )
      )
    )
    '';
    };

    #{# Scripts #}
    home.file.".config/eww/scripts/spotify.sh" = {
      text = ''
        #!/usr/bin/env bash
        
        if ! (playerctl --list-all 2>/dev/null | grep -q spotify); then
          echo ""
          exit 0
        fi
        
        status=$(playerctl status -p spotify 2>/dev/null)
        if [ "$status" != "Playing" ] && [ "$status" != "Paused" ]; then
          echo ""
          exit 0
        fi
        
        artist=$(playerctl metadata -p spotify artist)
        title=$(playerctl metadata -p spotify title)
        
        short_title=$(echo "$title" | cut -c1-8)
        short_artist=$(echo "$artist" | cut -c1-8)
        
        icon=""
        [ "$status" = "Playing" ] && icon=""
        
        echo "$icon\n$short_artist\n$short_title"
      '';
      executable = true;
    };

    home.file.".config/eww/scripts/wifi.sh" = {
      text = ''
        #!/usr/bin/env bash
        nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2
      '';
      executable = true;
    };

    home.file.".config/eww/scripts/battery.sh" = {
      text = ''
        #!/usr/bin/env bash
        capacity=$(cat /sys/class/power_supply/BAT0/capacity)
        status=$(cat /sys/class/power_supply/BAT0/status)

        echo "$status $capacity%"
      '';
      executable = true;
    };

    # script for spotify thumb window using eww
    home.file.".config/eww/spotify-thumb.sh" = {
      executable = true;
      text = ''

          #!/usr/bin/env bash

          # Output empty JSON for Waybar to stay happy
          echo '{"text": ""}'

          # Only proceed if Spotify is running and active
          if playerctl --list-all 2>/dev/null | grep -q spotify; then
            status=$(playerctl status -p spotify 2>/dev/null)
            if [[ "$status" == "Playing" || "$status" == "Paused" ]]; then
              arturl=$(playerctl metadata -p spotify mpris:artUrl 2>/dev/null | sed 's/open.spotify.com/i.scdn.co/')
              if [[ -n "$arturl" ]]; then
                wget -q "$arturl" -O /tmp/spotify_cover.jpg
              fi
              #eww open spotify_thumb &>/dev/null
              exit 0
            fi
          fi

          #eww close spotify_thumb &>/dev/null

      '';
    };
    #{# End Scripts #}

    # systemd service that starts eww on login
    # systemd.user.services.eww = {
    #   Unit = {
    #     Description = "Eww daemon";
    #     After = [ "graphical-session.target" "xdg-desktop-autostart.target" ];
    #     PartOf = [ "graphical-session.target" ];
    #     WantedBy = [ "default.target" ];
    #   };

    #   Service = {
    #     ExecStart = "${pkgs.eww}/bin/eww daemon";
    #     ExecStartPost = "${pkgs.eww}/bin/eww open keepalive";
    #     Restart = "on-failure";
    #   };

    #   Install = {
    #     WantedBy = [ "default.target" ];
    #   };
    # };
  
    # Install noto fonts
    home.packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      jetbrains-mono
    ];
}