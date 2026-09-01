{ config, lib, ... }:

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
      # The work (Team) account syncs between the workstations the same way, but
      # kaleipo carries it as an untrusted device: it store-and-forwards
      # ciphertext it holds no key for. The hub is still required — the
      # workstations are rarely online together — but employer session data
      # never sits in the clear on a machine at home.
      // (
        if isHub then {
          claude-work-projects = {
            id      = "claude-work-projects";
            # Encrypted blobs with encrypted filenames, not readable files.
            # Kept away from ~/.claude-work so nothing mistakes it for real data.
            path    = "${home}/syncthing-encrypted/claude-work";
            type    = "receiveencrypted";
            devices = workstations;
          };
        } else {
          claude-work-projects = {
            id      = "claude-work-projects";
            path    = "${home}/.claude-work/projects";
            devices = otherWorkstations ++ [{
              name                   = hub;
              encryptionPasswordFile = config.sops.secrets.syncthing-work-encryption.path;
            }];
            inherit versioning;
          };
        }
      );

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
