{pkgs, ...}: {
  home.packages = with pkgs; [
    zoxide
    gnumake
    ripgrep
    neovim
  ];
}
