{ config, pkgs, ... }:

# The astronaut theme preset is chosen in modules/common/overlays.nix, which
# defines pkgs.sddm-astronaut-themed. It lives there because hyprlock
# (home/common/hyprland.nix) reads a background image out of the same package,
# and sharing one derivation keeps a single copy in the closure.
{
  services.displayManager.sddm = {
    enable = true;
    theme = "sddm-astronaut-theme";
    package = pkgs.kdePackages.sddm;
    wayland.enable = true;
    wayland.compositor = "kwin";

    # SDDM finds the theme by path under /run/current-system/sw/share/sddm/
    # themes, not as a Nix dependency, so the Qt plugins the theme needs have
    # to be handed to the greeter explicitly here.
    extraPackages = with pkgs.kdePackages; [
      qtmultimedia
    ];
  };

  environment.systemPackages = [
    pkgs.sddm-astronaut-themed
  ];
}
