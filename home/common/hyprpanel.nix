{
  programs.hyprpanel = {
    enable = true;

    settings = {
      # Configure the bar layout
      layout = {
        bar.layouts."0" = {
          left = [
            "dashboard"      # Control panel with quick settings
            "workspaces"     # Workspace switcher
          ];
          middle = [
            "windowtitle"    # Current window title
          ];
          right = [
            "network"        # Network status
            "bluetooth"      # Bluetooth controls
            "volume"         # Volume controls
            "battery"        # Battery indicator (if laptop)
            "clock"          # Clock
            "systray"        # System tray
            "notifications"  # Notification center
          ];
        };
      };

      # Dashboard configuration for quick access panel
      dashboard = {
        powermenu = {
          enable = true;
        };
      };

      # Additional bar configuration
      bar = {
        position = "bottom";  # Place HyprPanel at bottom to avoid conflict with Waybar
        transparent = true;
      };

      # Theme configuration
      theme = {
        bar = {
          transparent = true;
        };
      };

      # Menus configuration
      menus = {
        dashboard = {
          directories = {
            left = {
              leftArea1 = {
                # App launcher buttons
                label = "Applications";
                action = "rofi -show drun -config ~/.config/rofi/launcher.rasi";
              };
              leftArea2 = {
                label = "VS Code";
                action = "code --enable-features=UseOzonePlatform --ozone-platform=wayland";
              };
              leftArea3 = {
                label = "Chrome";
                action = "google-chrome-stable";
              };
            };
          };
          powermenu = {
            shutdown = "systemctl poweroff";
            reboot = "systemctl reboot";
            logout = "hyprctl dispatch exit 0";
            lock = "swaylock";
          };
          shortcuts = {
            left = {
              shortcut1 = {
                tooltip = "Wallpaper Random";
                command = "~/.config/hyprland/scripts/wallpaper-random.sh";
                icon = "preferences-desktop-wallpaper";
              };
              shortcut2 = {
                tooltip = "Wallpaper Next";
                command = "~/.config/hyprland/scripts/wallpaper-next.sh";
                icon = "image-x-generic";
              };
              shortcut3 = {
                tooltip = "App Launcher";
                command = "rofi -show drun -config ~/.config/rofi/launcher.rasi";
                icon = "application-x-executable";
              };
            };
          };
        };
      };
    };
  };
}
