{ config, pkgs, ... }:
{
  services.displayManager.sddm = {
    enable = true;
    theme = "sddm-astronaut-theme";
    package = pkgs.kdePackages.sddm;
    wayland.enable = true;

    extraPackages = with pkgs.kdePackages; [
      qtmultimedia
    ];

    # Override theme settings here
    # These settings override the default theme config
    settings = {
      General = {
        # Background Options (choose one):
        # Static backgrounds:
        #   - "Backgrounds/astronaut.png"
        #   - "Backgrounds/black_hole.png"
        #   - "Backgrounds/cyberpunk.png"
        #   - "Backgrounds/japanese_aesthetic.png"
        #   - "Backgrounds/pixel_sakura_static.png"
        #   - "Backgrounds/post-apocalyptic_hacker.png"
        #   - "Backgrounds/purple_leaves.png"
        # Animated backgrounds:
        #   - "Backgrounds/pixel_sakura.gif"
        #   - "Backgrounds/jake_the_dog.mp4"
        #   - "Backgrounds/hyprland_kath.mp4"
        Background = "Backgrounds/pixel_sakura.gif";

        # Animated background settings
        BackgroundSpeed = "1.0";  # Speed multiplier (0.0-10.0+)
        # PauseBackground = "false"; # Pause GIF playback

        # Other customizations
        # HeaderText = "Welcome to NixOS!";
        # DimBackground = "0.0";  # 0.0 = no dim, 1.0 = fully dimmed
        # PartialBlur = "true";
        # FormPosition = "center";  # left, center, right
      };
    };
  };

  environment.systemPackages = with pkgs; [
    sddm-astronaut
  ];
}
