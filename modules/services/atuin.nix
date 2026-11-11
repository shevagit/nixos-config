{ pkgs-unstable, lib, ... }:

{
  # Self-hosted atuin sync server: the hub for zsh history shared across the
  # three desktops (nontas / simos / athanasiou). Clients are configured in
  # home/common/atuin.nix.
  #
  # Reachable over Tailscale ONLY (firewall rule at the bottom); never on the
  # public interface. atuin end-to-end encrypts history on the clients, so this
  # server only ever stores ciphertext — but we keep it off the public internet
  # anyway, because the history contains work commands (kubectl contexts, prod
  # namespaces, gcloud).
  services.atuin = {
    enable = true;

    # Match the clients' atuin to avoid any client/server sync-protocol skew:
    # the desktops are on nixpkgs-unstable (18.24.5) while kaleipo tracks stable
    # 25.05 (18.6.1). kaleipo already pulls pkgs-unstable for tailscale.
    package = pkgs-unstable.atuin;

    # Bind on all interfaces and gate reachability with the tailscale0-only
    # firewall rule below — the same approach glances uses in monitoring.nix.
    # Binding straight to the tailscale IP would race tailscaled on boot
    # (the service starts after network.target, before tailscale0 has its IP).
    host = "0.0.0.0";
    port = 8888;

    # Required so the first account can register. Flip to false and rebuild once
    # every host has registered / logged in (see the manual steps in CLAUDE.md).
    openRegistration = true;

    # openFirewall would punch the PUBLIC firewall. Keep it off; the port is
    # opened on tailscale0 only, below.
    openFirewall = false;

    # database.createLocally defaults to true: provisions a local postgres db
    # and user for atuin. The DB holds only atuin's encrypted history records.
  };

  # nixpkgs' atuin 18.24.5 (unstable) splits the server into a separate
  # `atuin-server` binary. The stock NixOS 25.05 module's ExecStart runs
  # `${atuin} server start`, but the main `atuin` binary no longer has that
  # subcommand (→ "unrecognized subcommand 'server'", unit fails on start).
  # Point the unit at atuin-server directly — it reads the same ATUIN_* env
  # vars the module sets. (Stable's unified atuin has `atuin server`; this
  # override is only needed because we pin the server to unstable for parity
  # with the clients. Drop it if the server ever moves back to stable atuin.)
  systemd.services.atuin.serviceConfig.ExecStart =
    lib.mkForce "${pkgs-unstable.atuin}/bin/atuin-server start";

  # Reachable only from the tailnet, exactly like glances (monitoring.nix).
  # This list option merges with monitoring.nix's entry (61208) across modules.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8888 ];
}
