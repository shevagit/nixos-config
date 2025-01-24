{
    programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
    };
    environment.sessionVariables = {
        WLR_NO_HARDWARE_CURSORS = "1";
  };

}