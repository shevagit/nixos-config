{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      pipewire = prev.pipewire.overrideAttrs (_: {
        version = "1.4.2";
        src = prev.fetchFromGitHub {
          owner = "PipeWire";
          repo = "pipewire";
          rev = "1.4.2";
          sha256 = "uxTzdvmazLNmWqc1v1LGiq34zV9IT0y1vTGc/+JiEU8=";
        };
      });
    })
  ];
}
