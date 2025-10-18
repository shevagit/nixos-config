{ config, pkgs, ... }:

{
  # Minimal home-manager configuration for server
  # Most server configuration happens in configuration.nix

  home.username = "sheva";
  home.homeDirectory = "/home/sheva";

  # Basic shell configuration
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -lah";
      ".." = "cd ..";
      docker-compose = "docker compose";
    };
  };

  programs.git = {
    enable = true;
    userName = "andreas sheva";
    userEmail = "shevaneo@gmail.com";
  };

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  home.stateVersion = "24.11";
}
