{ config, pkgs, lib, ... }:

let
  # Cursor is Electron/Chromium; under Hyprland (an unrecognized desktop env)
  # Chromium can't auto-detect the keyring backend and errors with "An OS keyring
  # couldn't be identified". gnome-keyring IS running and owns org.freedesktop.secrets,
  # so we just have to tell Chromium to use it — same fix as mongodb-compass in
  # home/default.nix. The .desktop files call bare `cursor` (PATH-resolved), so
  # wrapping the package binary fixes both the launcher and the CLI.
  code-cursor = pkgs.symlinkJoin {
    name = "code-cursor-keyring";
    paths = [ pkgs.code-cursor ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm "$out/bin/cursor"
      makeWrapper ${pkgs.code-cursor}/bin/cursor "$out/bin/cursor" \
        --add-flags "--password-store=gnome-libsecret"
    '';
  };
in
{
  home.packages = with pkgs; [
    code-cursor
    # claude-code — installed via native installer (~/.local/bin/claude), auto-updates on boot
    opencode
  ];

  # Second Claude Code account (work/Team) lives in ~/.claude-work, selected by
  # CLAUDE_CONFIG_DIR via the `claudew` wrapper in zsh.nix. That dir gets its own
  # login, session history and memory; only the hand-written extensions below are
  # shared, so a skill written once shows up in both accounts.
  #
  # These are out-of-store symlinks because skills are edited by hand (and by
  # Claude) at runtime — a nix store path would be read-only. Dangling until the
  # personal dirs exist, which the activation script below takes care of.
  home.file.".claude-work/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.claude/skills";
  home.file.".claude-work/commands".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.claude/commands";
  home.file.".claude-work/agents".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.claude/agents";

  # User-level instructions, loaded by Claude Code in every project on every
  # host. This is the half that makes the synced scratch folder actually get
  # used — without it we keep writing debug output into /tmp, which is tmpfs
  # and gone on reboot. Both accounts get it.
  #
  # Managed by nix, so it lands read-only; switch to mkOutOfStoreSymlink if you
  # want to hand-edit it.
  home.file.".claude/CLAUDE.md".text = ''
    # Working notes

    Start an investigation in its own directory under the synced tree, so the
    working files and the session travel together to my other machines:

    - personal account -> `~/sync/<topic>/`
    - work account (`claudew`) -> `~/sync-work/<topic>/`

    Both live at the same absolute path on every machine, which is what lets
    `claude --resume` find the session there — the project is keyed to its full
    path. Scratch that has no project of its own goes in `~/sync/scratch/`.

    Use `/tmp` only for genuinely throwaway files within a single session; it is
    tmpfs and gone on reboot.

    Session transcripts sync the same way, so `claude --resume` on another
    machine picks the conversation back up.

    Anything under `~/sync-work` and the work account's transcripts passes
    through the kaleipo hub encrypted; the personal equivalents do not. Keep
    work material on the work side.
  '';
  home.file.".claude-work/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.claude/CLAUDE.md";

  home.activation.claude-work = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    for d in skills commands agents; do
      mkdir -p "$HOME/.claude/$d"
    done
    mkdir -p "$HOME/sync/scratch"
    mkdir -p "$HOME/.claude-work/projects"
    # settings.json is rewritten in place by /config, and an atomic rewrite would
    # replace a symlink with a real file — so seed a copy once and let the two
    # accounts diverge from there.
    if [ ! -e "$HOME/.claude-work/settings.json" ] && [ -f "$HOME/.claude/settings.json" ]; then
      mkdir -p "$HOME/.claude-work"
      cp "$HOME/.claude/settings.json" "$HOME/.claude-work/settings.json"
    fi
  '';

  home.activation.claude-code = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    STAMP="$HOME/.cache/claude-code-last-update"
    if [ -x "$HOME/.local/bin/claude" ]; then
      NOW=$(date +%s)
      LAST=0
      [ -f "$STAMP" ] && LAST=$(cat "$STAMP" 2>/dev/null || echo 0)
      if [ $(( NOW - LAST )) -gt 86400 ]; then
        mkdir -p "$(dirname "$STAMP")"
        echo "$NOW" > "$STAMP"
        ( "$HOME/.local/bin/claude" update >/dev/null 2>&1 || true ) &
        disown || true
      fi
    fi
  '';
}
