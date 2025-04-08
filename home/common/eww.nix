{
    programs.eww = {
      enable = true;
    };

    home.file.".config/eww/eww.yuck" = {
    text = ''
        (defwidget sidebar []
        (box :class "sidebar"
            :orientation "v"
            (button :onclick "foot" :tooltip "Terminal" (label :text ""))
            (button :onclick "firefox" :tooltip "Browser" (label :text ""))
            (button :onclick "rofi -show run" :tooltip "Run" (label :text ""))
        )
        )

        (window
        :name "sidebar"
        :anchor "right top"
        :exclusive false
        :focusable false
        :geometry (geometry :x "10px" :y "10px" :width "60px" :height "auto")
        :stacking "fg"
        :visible true
        sidebar)
    '';
    };

    home.file.".config/eww/eww.scss" = {
    text = ''
        $bg: rgba(30, 30, 46, 0.9);
        $fg: #cdd6f4;

        * {
        all: unset;
        font-family: "JetBrainsMono Nerd Font";
        font-size: 20px;
        color: $fg;
        }

        .sidebar {
        background-color: $bg;
        border-radius: 12px;
        padding: 10px;
        box-shadow: 0 0 10px rgba(0,0,0,0.5);
        spacing: 12px;
        }
    '';
    };

}