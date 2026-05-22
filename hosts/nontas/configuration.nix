{ config, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ../../modules/common/bluetooth.nix
      ../../modules/common/virt-manager.nix
      ../../modules/hardware/amd.nix
      ../../modules/common/hyprland.nix
      ../../modules/common/hyprland-extras.nix
      ../../modules/common/docker.nix
      ../../modules/common/extraHosts.nix
      ../../modules/services/systemd-tmpfiles-rules.nix
      ../../modules/common/fprintd.nix
      ../../modules/common/howdy.nix
      ../../modules/common/tailscale.nix
      ../../modules/services/yubi-auth.nix
      ../../modules/services/speechd.nix
      ../../modules/common/display-manager.nix
      ../../modules/common/desktop-environment.nix
      ../../modules/common/nix-ld.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Strix Point needs a recent kernel for GPU/NPU support.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nontas";

  # Enable networking
  networking.networkmanager = {
    enable = true;
    settings = {
      connectivity.uri = "http://nmcheck.gnome.org/check_network_status.txt";
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Athens";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "el_GR.UTF-8";
    LC_IDENTIFICATION = "el_GR.UTF-8";
    LC_MEASUREMENT = "el_GR.UTF-8";
    LC_MONETARY = "el_GR.UTF-8";
    LC_NAME = "el_GR.UTF-8";
    LC_NUMERIC = "el_GR.UTF-8";
    LC_PAPER = "el_GR.UTF-8";
    LC_TELEPHONE = "el_GR.UTF-8";
    LC_TIME = "el_GR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Use gdm and gnome keyring and disable gnome desktop manager
  services.desktopManager.gnome.enable = false;
  services.gnome.gnome-keyring.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.sheva = {
    isNormalUser = true;
    description = "andreas sheva";
    group = "sheva";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  users.groups.sheva = {
    gid = 1000;
  };

  # zsh is enabled in home manager, but is not recognized if I don't add it here
  programs.zsh.enable = true;

  # enable dbus and fwupd for firmware updates
  services.dbus.enable = true;
  services.fwupd.enable = true;
  services.upower.enable = true;

  # Lid close: only lock (handled by Hyprland bindl -> DMS), don't suspend
  services.logind.settings.Login.HandleLidSwitch = "lock";

  # Install firefox.
  programs.firefox.enable = true;

  # Dank Material Shell (DMS) - replaces hyprpanel and waybar
  programs.dms-shell = {
    enable = true;
    systemd.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
   vim
   wget
   docker
   gnome-tweaks
   comma
   git
   brightnessctl
  ];

  # Battery charge limit: T14s G6 may expose battery as BAT1 — verify with
  # `ls /sys/class/power_supply/` and adjust the path below before enabling.
  # systemd.services.set-battery-charge-limit = {
  #   description = "Set battery charge threshold to 95%";
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "systemd-udev-settle.service" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.bash}/bin/bash -c 'echo 95 > /sys/class/power_supply/BAT0/charge_control_end_threshold'";
  #   };
  # };

  systemd.services.set-kbd-backlight = {
    description = "Set keyboard backlight brightness to 1 on boot";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-udev-settle.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.brightnessctl}/bin/brightnessctl -d tpacpi::kbd_backlight set 1";
    };
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    download-buffer-size = 524288000;
  };

  # SOPS secrets management — enable after generating an age key on this host
  # and adding it as a recipient in .sops.yaml (see INSTALL.md section 8).
   sops = {
     defaultSopsFile = ../../secrets/common/api-keys.yaml;
     age.keyFile = "/var/lib/sops-nix/key.txt";
     secrets = {
       anthropic_api_key = {
         owner = "sheva";
         mode = "0400";
       };
     };
   };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "25.05";
}
