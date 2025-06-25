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
          font-family: JetBrainsMono, "Noto Color Emoji", sans-serif;
        }

        .power-popup {
          background-color: rgba(30, 30, 46, 0.6); // translucent
          border-radius: 12px;
          padding: 16px;
          box-shadow: 0 0 20px rgba(0, 0, 0, 0.6);
          transition: all 0.25s ease;
        }

        .power-popup button {
          background-color:rgba(69, 71, 90, 0.8);
          border-radius: 8px;
          padding: 10px 12px;
          font-size: 16px;
          color: rgba(205, 214, 244, 0.9);
          transition: background 0.2s, transform 0.1s ease;
          min-width: 140px;
        }

        .power-popup button:hover {
          background-color: rgba(69, 71, 90, 0.8);
        }

        .power-popup label {
          color: rgba(205, 214, 244, 0.9);
          font-weight: 500;
          text-shadow: 1px 1px #1e1e2e;
        }

        .spotify-thumb {
          margin: 12px 0;
          padding: 4px;
          border: 2px solid #c7ab7a;
          border-radius: 8px;
          background-color: #2b2b2b;
        }

        .spotify-popup {
          background-color: #222;
          border-radius: 12px;
          border: 2px solid #1db954;
          padding: 10px;
          color: white;
        }

        .left-bar {
          background-color: rgba(30, 30, 46, 0.8);
          border-radius: 0 12px 12px 0;
          padding: 10px 4px;
          transition: width 0.25s ease, padding 0.25s ease;
          box-shadow: 4px 0 12px rgba(0, 0, 0, 0.5);
        }

        .dock-box {
          background-color: #1e1e2eff;
          border-radius: 20px;
          padding: 10px;
          box-shadow: 0 4px 20px #00000088;
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

    (defwindow left_bar
      :monitor 0
      :geometry (geometry :x 0 :y 0 :width 60 :height 1080)
      :stacking "bottom"
      :anchor "left center"
      :exclusive true
      :visible true
      (box
        :class "left-bar"
        :orientation "vertical"
        :halign "center"
        :valign "start"
        :spacing 20

        (label :class "clock" :text (strftime "%H:%M"))
        (label :class "weather" :text (weather))
        (label :class "gpu-temp" :text (gpu_temp))

        (button :onclick "google-chrome-stable &" (label :text "🌐"))
        (button :onclick "code --enable-features=UseOzonePlatform --ozone-platform=wayland &" (label :text "🧠"))
        (button :onclick "insomnia &" (label :text "💤"))
      )
    )
    '';
    };

    #{# Scripts #}
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
      noto-fonts-emoji
      jetbrains-mono
    ];
}