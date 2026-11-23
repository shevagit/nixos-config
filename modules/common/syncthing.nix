{ config, lib, pkgs, ... }:

let
  user    = "sheva";
  home    = "/home/${user}";
  tailnet = "tail7a4d5.ts.net";
  self    = config.networking.hostName;

  # Device IDs were generated ahead of time and the matching private keys are
  # deployed per host through sops (secrets/hosts/<host>/syncthing.yaml). That
  # means every machine already knows every other machine's identity on first
  # boot — no manual device-ID pairing, which matters because simos and
  # athanasiou are rarely online at the same time as nontas.
  devices = {
    nontas     = "P2AM3C5-HSDHROK-2IGDXAO-4LQC5UP-LBUH7ZS-GOQ35XF-QMACH2O-FXKRTA5";
    simos      = "XXVPGBC-NNZ4BUR-DCL3NTJ-NAPLMD4-7QDWFUV-MTZOFNK-O7J4YCY-NO4JFQZ";
    athanasiou = "WQCNKOO-QZSCRHO-VWHTW6Z-ZDYOS5N-2QZ3MJE-2G2T372-M7J57PK-SW544A7";
    kaleipo    = "VCHUG4S-CMNYJEO-C4V4FLC-ZWKXFXF-55PL5DT-WMA7T4S-ZE2FUBX-A3ZPKA5";
  };

  peers = lib.attrNames (lib.filterAttrs (n: _: n != self) devices);

  # kaleipo is the always-on hub; the other three are where Claude actually runs.
  hub               = "kaleipo";
  workstations      = [ "nontas" "simos" "athanasiou" ];
  isHub             = self == hub;
  otherWorkstations = lib.filter (n: n != self) workstations;

  # Keep a month of overwritten versions. This is the undo button for a
  # troubleshooting session that clobbers its own output.
  versioning = {
    type = "staggered";
    params.maxAge = toString (30 * 24 * 3600);
  };

  # The working-dir folders (~/sync, ~/sync-work) are for scripts, notes and
  # session output, not for code trees, their dependencies or bulk media.
  #
  # Two layers, because .stignore itself never syncs:
  #
  # - The pattern list is syncthing-ignore.txt inside each folder. It is an
  #   ordinary synced file, so an edit on one machine reaches all of them with
  #   no rebuild. Its header holds the policy for what gets ignored.
  # - .stignore is per machine and written here. It pulls the list in with
  #   #include and adds *.nosync: anything so named stays on the machine that
  #   made it, the escape hatch for heavy session output
  #   (`<topic>/src.nosync/`, `<topic>/render.nosync/`).
  #
  # The #include is written only when the list exists: Syncthing refuses to
  # load an ignore file whose include is missing, and a fresh machine has not
  # received the list yet. The next boot or rebuild adds it.
  #
  # (?d) lets Syncthing delete an ignored file when it is the only thing
  # stopping a directory deletion that came from a peer. Without it, deleting
  # a topic on one machine leaves an undeletable husk on the others.
  stignoreBase = pkgs.writeText "stignore-base" ''
    // Per machine, NOT synced. Written by nixos-config
    // (modules/common/syncthing.nix); local edits are overwritten.
    // Shared patterns: syncthing-ignore.txt, which DOES sync.
    (?d)*.nosync
  '';
  workingDirs = [ "${home}/sync" "${home}/sync-work" ];

  # A folder that passes through the hub encrypted. kaleipo relays ciphertext it
  # holds no key for, so it needs a receiveencrypted definition pointed at a
  # blob directory, while the workstations hold the real files. Same shape for
  # every folder carrying work data.
  encryptedFolder =
    { id, path, hubPath }:
    if isHub then
      {
        ${id} = {
          inherit id;
          # Encrypted blobs with encrypted filenames, not readable files. Kept
          # away from the real paths so nothing mistakes this for usable data.
          path    = hubPath;
          type    = "receiveencrypted";
          devices = workstations;
        };
      }
    else
      {
        ${id} = {
          inherit id path versioning;
          devices = otherWorkstations ++ [{
            name                   = hub;
            encryptionPasswordFile = config.sops.secrets.syncthing-work-encryption.path;
          }];
        };
      };
