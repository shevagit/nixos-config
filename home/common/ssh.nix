{ osConfig, ... }:
let
  host = osConfig.networking.hostName;
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [ "~/.config/colima/ssh_config" ];
    settings = {
      "github.com" = {
        User = "shevagit";
        IdentityFile = "~/.ssh/nix${host}-p";
        IdentitiesOnly = "yes";
      };
      "github-work" = {
        HostName = "github.com";
        User = "sheva-lw";
        IdentityFile = "~/.ssh/nix${host}-w";
        IdentitiesOnly = "yes";
      };
    };
  };
}
