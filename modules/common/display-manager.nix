{ config, pkgs, ... }:
{
  services.displayManager.sddm = {
    enable = true;
    theme = "sddm-astronaut-theme";
    package = pkgs.kdePackages.sddm;
    wayland = {
      enable = true;
    };
    extraPackages = with pkgs.kdePackages; [
      qtmultimedia
    ];
  };

  environment.systemPackages = with pkgs; [
    sddm-astronaut
  ];
}
