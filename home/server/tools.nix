{pkgs, ...}: {
  home.packages = with pkgs; [
    zoxide
    gnumake
    ripgrep  # Used by fzf
  ];
}
