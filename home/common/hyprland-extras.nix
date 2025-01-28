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
      "modules-left": ["workspaces"],
      "modules-center": ["clock"],
      "modules-right": ["cpu", "memory", "battery"],
      "workspaces": {
        "hyprland": true
      },
      "clock": {
        "format": "%A, %d %B %Y, %H:%M:%S"
      },
      "battery": {
        "format": "{percent}%"
      },
      "cpu": {
        "format": "CPU: {usage}%"
      },
      "memory": {
        "format": "RAM: {used} / {total} GB"
      }
    }
  '';

  # Define Waybar styling
  home.file.".config/waybar/style.css".text = ''
    * {
      font-family: "JetBrains Mono", monospace;
      font-size: 12px;
      color: #ffffff;
      background: #1e1e2e;
    }

    #clock {
      font-size: 14px;
      padding: 0 10px;
    }

    #workspaces button {
      border: none;
      padding: 5px;
      margin: 2px;
      background-color: #2e3440;
      color: #ffffff;
      border-radius: 5px;
    }

    #workspaces button.focused {
      background-color: #88c0d0;
      color: #2e3440;
    }
  '';
};
}