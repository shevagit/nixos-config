{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    code-cursor
    claude-code
  ];
}