in
{
  sops.secrets = {
    syncthing-cert = {
      sopsFile = ../../secrets/hosts/${self}/syncthing.yaml;
      key      = "cert";
      owner    = user;
    };
    syncthing-key = {
      sopsFile = ../../secrets/hosts/${self}/syncthing.yaml;
      key      = "key";
      owner    = user;
    };
  } // lib.optionalAttrs (!isHub) {
    # Encrypts the work-account folder before it reaches the hub. Deliberately
    # not decryptable by kaleipo — see the workstation rule in .sops.yaml.
    syncthing-work-encryption = {
      sopsFile = ../../secrets/workstations/claude-work-sync.yaml;
      key      = "encryptionPassword";
      owner    = user;
    };
  };

  # Written before syncthing starts, so a fresh machine never pulls ignored
  # content first and filters it afterwards. Workstations only: kaleipo holds
  # ciphertext with encrypted names and can't match patterns anyway.
  #
  # Also wanted by multi-user.target and kept active (RemainAfterExit), so a
  # rebuild starts it on first deploy and re-runs it when the patterns change;
  # being wanted by syncthing.service alone only runs it when syncthing
  # restarts. Syncthing picks up a changed .stignore on its next scan.
  systemd.services.syncthing-ignores = lib.mkIf (!isHub) {
    description = "Write .stignore for the Syncthing working-dir folders";
    wantedBy    = [ "multi-user.target" "syncthing.service" ];
    before      = [ "syncthing.service" ];
    serviceConfig = {
      Type            = "oneshot";
      RemainAfterExit = true;
      User            = user;
      Group           = "users";
    };
    # Assembled outside the folder and moved in whole, so Syncthing never
    # sees a half-written ignore file or a temp file worth syncing.
    script = ''
      for dir in ${lib.escapeShellArgs workingDirs}; do
        mkdir -p "$dir"
        tmp=$(mktemp)
        cat ${stignoreBase} > "$tmp"
        if [ -e "$dir/syncthing-ignore.txt" ]; then
          echo '#include syncthing-ignore.txt' >> "$tmp"
        fi
        install -m 0644 "$tmp" "$dir/.stignore"
        rm -f "$tmp"
      done
    '';
  };

  services.syncthing = {
    enable = true;

    # Runs as sheva rather than the default `syncthing` user so it can own the
    # files it syncs into the home directory.
    inherit user;
    group     = "users";
    dataDir   = home;
    configDir = "${home}/.config/syncthing";

    cert = config.sops.secrets.syncthing-cert.path;
    key  = config.sops.secrets.syncthing-key.path;

    settings = {
      # Reach peers only over tailscale, by MagicDNS name. Every host already
      # sets services.resolved.enable and trusts the tailscale0 interface
      # (modules/common/tailscale.nix), so there are no firewall rules to add.
      devices = lib.genAttrs peers (name: {
        id        = devices.${name};
        addresses = [ "tcp://${name}.${tailnet}:22000" ];
      });

      folders = {
        # Claude Code session transcripts and memory. Small (~1M) and the
        # reason `claude --resume` works on whichever machine you pick up next.
        # Deliberately NOT ~/.claude wholesale: that would drag along
        # .credentials.json and .claude.json, and two hosts refreshing the same
        # OAuth token can invalidate each other.
        #
        # The work account is synced too, but separately — see below.
        claude-projects = {
          id      = "claude-projects";
          path    = "${home}/.claude/projects";
          devices = peers;
          inherit versioning;
        };

        # General scratch: debug output, notes, one-off files. Anything that
        # would otherwise die in /tmp on the next reboot.
        sync = {
          id      = "sync";
          path    = "${home}/sync";
          devices = peers;
          inherit versioning;
        };
      }
      # Everything carrying work data goes through the hub encrypted. kaleipo
      # cannot be avoided — the workstations are rarely online together — but it
      # is a machine at home, so it relays ciphertext rather than being trusted.
      #
      # Both halves of an investigation are covered: the session transcript and
      # the working files. Encrypting only the transcript would leave the
      # artifacts it produced (exports, logs, captured output) in the clear,
      # which is usually the more sensitive half.
      // encryptedFolder {
        id      = "claude-work-projects";
        path    = "${home}/.claude-work/projects";
        hubPath = "${home}/syncthing-encrypted/claude-work";
      }
      // encryptedFolder {
        id      = "sync-work";
        path    = "${home}/sync-work";
        hubPath = "${home}/syncthing-encrypted/sync-work";
      };

      options = {
        # Tailscale is the only transport: no public discovery, no relays, no
        # NAT traversal, and no phoning home.
        globalAnnounceEnabled = false;
        localAnnounceEnabled  = false;
        relaysEnabled         = false;
        natEnabled            = false;
        urAccepted            = -1;
      };
    };
  };
}
