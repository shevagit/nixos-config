{ config, pkgs, lib, ... }:

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
