# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/common/bluetooth.nix
      ../../modules/common/virt-manager.nix
      ../../modules/hardware/nvidia.nix
      ../../modules/common/hyprland.nix
      ../../modules/common/hyprland-extras.nix
      ../../modules/common/docker.nix
      ../../modules/common/extraHosts.nix
      ../../modules/services/systemd-tmpfiles-rules.nix
      ../../modules/common/tailscale.nix
      ../../modules/services/yubi-auth.nix
      ../../modules/common/display-manager.nix
      ../../modules/common/desktop-environment.nix
      ../../modules/common/shokz-fix.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-71011c21-d4ea-4506-b3f2-a909a67ba871".device = "/dev/disk/by-uuid/71011c21-d4ea-4506-b3f2-a909a67ba871";
  networking.hostName = "simos";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

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

  # disable input method framework
  # i18n.inputMethod.enable = false;

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
    wireplumber.enable = true;  # Session manager needed for DMS audio controls
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
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
 
  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # enable dbus and fwupd for firmware updates
  services.dbus.enable = true;
  services.fwupd.enable = true;

  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    docker
    gnome-tweaks
    comma
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    download-buffer-size = 524288000;
  };

  # SOPS secrets management
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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
