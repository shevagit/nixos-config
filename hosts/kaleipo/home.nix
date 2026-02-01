{ config, pkgs, ... }:

{
  imports = [
    ../../home/server
    ../../home/common/terminal.nix
    ../../home/common/kitty-kittens.nix
  ];

  home.username = "sheva";
  home.homeDirectory = "/home/sheva";

  # Let programs.home-manager.enable manage the home-manager installation
  programs.home-manager.enable = true;

  home.stateVersion = "24.11";
}
