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
      "bar.layouts" = {
        "*" = {
          left = [
            "dashboard"
            "workspaces"
          ];
          middle = [
            "windowtitle"
          ];
          right = [
            "kbinput"
            "volume"
            "network"
            "bluetooth"
            "battery"
            "systray"
            "clock"
            "notifications"
          ];
        };
      };
    }}
EOF
    fi
  '';
}
