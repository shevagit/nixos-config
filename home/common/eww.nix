{
    programs.eww = {
      enable = true;
      configDir = ./skel-eww-config;
    };

    home.file.".config/eww/eww.yuck" = {
    text = ''
        (defwidget greeter [?text name]
        (box :orientation "horizontal"
            :halign "right"
            text
            (button :onclick "notify-send 'Hello' 'Hello, $${name}'"
            "Greet")))

        (defwindow example
                :monitor 0
                :geometry (geometry :x "0%"
                                    :y "20px"
                                    :width "90%"
                                    :height "30px"
                                    :anchor "top right")
                :stacking "fg"
                :reserve (struts :distance "40px" :side "top")
                :windowtype "dock"
                :wm-ignore false
        (greeter :text "Say hello!"
                :name "sheva"))

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
        }
    '';
    };

}