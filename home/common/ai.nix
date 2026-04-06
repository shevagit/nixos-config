{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    code-cursor
    # claude-code — installed via native installer (~/.local/bin/claude), auto-updates on boot
    opencode
  ];

  home.activation.claude-code = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    CURRENT=$(${pkgs.nodejs}/bin/npm list -g @anthropic-ai/claude-code --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.dependencies["@anthropic-ai/claude-code"].version // empty')
    LATEST=$(${pkgs.nodejs}/bin/npm view @anthropic-ai/claude-code version 2>/dev/null || true)
    if [ -n "$LATEST" ] && [ "$CURRENT" != "$LATEST" ]; then
      ${pkgs.nodejs}/bin/npm install -g @anthropic-ai/claude-code 2>/dev/null || true
    fi
  '';
}
