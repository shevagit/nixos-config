{ config, ... }:

{
  # DMS (Dank Material Shell) configuration
  # Using mkOutOfStoreSymlink so DMS UI can write changes directly to the git repo
  # Changes can then be committed and shared across machines
  home.file.".config/DankMaterialShell/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "/home/sheva/githubdir/nixos-config/home/common/dms/settings.json";
}
