{ pkgs, ... }:{
    programs.eww = {
      enable = true;
      configDir = ./skel-eww-config;
    };

    # Try a spotify pop-up using eww
    home.file.".config/eww/eww.yuck" = {
    text = ''

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

          # Default JSON output
          echo '{"text": ""}'

          # Only proceed silently if spotify is a known player
          if playerctl --list-all 2>/dev/null | grep -q spotify; then
            status=$(playerctl status -p spotify 2>/dev/null)
            if [[ "$status" == "Playing" || "$status" == "Paused" ]]; then
              arturl=$(playerctl metadata -p spotify mpris:artUrl 2>/dev/null | sed 's/open.spotify.com/i.scdn.co/')
              if [[ -n "$arturl" ]]; then
                wget -q "$arturl" -O /tmp/spotify_cover.jpg
              fi
              eww open spotify_thumb 2>/dev/null
              exit 0
            fi
          fi

          # Hide thumbnail
          eww close spotify_thumb 2>/dev/null
          exit 0

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
}