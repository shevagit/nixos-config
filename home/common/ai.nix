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
