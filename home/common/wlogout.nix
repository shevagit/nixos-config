{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ 
    wlogout 
  ];

  programs.wlogout = {
    enable = false;
    package = pkgs.wlogout;

    layout = [
      { label = "lock";     text = "  Lock";     action = "${pkgs.hyprlock}/bin/hyprlock"; keybind = "l"; }
      { label = "logout";   text = "  Logout";   action = "${pkgs.hyprland}/bin/hyprctl dispatch exit 0"; keybind = "o"; }
      { label = "reboot";   text = "  Restart";  action = "${pkgs.systemd}/bin/systemctl reboot"; keybind = "r"; }
      { label = "shutdown"; text = "  Shutdown"; action = "${pkgs.systemd}/bin/systemctl poweroff"; keybind = "s"; }
    ];

    style = ''
      window {
        background-color: rgba(0,0,0,0.35);
      }

      button {
        background-image: linear-gradient(180deg, rgba(41,45,62,0.92), rgba(20,22,30,0.92));
        color: #ECEFF4;
        border: 1px solid rgba(255,255,255,0.10);
        border-radius: 20px;
        padding: 24px;
        margin: 14px;
        min-width: 260px;
        min-height: 130px;
        box-shadow: 0 6px 24px rgba(0,0,0,0.35), inset 0 1px 0 rgba(255,255,255,0.06);
        transition: transform .12s ease, box-shadow .2s ease, border-color .2s ease, background .2s ease;
        font-family: "JetBrainsMono Nerd Font", "FiraCode Nerd Font", "Hack Nerd Font", "Noto Sans", sans-serif;
      }

      button:hover, button:focus {
        transform: translateY(-2px);
        box-shadow: 0 14px 34px rgba(0,0,0,0.45), inset 0 1px 0 rgba(255,255,255,0.08);
        border-color: rgba(255,255,255,0.20);
      }

      /* Hide default GTK icon completely */
      button image {
        min-width: 0;
        min-height: 0;
        padding: 0;
        margin: 0;
        opacity: 0;
      }

      /* Main label with icon glyph included */
      button label#text {
        font-weight: 800;
        font-size: 28px;
        letter-spacing: 0.2px;
        margin-bottom: 8px;
      }

      /* Keybind hint */
      button label#keybind {
        font-size: 14px;
        opacity: 0.75;
      }

      /* Per-button accents */
      #lock     { border-color: rgba(96,165,250,0.35); }
      #logout   { border-color: rgba(147,197,253,0.35); }
      #reboot   { border-color: rgba(52,211,153,0.35); }
      #shutdown { border-color: rgba(248,113,113,0.45); }

      #lock:hover     { box-shadow: 0 14px 34px rgba(0,0,0,0.45), 0 0 20px 4px rgba(59,130,246,0.18); }
      #logout:hover   { box-shadow: 0 14px 34px rgba(0,0,0,0.45), 0 0 20px 4px rgba(147,197,253,0.18); }
      #reboot:hover   { box-shadow: 0 14px 34px rgba(0,0,0,0.45), 0 0 20px 4px rgba(52,211,153,0.18); }
      #shutdown:hover { box-shadow: 0 14px 34px rgba(0,0,0,0.45), 0 0 20px 4px rgba(248,113,113,0.20); }
    '';
  };

  home.file.".config/wlogout/scripts/power-menu".text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    if pgrep -x wlogout >/dev/null; then
      pkill -x wlogout
      exit 0
    fi

    exec wlogout \
      -s \
      -b 2 \
      -T 180 -B 180 \
      --layout "$HOME/.config/wlogout/layout" \
      --css "$HOME/.config/wlogout/style.css"
  '';
  home.file.".config/wlogout/scripts/power-menu".executable = true;

}
