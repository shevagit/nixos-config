{ pkgs, ... }:

{
  nixpkgs.config.packageOverrides = pkgs: {
    pipewire = pkgs.pipewire.overrideAttrs (oldAttrs: rec {
      version = "1.4.2";
      src = pkgs.fetchFromGitLab {
        domain = "gitlab.freedesktop.org";
        owner = "pipewire";
        repo = "pipewire";
        rev = version;
        sha256 = "sha256-uxTzdvmazLNmWqc1v1LGiq34zV9IT0y1vTGc/+JiEU8=";
      };
    });
  };
}