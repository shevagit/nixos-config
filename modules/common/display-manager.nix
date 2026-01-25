{ config, pkgs, ... }:
let
  # Choose your theme preset here:
  # Available options:
  #   - "astronaut"
  #   - "black_hole"
  #   - "cyberpunk"
  #   - "japanese_aesthetic"
  #   - "pixel_sakura_static"
  #   - "post-apocalyptic_hacker"
  #   - "purple_leaves"
  #   - "pixel_sakura" (animated gif)
  #   - "jake_the_dog" (animated mp4)
  #   - "hyprland_kath" (animated mp4)
  themePreset = "hyprland_kath";

  # Custom sddm-astronaut theme with selected preset
  sddm-astronaut-custom = pkgs.runCommand "sddm-astronaut-${themePreset}" { } ''
    mkdir -p $out/share/sddm/themes
    cp -r ${pkgs.sddm-astronaut}/share/sddm/themes/sddm-astronaut-theme $out/share/sddm/themes/
    chmod -R +w $out/share/sddm/themes/sddm-astronaut-theme

    # Change the ConfigFile to the selected theme preset
    sed -i 's|ConfigFile=Themes/astronaut.conf|ConfigFile=Themes/${themePreset}.conf|' \
      $out/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
  '';
in
{
  services.displayManager.sddm = {
    enable = true;
    theme = "sddm-astronaut-theme";
    package = pkgs.kdePackages.sddm;
    wayland.enable = true;

    extraPackages = with pkgs.kdePackages; [
      qtmultimedia
    ];
  };

  environment.systemPackages = [
    sddm-astronaut-custom
  ];
}
