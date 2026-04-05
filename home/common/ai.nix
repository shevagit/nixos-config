{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    code-cursor
    # claude-code — installed via npm instead; nixpkgs can't keep up with frequent releases
    opencode
  ];
}