{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz";
    sha256 = "15k41il0mvmwyv6jns4z8k6khhmb22jk5gpcqs1paym3l01g6abn";
  };
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.users.sheva = {
    /* The home.stateVersion option does not have a default and must be set */
    home.stateVersion = "24.11";
    /* Here goes the rest of your home-manager config, e.g. home.packages = [ pkgs.foo ]; */
    home.file = {
        ".foorc" = {
            text = ''
                Hello, world!
            '';
        };
    };
  };
}
