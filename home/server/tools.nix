{pkgs, ...}: {
  home.packages = with pkgs; [
    zoxide
    gnumake
    ripgrep
    neovim
    nvd # closure diff viewer — used by `make diff` (desktops get it via home/default.nix)
  ];
}
