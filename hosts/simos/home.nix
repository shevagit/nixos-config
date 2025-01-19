{ config, pkgs, ... }:

{
  # Enable Home Manager
  programs.home-manager.enable = true;

  # Specify the username and home directory
  home.username = "sheva";
  home.homeDirectory = "/home/sheva";

  # Set the state version
  home.stateVersion = "24.11"; # Please read the comment before changing.
}
