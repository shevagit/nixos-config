{ ... }:

{
  # zsh history shared across nontas / simos / athanasiou, searchable with
  # Ctrl-R, showing which machine each command came from. The server lives on
  # kaleipo (modules/services/atuin.nix), reached over Tailscale.
  #
  # The native zsh history (history.* in zsh.nix) is kept intact as a fallback;
  # atuin layers on top of it.
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;

    # atuin takes over Ctrl-R. Keep the Up arrow bound to zsh's own history
    # so there's still a local fallback if atuin/the server is unavailable.
    flags = [ "--disable-up-arrow" ];

    settings = {
      # kaleipo over Tailscale MagicDNS (tailnet IP 100.108.44.89). This is the
      # self-hosted server — never the public api.atuin.sh.
      sync_address = "http://kaleipo:8888";
      auto_sync = true;
      # Mostly single-machine use, so no need for aggressive syncing: auto-sync
      # runs hourly (keeps kaleipo as a recent backup). Full history still lives
      # locally; run `atuin sync` by hand for an immediate push/pull when hopping
      # machines.
      sync_frequency = "1h";

      ui = {
        # Columns shown in the Ctrl-R TUI, left to right. `host` is the whole
        # point of this setup — it tags each command with its origin machine.
        # (UiColumnType in atuin-client, confirmed present in 18.24.5.)
        columns = [ "duration" "time" "host" "command" ];
      };
    };
  };
}
