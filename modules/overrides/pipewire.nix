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
          sha256 = "0kwr4a6iyij9vpxryqgjc2jk45282h4l92xv3za9md5rckdal4j7";
        };
      });
    })
  ];
}
