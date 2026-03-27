{ config, pkgs, lib, ... }:

let
  nixos-artwork = pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixos-artwork";
    rev = "9d2cdedd73d64a068214482902adea3d02783ba8";
    sha256 = "1mckvjbrjx9jcans2yigyy7cw84bm75yiw26mjv9anvm264h3zpz";
  };

  wallpapersDir = "${nixos-artwork}/wallpapers";

  allFiles = builtins.readDir wallpapersDir;

  # Keep only PNG files, exclude 8k variants, xcf, and svg source files
  isWanted = name: type:
    type == "regular"
    && lib.hasSuffix ".png" name
    && !(lib.hasInfix "_8k" name);

  wallpaperFiles = lib.filterAttrs isWanted allFiles;
  wallpaperNames = builtins.attrNames wallpaperFiles;

  destDir = "${config.home.homeDirectory}/Pictures/wallpapers";
in
{
  # Copy wallpapers as real files (not symlinks) so DMS can cycle through them
  home.activation.copyNixosWallpapers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "${destDir}"
    ${lib.concatMapStringsSep "\n" (name: ''
      if [ ! -f "${destDir}/${name}" ] || [ "$(stat -c %s "${wallpapersDir}/${name}")" != "$(stat -c %s "${destDir}/${name}")" ]; then
        $DRY_RUN_CMD cp $VERBOSE_ARG "${wallpapersDir}/${name}" "${destDir}/${name}"
      fi
    '') wallpaperNames}
  '';
}
