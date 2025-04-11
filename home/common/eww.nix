{ pkgs, ... }:{
    programs.eww = {
      enable = true;
      configDir = ./skel-eww-config;
    };

    home.file.".config/eww/eww.yuck" = {
    text = ''
        (defwidget clock []
        (label :text (date "%a %b %d - %H:%M")))

        (defwidget battery []
        (label :text (poll "~/.config/eww/scripts/battery.sh" :interval "10s")))

        (defwidget wifi []
        (label :text (poll "~/.config/eww/scripts/wifi.sh" :interval "15s")))

        (defwidget greeter [?name]
        (button
            :onclick "notify-send 'Hi' 'Hey there, ''${name}!'"
            :class "widget"
            "👋 ''${name}"))

        (defwindow bottom-bar
        :monitor 0
        :geometry (geometry :x "50%" :y "50%" :width "400px" :height "80px" :anchor "center")
        :stacking "fg"
        :windowtype "dock"
        :wm-ignore false
        (box :orientation "horizontal"
            :class "bar"
            (label :text "Can you see me now? 👀")))

    '';
    };

    home.file.".config/eww/eww.scss" = {
    text = ''
        $bg: rgba(30, 30, 46, 0.9);
        $fg: #cdd6f4;

        * {
        all: unset;
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 16px;
        color: $fg;
        }

        .bar {
        background-color: $bg;
        padding: 0 20px;
        border-top: 1px solid lighten($bg, 10%);
        box-shadow: 0 -2px 8px rgba(0, 0, 0, 0.3);
        }

        .widget {
        padding: 0 10px;
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
    systemd.user.services.eww-bottom = {
        Unit = {
        Description = "Eww bottom bar";
        After = [ "graphical-session.target" ];
        };

        Service = {
        ExecStart = "${pkgs.eww}/bin/eww daemon --no-daemon && ${pkgs.eww}/bin/eww open bottom-bar";
        Restart = "on-failure";
        };

        Install = {
        WantedBy = [ "default.target" ];
        };
    };
}