{ config, pkgs, ... }:

{
  # Set the username and home directory
  home.username = "sheva";
  home.homeDirectory = "/home/sheva";

  # Enable Home Manager
  programs.home-manager.enable = true;

  # Set the state version
  home.stateVersion = "24.11"; # Please read the comment before changing.
}
