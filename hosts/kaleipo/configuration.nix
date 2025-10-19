{ config, pkgs, ... }:

{
  imports = [
    # Hardware scan
    ./hardware-configuration.nix

    # Server modules
    # ../../modules/server/base.nix
    # ../../modules/server/nginx.nix
    # ../../modules/server/fail2ban.nix
    # ../../modules/server/acme.nix
    # ../../modules/common/docker.nix
    ../../modules/common/tailscale.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = "kaleipo";

  # Network configuration
  # For a server, you might want to use static networking instead of NetworkManager
  # Uncomment and configure as needed:
  # networking.interfaces.eth0.ipv4.addresses = [{
  #   address = "192.168.1.100";
  #   prefixLength = 24;
  # }];
  # networking.defaultGateway = "192.168.1.1";
  # networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # Or use NetworkManager (simpler for homelab):
  networking.networkmanager.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # User account
  users.users.sheva = {
    isNormalUser = true;
    description = "andreas sheva";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  # zsh is enabled in home manager, but is not recognized if I don't add it here
  programs.zsh.enable = true;

  # Allow unfree packages (needed for some proprietary software)
  nixpkgs.config.allowUnfree = true;

  # Enable nix flakes and nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data were taken.
  system.stateVersion = "24.11"; # Don't change this after initial install
}
