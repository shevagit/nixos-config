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
        # To sync the work account too, add ~/.claude-work/projects the same
        # way — left out by default so work session data stays off the server.
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
