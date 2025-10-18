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
    # ../../modules/common/tailscale.nix
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

  # User account
  users.users.sheva = {
    isNormalUser = true;
    description = "andreas sheva";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.bash;

    # Add your SSH public key here for remote access
    # openssh.authorizedKeys.keys = [
    #   "ssh-ed25519 AAAAC3...xxxxxx"
    # ];
  };

  # Enable bash (or zsh if preferred)
  programs.bash.enable = true;

  # Allow unfree packages (needed for some proprietary software)
  nixpkgs.config.allowUnfree = true;

  # Nginx virtual hosts configuration
  # Customize this for your actual services
  services.nginx.virtualHosts = {
    # Example: Reverse proxy to a Docker container
    # "app.xamal.eu" = {
    #   enableACME = true;
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "http://localhost:8080";
    #     proxyWebsockets = true;
    #     extraConfig = ''
    #       limit_req zone=mylimit burst=10 nodelay;
    #     '';
    #   };
    # };

    # Default catch-all (optional)
    "_" = {
      default = true;
      locations."/" = {
        return = "444";  # Close connection without response
      };
    };
  };

  # ACME certificates configuration
  # Uncomment and configure when ready to issue certificates
  # security.acme.certs."xamal.eu" = {
  #   domain = "*.xamal.eu";
  #   extraDomainNames = [ "xamal.eu" ];
  #   dnsProvider = "cloudflare";
  #   environmentFile = "/run/secrets/cloudflare-api";
  #   group = "nginx";
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data were taken.
  system.stateVersion = "24.11"; # Don't change this after initial install
}
