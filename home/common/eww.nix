{ pkgs, ... }:{
    programs.eww = {
      enable = true;
      configDir = ./skel-eww-config;
    };

    # Try a spotify pop-up using eww
    home.file.".config/eww/eww.yuck" = {
    text = ''

      (defwindow power_popup
        :monitor 0
        :geometry (geometry
          :x (- (/ (monitor-width) 2) 110)
          :y (- (/ (monitor-height) 2) 120)
          :width 220
          :height 240)
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

      (defwindow keepalive
        :monitor 0
        :visible false
        (box)
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
          background-color: #313244cc;
          border-radius: 8px;
          padding: 10px 12px;
          font-size: 16px;
          color: #cdd6f4;
          transition: background 0.2s, transform 0.1s ease;
          min-width: 140px;
          text-align: center;
        }

        .power-popup button:hover {
          background-color: #45475acc;
          transform: scale(1.03);
        }

        .power-popup label {
          color: #cdd6f4;
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
              eww open spotify_thumb &>/dev/null
              exit 0
            fi
          fi

          eww close spotify_thumb &>/dev/null

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