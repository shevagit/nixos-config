{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    code-cursor
    # claude-code — installed via native installer (~/.local/bin/claude), auto-updates
    opencode
  ];
}