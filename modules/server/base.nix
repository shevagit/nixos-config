{ config, pkgs, lib, ... }:

{
  # Essential server packages (based on your apt-manual.txt)
  environment.systemPackages = with pkgs; [
    # Basic utilities
    vim
    nano
    wget
    curl
    git
    htop
    tmux
    rsync
    unzip

    # System tools
    lsof
    socat
    netcat
    mtr
    traceroute
    bind.dnsutils  # dig, nslookup, etc.

    # Debugging and monitoring
    sysstat
    iotop

    # Build essentials
    gcc
    gnumake
    pkg-config
  ];

  # Time synchronization
  services.timesyncd.enable = true;
  time.timeZone = "Europe/Athens";  # Change as needed

  # Locale settings
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Automatic system maintenance
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;  # Set to true if you want automatic reboots
    dates = "04:00";      # Daily at 4 AM
    flake = "/home/sheva/nixos-config";  # Adjust path as needed
  };

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Optimize Nix store
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
  };

  # Enable cron
  services.cron.enable = true;

  # SSH server configuration
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
    openFirewall = true;
  };

  # Basic firewall (will be enhanced by fail2ban)
  networking.firewall = {
    enable = true;
    # SSH is handled by services.openssh.openFirewall
    # Additional ports will be opened by service-specific modules
  };

  # Sysctl security settings
  boot.kernel.sysctl = {
    # IP forwarding (needed for Docker)
    "net.ipv4.ip_forward" = 1;

    # Security hardening
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
  };
}
