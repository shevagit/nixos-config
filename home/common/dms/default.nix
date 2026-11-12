{ config, pkgs, ... }:

# DMS (Dux Modular Shell, formerly Dank Material Shell) settings, shared by
# every workstation through Syncthing.
#
# DMS owns settings.json at runtime: it rewrites it whenever something changes
# in its Settings UI, and migrates the schema on upgrades (1.x → 2.x went from
# configVersion 18 to 42). That rules out a Nix-generated file. So the live
# file sits in the Syncthing `sync` folder (modules/common/syncthing.nix), which
# every workstation already shares, and ~/.config/dms/settings.json is an
# out-of-store symlink to it. DMS watches the file, so a change made on one
# machine shows up live on the others once Syncthing delivers it.
#
# Caveats:
# - Keep the hosts on the same flake.lock. If an older DMS loads a newer-schema
#   file, it backs it up as ~/.config/dms/settings.v<N>.json and may write the
#   older schema back, which Syncthing would then spread to every host.
# - Two hosts editing settings while apart produces a
#   settings.sync-conflict-*.json next to the file; Syncthing keeps the newer
#   copy, and 30 days of old versions live in ~/sync/.stversions.
# - Per-machine state (session.json, wallpaper per monitor, app usage) lives in
#   ~/.local/state/dms and deliberately does not sync.
let
  repoDir    = "${config.home.homeDirectory}/githubdir/nixos-config/home/common/dms";
  syncedDir  = "${config.home.homeDirectory}/sync/dotfiles/dms";
  syncedFile = "${syncedDir}/settings.json";
in
{
  # Seed the synced file the first time, on whichever host gets here first:
  # that host's old repo-local settings.json (gitignored, the pre-Syncthing
  # per-machine copy) if it has one, else the committed default template.
  # Once the file exists, hosts adopt it as-is. Their old repo-local copy is
  # left untouched as a backup.
  home.activation.dmsSeedSyncedSettings = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "${syncedFile}" ]; then
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "${syncedDir}"
      if [ -f "${repoDir}/settings.json" ]; then
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/cp "${repoDir}/settings.json" "${syncedFile}"
        echo "DMS: seeded synced settings from this host's repo-local settings.json"
      else
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/cp "${repoDir}/settings.json.default" "${syncedFile}"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/chmod u+w "${syncedFile}"
        echo "DMS: seeded synced settings from settings.json.default"
      fi
    fi
  '';

  # DMS 2.x moved its config dir to ~/.config/dms and left
  # ~/.config/DankMaterialShell as a symlink to it, so this still lands in
  # ~/.config/dms/settings.json. Do NOT "fix" the path to .config/dms: Home
  # Manager removes the old generation's links *before* creating new ones, and
  # since both paths are the same file via that dir symlink, a rename would
  # delete the fresh link and then rmdir a symlink mid-activation.
  home.file.".config/DankMaterialShell/settings.json" = {
    source = config.lib.file.mkOutOfStoreSymlink syncedFile;
    force = true;  # Allow overwriting existing file
  };
}
