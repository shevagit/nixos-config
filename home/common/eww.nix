{ pkgs, ... }:{
    programs.eww = {
      enable = true;
      configDir = ./skel-eww-config;
    };

    # Try a spotify pop-up using eww
    home.file.".config/eww/eww.yuck" = {
    text = ''

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