{ pkgs, lib, config, ... }:

{
  # swww animated wallpaper daemon package
  home.packages = with pkgs; [
    swww
  ];

  # Create a script that swww/hyprpanel can use to get the background path
  # The actual wallpaper is at ~/Pictures/hyprlock-wallpaper.jpeg
  home.activation.createBackgroundLink = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD ln -sf $VERBOSE_ARG \
      ${config.home.homeDirectory}/Pictures/hyprlock-wallpaper.jpeg \
      ${config.home.homeDirectory}/.config/background
  '';

  # Wallpaper scripts for swww
  home.file = {
    ".config/hyprland/scripts/wallpaper-init.sh".text = ''
      #!/usr/bin/env bash
      # Initialize swww with wallpaper
      sleep 1
      
      # Set initial wallpaper
      if [ -f ~/Pictures/hyprlock-wallpaper.jpeg ]; then
        swww img ~/Pictures/hyprlock-wallpaper.jpeg --transition-type wipe --transition-duration 2
      fi
      
      # Start wallpaper rotation if wallpapers directory exists
      if [ -d ~/Pictures/wallpapers ]; then
        ~/.config/hyprland/scripts/wallpaper-rotate.sh &
      fi
    '';
  };
  home.file.".config/hyprland/scripts/wallpaper-init.sh".executable = true;

  home.file = {
    ".config/hyprland/scripts/wallpaper-rotate.sh".text = ''
      #!/usr/bin/env bash
      # Rotate wallpapers every 30 minutes
      WALLPAPER_DIR="$HOME/Pictures/wallpapers"
      INTERVAL=1800

      if [ ! -d "$WALLPAPER_DIR" ]; then
        echo "Wallpaper directory $WALLPAPER_DIR not found"
        exit 1
      fi

      while true; do
        # Get all wallpapers - use null delimiter to handle spaces properly
        wallpapers=()
        while IFS= read -r -d $'\0' file; do
          wallpapers+=("$file")
        done < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.mp4" -o -iname "*.webm" \) -print0 | sort -z)
        
        if [ ''${#wallpapers[@]} -eq 0 ]; then
          echo "No wallpapers found in $WALLPAPER_DIR"
          exit 1
        fi

        for wallpaper in "''${wallpapers[@]}"; do
          swww img "$wallpaper" --transition-type random --transition-duration 3
          sleep $INTERVAL
        done
      done
    '';
  };
  home.file.".config/hyprland/scripts/wallpaper-rotate.sh".executable = true;

  home.file = {
    ".config/hyprland/scripts/wallpaper-next.sh".text = ''
      #!/usr/bin/env bash
      # Switch to next wallpaper manually
      WALLPAPER_DIR="$HOME/Pictures/wallpapers"
      CURRENT_FILE="/tmp/swww_current_wallpaper"

      if [ ! -d "$WALLPAPER_DIR" ]; then
        echo "Wallpaper directory $WALLPAPER_DIR not found"
        exit 1
      fi

      # Get all wallpapers - use null delimiter to handle spaces properly
      wallpapers=()
      while IFS= read -r -d $'\0' file; do
        wallpapers+=("$file")
      done < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.mp4" -o -iname "*.webm" \) -print0 | sort -z)
      
      if [ ''${#wallpapers[@]} -eq 0 ]; then
        echo "No wallpapers found in $WALLPAPER_DIR"
        exit 1
      fi

      # Get current wallpaper index
      current_index=0
      if [ -f "$CURRENT_FILE" ]; then
        current_index=$(cat "$CURRENT_FILE")
      fi

      # Move to next wallpaper
      current_index=$(( (current_index + 1) % ''${#wallpapers[@]} ))
      echo "$current_index" > "$CURRENT_FILE"

      # Set wallpaper
      swww img "''${wallpapers[$current_index]}" --transition-type grow --transition-pos 0.5,0.5 --transition-duration 2
    '';
  };
  home.file.".config/hyprland/scripts/wallpaper-next.sh".executable = true;

  home.file = {
    ".config/hyprland/scripts/wallpaper-random.sh".text = ''
      #!/usr/bin/env bash
      # Switch to random wallpaper
      WALLPAPER_DIR="$HOME/Pictures/wallpapers"

      if [ ! -d "$WALLPAPER_DIR" ]; then
        echo "Wallpaper directory $WALLPAPER_DIR not found"
        exit 1
      fi

      # Get all wallpapers - use null delimiter to handle spaces properly
      wallpapers=()
      while IFS= read -r -d $'\0' file; do
        wallpapers+=("$file")
      done < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.mp4" -o -iname "*.webm" \) -print0 | sort -z)
      
      if [ ''${#wallpapers[@]} -eq 0 ]; then
        echo "No wallpapers found in $WALLPAPER_DIR"
        exit 1
      fi

      # Pick random wallpaper
      random_index=$((RANDOM % ''${#wallpapers[@]}))
      
      # Set wallpaper with random transition
      transitions=("fade" "grow" "outer" "wave" "wipe")
      random_transition=''${transitions[$((RANDOM % ''${#transitions[@]}))]}
      
      swww img "''${wallpapers[$random_index]}" --transition-type "$random_transition" --transition-duration 2
    '';
  };
  home.file.".config/hyprland/scripts/wallpaper-random.sh".executable = true;
}
