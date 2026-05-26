{ osConfig, ... }:
let
  host = osConfig.networking.hostName;
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [ "~/.config/colima/ssh_config" ];
    matchBlocks = {
      "github.com" = {
        user = "shevagit";
        identityFile = "~/.ssh/nix${host}-p";
        extraOptions = { IdentitiesOnly = "yes"; };
      };
      "github-work" = {
        hostname = "github.com";
        user = "sheva-lw";
        identityFile = "~/.ssh/nix${host}-w";
        extraOptions = { IdentitiesOnly = "yes"; };
      };
    };
  };
}
