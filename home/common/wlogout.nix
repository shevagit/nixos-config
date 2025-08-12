{ config, pkgs, ... }:

{
  # Apps
  home.packages = with pkgs; [
    wlogout
  ];

  programs.wlogout = {
    enable = true;
    package = pkgs.wlogout;

    # Correct JSON layout (Home-Manager renders this to ~/.config/wlogout/layout)
    layout = [
      { label = "lock";     text = "🔒 Lock";    action = "${pkgs.hyprlock}/bin/hyprlock";                        keybind = "l"; }
      { label = "logout";   text = "🚪 Logout";  action = "${pkgs.hyprland}/bin/hyprctl dispatch exit 0";         keybind = "o"; }
      { label = "reboot";   text = "🔄 Restart"; action = "${pkgs.systemd}/bin/systemctl reboot";                 keybind = "r"; }
      { label = "shutdown"; text = "⏻ Shutdown"; action = "${pkgs.systemd}/bin/systemctl poweroff";              keybind = "s"; }
    ];

    # Pretty translucent style (goes to ~/.config/wlogout/style.css)
    style = ''
      window { background-color: rgba(0,0,0,0.35); }

      button {
        background-color: rgba(24,24,27,0.88);
        color: #e5e7eb;
        border: 2px solid rgba(255,255,255,0.08);
        border-radius: 24px;
        padding: 18px 22px;
        margin: 12px;
        min-width: 220px;
        min-height: 90px;
        font-size: 18px;
      }
      button:focus, button:hover {
        background-color: rgba(39,39,42,0.95);
        border-color: rgba(255,255,255,0.22);
      }

      /* per-button accents via label ids */
      #lock     { border-color: rgba(96,165,250,0.35); }   /* blue */
      #logout   { border-color: rgba(147,197,253,0.35); }
      #reboot   { border-color: rgba(52,211,153,0.35); }   /* green */
      #shutdown { border-color: rgba(248,113,113,0.45); }  /* red */

      /* optional keybind hint labels if theme shows them */
      button label#text   { font-weight: 600; font-size: 18px; margin-top: 6px; }
      button label#keybind{ font-size: 13px; opacity: 0.7; margin-top: 4px; }
    '';
  };

  # Small wrapper to toggle wlogout (press SUPER+P again to close)
  home.file.".config/wlogout/scripts/power-menu".text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    if pgrep -x wlogout >/dev/null; then
      pkill -x wlogout
      exit 0
    fi

    exec ${pkgs.wlogout}/bin/wlogout \
      -b 4 \               # 4 buttons per row
      -T 200 \             # top margin
      -B 200 \             # bottom margin
      --layout "$HOME/.config/wlogout/layout" \
      --css "$HOME/.config/wlogout/style.css"
    '';

  home.file.".config/wlogout/scripts/power-menu".executable = true;

}
