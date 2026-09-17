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
  themePreset = "purple_leaves";

  # Which of the bundled presets the theme uses is decided by the ConfigFile=
  # line in the theme's metadata.desktop. nixpkgs' sddm-astronaut takes that as
  # an argument, so hand it the preset instead of copying the theme out of the
  # package and running our own sed over the copy, as this used to.
  # Upstream's substitution is anchored (^ConfigFile=Themes/.*\.conf$) where
  # ours matched the literal astronaut.conf, so ours would have silently
  # no-opped — sed exits 0 on no match — if upstream ever changed its default
  # preset, leaving us on astronaut with no error.
  # Note this does not shrink the system closure: hyprlock (home/common/
  # hyprland.nix) pulls in the *unmodified* sddm-astronaut for its lock screen
  # background, so both that and this override are present, ~22M each. Pointing
  # hyprlock at the same derivation would leave just one.
  # `themeConfig` is available here too, if individual theme keys ever need
  # overriding.
  sddm-astronaut-custom = pkgs.sddm-astronaut.override {
    embeddedTheme = themePreset;
  };
in
{
  services.displayManager.sddm = {
    enable = true;
    theme = "sddm-astronaut-theme";
    package = pkgs.kdePackages.sddm;
    wayland.enable = true;
    wayland.compositor = "kwin";

    extraPackages = with pkgs.kdePackages; [
      qtmultimedia
    ];
  };

  environment.systemPackages = [
    sddm-astronaut-custom
  ];
}
