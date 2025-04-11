{ pkgs, ... }:{
  programs.vscode.extensions = with pkgs.vscode-extensions; [
    bbenoist.nix
    eamodio.gitlens
    github.copilot
    github.copilot-chat
    golang.go
    mechatroner.rainbow-csv
    ms-vscode.makefile-tools
    hashicorp.terraform
    "4ops.terraform"
  ];
}