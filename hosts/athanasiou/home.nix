{
  imports = [
    ../../home
    ../../home/common
  ];
  # override home manager configuration
  wayland.windowManager.hyprland.settings.monitor = [
    "eDP-1,1920x1080@60,0x0,1"
  ];
  
  # Override vscode.extensions
  programs.vscode.extensions = lib.mkForce null;

  programs.vscode.profiles.default.extensions = with pkgs.vscode-extensions; [
    bbenoist.nix
    eamodio.gitlens
    github.copilot
    github.copilot-chat
    golang.go
    mechatroner.rainbow-csv
    ms-vscode.makefile-tools
    hashicorp.terraform
    4ops.terraform
  ];
}