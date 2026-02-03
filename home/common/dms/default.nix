{ config, pkgs, ... }:

{
  # DMS (Dank Material Shell) configuration
  # Using a default template that gets copied to a local settings.json (gitignored)
  # Each machine maintains its own settings, but new machines start with the default

  # Initialize settings.json from default if it doesn't exist
  home.activation.dmsCopyDefaultSettings = config.lib.dag.entryAfter ["writeBoundary"] ''
    SETTINGS_DIR="${config.home.homeDirectory}/githubdir/nixos-config/home/common/dms"
    if [ ! -f "$SETTINGS_DIR/settings.json" ]; then
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/cp "$SETTINGS_DIR/settings.json.default" "$SETTINGS_DIR/settings.json"
      echo "Initialized DMS settings from default template"
    fi
  '';

  # Symlink to the local settings.json (which is gitignored)
  home.file.".config/DankMaterialShell/settings.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "/home/sheva/githubdir/nixos-config/home/common/dms/settings.json";
    force = true;  # Allow overwriting existing file
  };
}
