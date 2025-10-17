{ config, pkgs, lib, ... }:

{
  # Enable hyprpanel package
  home.packages = with pkgs; [
    hyprpanel
  ];

  # Configure hyprpanel initial config
  # Use home.activation instead of xdg.configFile to create a writable file
  # This allows hyprpanel to modify its own config when you change settings in the UI
  home.activation.hyprpanelConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    CONFIG_DIR="${config.home.homeDirectory}/.config/hyprpanel"
    CONFIG_FILE="$CONFIG_DIR/config.json"

    # Create directory if it doesn't exist
    $DRY_RUN_CMD mkdir -p "$CONFIG_DIR"

    # Only create config if it doesn't exist (don't overwrite user changes)
    if [ ! -f "$CONFIG_FILE" ]; then
      $DRY_RUN_CMD cat > "$CONFIG_FILE" << 'EOF'
${builtins.toJSON {
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
    }
    }
  }}
EOF
    fi
  '';
}
