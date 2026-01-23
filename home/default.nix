{ config, pkgs, ... }:

{
  home.username = "sheva";
  home.homeDirectory = "/home/sheva";

  programs.nix-index = {
    enable = true;
  };

  # Notification daemons disabled - using HyprPanel's built-in notification service
  # services.mako.enable = true;
  # services.swaync.enable = true;

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  # Override MongoDB Compass desktop entry to include Wayland and password store flags
  xdg.desktopEntries.mongodb-compass = {
    name = "MongoDB Compass";
    comment = "The MongoDB GUI";
    genericName = "MongoDB Compass";
    exec = "mongodb-compass --ignore-additional-command-line-flags --enable-features=UseOzonePlatform --ozone-platform=wayland --password-store=gnome-libsecret %U";
    icon = "mongodb-compass";
    type = "Application";
    startupNotify = true;
    categories = [ "GNOME" "GTK" "Utility" ];
    mimeType = [ "x-scheme-handler/mongodb" "x-scheme-handler/mongodb+srv" ];
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    google-chrome
    git
    gnumake
    vscode
    wezterm
    alacritty
    terminator
    neofetch
    nnn # terminal file manager
    mongodb-compass
    mongosh
    insomnia
    terraform
    gnome-keyring # required by mongodb-compass
    libreoffice
    rclone
    linkerd
    neovim
    tree-sitter
    fd
    zoom-us

    # gitlab and github cli
    glab
    gh
    
    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
    nss_latest # certutil
    mkcert
    duf
    zoxide
    lazydocker

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils  # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc  # it is a calculator for the IPv4/v6 addresses

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg
    flameshot
    grimblast
    swappy
    blueman
    discord
    slack
    weather
    wthrr
    spotify
    playerctl

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor
    nvd # used for diff

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal

    btop  # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
  ];

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
